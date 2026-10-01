import SwiftUI
import UIKit
import Foundation

struct AIChatRequest: Encodable {
    let message: String
    let conversation: [AIConversationMessage]
}

struct AIConversationMessage: Codable {
    let role: String
    let content: String
}

struct AIChatResponse: Decodable {
    let reply: String
    let sources: [AISource]
}

struct AISource: Decodable, Identifiable {
    let title: String
    let source: String
    let id: String
    let url: String
}

struct ArchivedAnswer: Identifiable {
    let id = UUID()
    let prompt: String
    let answer: String
    let createdAt: Date
}

struct WebSearchResult: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let snippet: String
    let faviconURL: String
}

final class AIManager: ObservableObject {
    @AppStorage("aiServerURL") private var serverURL: String = ""
    @AppStorage("aiServerToken") private var serverToken: String = ""
    
    @Published private(set) var isLoading = false
    @Published private(set) var statusText = "Ready"
    @Published private(set) var approachSummary = ""
    @Published var errorMessage: String?
    @Published private(set) var debugLog: [String] = []
    
    var debugLogText: String {
        debugLog.isEmpty ? "No AI log available yet." : debugLog.joined(separator: "\n")
    }
    
    func clearDebugLog() {
        debugLog.removeAll()
    }
    
    func record(_ message: String) {
        addLog("[\(time())] \(message)")
    }
    
    func cancel() {
        activeTask?.cancel()
        activeTask = nil
        isLoading = false
        statusText = "Stopped by user"
        addLog("[\(time())] Request cancelled by user")
    }
    
    private var activeTask: Task<Void, Never>?
    
    func sendStreaming(message: String, history: [ChatMessage], onText: @escaping (String) -> Void, onSources: @escaping ([AISource]) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let baseURL = normalizedServerURL(), let url = URL(string: baseURL + "/chat/stream") else {
            let error = AIManagerError.serverNotConfigured
            addLog("[\(time())] ERROR: AI server address missing or invalid.")
            completion(.failure(error))
            return
        }
        
        activeTask?.cancel()
        let conversation = history.suffix(12).map { AIConversationMessage(role: $0.isUser ? "user" : "assistant", content: $0.text) }
        let body = AIChatRequest(message: message, conversation: Array(conversation))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !serverToken.isEmpty { request.setValue("Bearer \(serverToken)", forHTTPHeaderField: "Authorization") }
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        statusText = "Connecting to AI..."
        approachSummary = "Connecting to the local GetDone AI..."
        isLoading = true
        addLog("[\(time())] Streaming started to \(baseURL)/chat/stream")
        
        activeTask = Task {
            do {
                let (bytes, response) = try await URLSession.shared.bytes(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw AIManagerError.invalidResponse
                }
                
                statusText = "AI is responding..."
                for try await line in bytes.lines {
                    try Task.checkCancellation()
                    guard let data = line.data(using: .utf8),
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
                    if let error = json["error"] as? String { throw AIManagerError.backend(error) }
                    if json["type"] as? String == "sources",
                       let sourcePayload = json["sources"] as? [[String: Any]],
                       let sourceData = try? JSONSerialization.data(withJSONObject: sourcePayload),
                       let sources = try? JSONDecoder().decode([AISource].self, from: sourceData) {
                        onSources(sources)
                        continue
                    }
                    if json["type"] as? String == "status" {
                        if let status = json["status"] as? String {
                            statusText = status
                        }
                        if let summary = json["summary"] as? String {
                            approachSummary = summary
                        }
                        continue
                    }
                    if let choices = json["choices"] as? [[String: Any]],
                       let delta = choices.first?["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        if statusText != "AI is typing..." {
                            statusText = "AI is typing..."
                        }
                        onText(content)
                    }
                }
                
                await MainActor.run {
                    self.isLoading = false
                    self.statusText = "Ready"
                    self.approachSummary = "Answer received."
                    self.activeTask = nil
                    self.addLog("[\(self.time())] Streaming complete")
                    completion(.success(()))
                }
            } catch is CancellationError {
                await MainActor.run {
                    self.isLoading = false
                    self.statusText = "Stopped by user"
                    self.approachSummary = "The request was stopped."
                    self.activeTask = nil
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.statusText = "Error"
                    self.approachSummary = "Something went wrong while fetching the answer."
                    self.activeTask = nil
                    self.addLog("[\(self.time())] STREAM ERROR: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func send(message: String, history: [ChatMessage], completion: @escaping (Result<AIChatResponse, Error>) -> Void) {
        let startTime = Date()
        guard let baseURL = normalizedServerURL(), let url = URL(string: baseURL + "/chat") else {
            addLog("[\(time())] ERROR: AI server address missing or invalid.")
            completion(.failure(AIManagerError.serverNotConfigured))
            return
        }
        
        addLog("[\(time())] Chat message sent to \(baseURL)/chat")
        let conversation = history.suffix(12).map { item in
            AIConversationMessage(role: item.isUser ? "user" : "assistant", content: item.text)
        }
        let requestBody = AIChatRequest(message: message, conversation: Array(conversation))
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !serverToken.isEmpty {
            request.setValue("Bearer \(serverToken)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            addLog("[\(time())] ERROR: failed to build request: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        addLog("[\(time())] Connecting...")
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { self.isLoading = false } }
            
            if let error {
                self.addLog("[\(self.time())] NETWORK ERROR after \(self.elapsedSince(startTime)): \(error.localizedDescription)")
                self.complete(.failure(error), completion: completion)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data else {
                self.addLog("[\(self.time())] ERROR: no valid HTTP response received.")
                self.complete(.failure(AIManagerError.invalidResponse), completion: completion)
                return
            }
            self.addLog("[\(self.time())] HTTP \(httpResponse.statusCode) received after \(self.elapsedSince(startTime))")
            guard (200...299).contains(httpResponse.statusCode) else {
                self.addLog("[\(self.time())] SERVER ERROR: status code \(httpResponse.statusCode)")
                self.complete(.failure(AIManagerError.server(statusCode: httpResponse.statusCode)), completion: completion)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AIChatResponse.self, from: data)
                self.addLog("[\(self.time())] Answer received (\(response.reply.count) characters)")
                self.complete(.success(response), completion: completion)
            } catch {
                self.addLog("[\(self.time())] ERROR: invalid JSON response: \(error.localizedDescription)")
                self.complete(.failure(error), completion: completion)
            }
        }.resume()
    }
    
    private func addLog(_ message: String) {
        print("[GetDone AI] \(message)")
        DispatchQueue.main.async {
            self.debugLog.append(message)
            if self.debugLog.count > 100 {
                self.debugLog.removeFirst(self.debugLog.count - 100)
            }
        }
    }
    
    private func time() -> String {
        Date().formatted(date: .omitted, time: .standard)
    }
    
    private func elapsedSince(_ startTime: Date) -> String {
        String(format: "%.1fs", Date().timeIntervalSince(startTime))
    }
    
    private func normalizedServerURL() -> String? {
        let value = serverURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !value.isEmpty, URL(string: value) != nil else { return nil }
        return value
    }
    
    private func complete(_ result: Result<AIChatResponse, Error>, completion: @escaping (Result<AIChatResponse, Error>) -> Void) {
        DispatchQueue.main.async {
            if case .failure(let error) = result { self.errorMessage = error.localizedDescription }
            completion(result)
        }
    }
}

enum AIManagerError: LocalizedError {
    case serverNotConfigured
    case invalidResponse
    case server(statusCode: Int)
    case backend(String)
    
    var errorDescription: String? {
        switch self {
        case .serverNotConfigured:
            return "The AI server has not been configured in your profile."
        case .invalidResponse:
            return "The AI server returned an invalid response."
        case .server(let statusCode):
            return "The AI server returned error code \(statusCode)."
        case .backend(let message):
            return message
        }
    }
}

// MARK: - 💬 CHAT COMPONENTS
struct ChatView: View {
    var title: String
    
    @AppStorage("ai_provider") private var aiProvider: String = "auto"
    @AppStorage("google_user_name") private var googleUserName: String = ""
    @AppStorage("magister_voornaam") private var magisterFirstName: String = ""
    @AppStorage("magister_achternaam") private var magisterLastName: String = ""
    
    @StateObject private var aiManager = AIManager()
    @State private var showLog = false
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var streamingReply = ""
    @State private var scrollTarget: UUID?
    @State private var autoScrollEnabled = true
    @State private var isUserDragging = false
    @State private var responseStopped = false
    @State private var archivedAnswers: [ArchivedAnswer] = []
    @State private var editingMessageID: UUID? = nil
    @State private var originalEditingText: String = ""
    @State private var showArchivedAnswers = false
    @State private var webSourcesByMessageID: [UUID: [WebSearchResult]] = [:]
    @State private var selectedWebSources: [WebSearchResult] = []
    @State private var isShowingWebSources = false
    @State private var activeWebSources: [WebSearchResult] = []
    
    private let welcomeTemplates = [
        "Welcome back, {name} — lets make today count.",
        "Hey {name}, good to have you. Lets get started.",
        "Good morning, {name}. Your plan for today is ready.",
        "Hello {name}, your overview is here. Time to start."
    ]
    
    private var displayUserName: String {
        let magisterName = "\(magisterFirstName) \(magisterLastName)".trimmingCharacters(in: .whitespaces)
        if !magisterName.isEmpty { return magisterName }
        if !googleUserName.isEmpty { return googleUserName }
        return "User"
    }
    
    private var welcomeGreeting: String {
        let name = displayUserName
        let index = abs(name.lowercased().unicodeScalars.reduce(0) { $0 + Int($1.value) }) % welcomeTemplates.count
        return welcomeTemplates[index].replacingOccurrences(of: "{name}", with: name)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.12),
                    Color(red: 0.10, green: 0.10, blue: 0.18),
                    Color(red: 0.06, green: 0.07, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if messages.isEmpty && !aiManager.isLoading {
                WelcomeHeroView(greeting: welcomeGreeting)
                    .zIndex(1)
            }
            
            // 1. Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) { 
                        ForEach(messages) { message in
                            ChatBubble(
                                message: message,
                                onCopy: {
                                    copyMessage(message.text)
                                },
                                onRetry: message.isUser ? nil : {
                                    retryAssistantResponse(message)
                                },
                                onEdit: message.isUser ? {
                                    editUserMessage(message)
                                } : nil,
                                webSources: sources(for: message)
                            )
                            .id(message.id)
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                        }
                        if !streamingReply.isEmpty {
                            ChatBubble(
                                message: ChatMessage(text: streamingReply, isUser: false),
                                onCopy: {
                                    copyMessage(streamingReply)
                                },
                                onRetry: {
                                    retryCurrentStreamingReply()
                                },
                                onEdit: nil,
                                webSources: activeWebSources
                            )
                            .id("streaming-reply")
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.18), value: streamingReply)
                        } else if aiManager.isLoading {
                            ThinkingIndicator(status: aiManager.statusText, summary: aiManager.approachSummary)
                                .id("thinking-indicator")
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        if responseStopped {
                            VStack(spacing: 8) {
                                StoppedResponseDivider()
                                Button {
                                    retryStoppedResponse()
                                } label: {
                                    Label("Retry answer", systemImage: "arrow.counterclockwise")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.7))
                                        .clipShape(Capsule())
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    Color.clear
                        .frame(height: 180)
                        .id("bottomAnchor")
                }
                .coordinateSpace(name: "chatScrollView")
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !isUserDragging {
                                isUserDragging = true
                                autoScrollEnabled = false
                            }
                        }
                        .onEnded { _ in
                            isUserDragging = false
                        }
                )
                .onChange(of: messages.count) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let scrollTarget {
                            proxy.scrollTo(scrollTarget, anchor: .top)
                            self.scrollTarget = nil
                        } else if autoScrollEnabled && !isUserDragging {
                            proxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: streamingReply) {
                    guard !streamingReply.isEmpty, autoScrollEnabled, !isUserDragging else { return }
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
            
            // 2. Floating input field
            VStack(spacing: 8) {
                if editingMessageID != nil {
                    HStack {
                        Button("Cancel edit") {
                            inputText = ""
                            editingMessageID = nil
                            originalEditingText = ""
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                }
                
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Type a message...", text: $inputText, axis: .vertical)
                        .padding(.leading, 20)
                        .padding(.vertical, 14)
                        .lineLimit(1...6)
                        .foregroundColor(.white)
                        .font(.body)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                    
                    Button {
                        if aiManager.isLoading {
                            aiManager.cancel()
                            responseStopped = true
                        } else {
                            sendMessage()
                        }
                    } label: {
                        Image(systemName: aiManager.isLoading ? "stop.fill" : "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(aiManager.isLoading ? .red : (inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .black))
                            .frame(width: 32, height: 32)
                            .background(
                                aiManager.isLoading
                                ? Color.white.opacity(0.1)
                                : (inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                   ? Color.white.opacity(0.1) 
                                   : Color.white)
                            )
                            .clipShape(Circle())
                            .animation(.easeInOut(duration: 0.2), value: aiManager.isLoading)
                    }
                    .padding(.trailing, 10)
                    .padding(.bottom, 8)
                    .disabled(!aiManager.isLoading && inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 2)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
            }
            
        }
        .background(Color.clear)
        .onAppear {
            aiManager.record("Chat opened")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button(action: { aiProvider = "auto" }) {
                        Label("Auto", systemImage: aiProvider == "auto" ? "checkmark" : "")
                    }
                    Button(action: { aiProvider = "gemini" }) {
                        Label("Gemini API", systemImage: aiProvider == "gemini" ? "checkmark" : "")
                    }
                    Button(action: { aiProvider = "local" }) {
                        Label("Local Model", systemImage: aiProvider == "local" ? "checkmark" : "")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: aiProvider == "gemini" ? "sparkles" : (aiProvider == "local" ? "desktopcomputer" : "wand.and.stars"))
                            .font(.system(size: 14, weight: .semibold))
                        Text(aiProvider == "gemini" ? "Gemini" : (aiProvider == "local" ? "Local" : "Auto"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Choose AI provider")
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showArchivedAnswers = true
                } label: {
                    Image(systemName: "archivebox")
                        .font(.system(size: 16, weight: .semibold))
                }
                .accessibilityLabel("Archived Answers")
                .foregroundColor(.white)
                .padding(.horizontal, 2)
                
                Button {
                    showLog = true
                } label: {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                }
                .accessibilityLabel("AI Log")
                .foregroundColor(.white)
                .padding(.horizontal, 2)
            }
        }
        .sheet(isPresented: $showLog) {
            AILogView(aiManager: aiManager)
        }
        .sheet(isPresented: $showArchivedAnswers) {
            ArchivedResponsesView(archivedAnswers: $archivedAnswers)
        }
        .sheet(isPresented: $isShowingWebSources) {
            WebResultsSheet(results: selectedWebSources)
        }
    }
    
    private func sendMessage(forceText: String? = nil) {
        let text = (forceText ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        if let editingID = editingMessageID {
            if let userIndex = messages.firstIndex(where: { $0.id == editingID }) {
                var archivedAnswerText: String?
                if userIndex + 1 < messages.count && !messages[userIndex + 1].isUser {
                    archivedAnswerText = messages[userIndex + 1].text
                }
                archiveAnswer(archivedAnswerText ?? messages[userIndex].text, forPrompt: messages[userIndex].text)
                
                var indexesToRemove = [userIndex]
                if userIndex + 1 < messages.count && !messages[userIndex + 1].isUser {
                    indexesToRemove.append(userIndex + 1)
                }
                for index in indexesToRemove.sorted(by: >) {
                    messages.remove(at: index)
                }
            }
            editingMessageID = nil
            originalEditingText = ""
        }
        
        let userMessage = ChatMessage(text: text, isUser: true)
        autoScrollEnabled = true
        responseStopped = false
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            messages.append(userMessage)
        }
        scrollTarget = userMessage.id
        inputText = ""
        
        startStreaming(message: text, history: messages)
    }
    
    private func startStreaming(message: String, history: [ChatMessage]) {
        streamingReply = ""
        activeWebSources = []
        
        aiManager.sendStreaming(message: message, history: history, onText: { chunk in
            streamingReply += chunk
        }, onSources: { sources in
            activeWebSources = sources.map { source in
                let url = source.url
                return WebSearchResult(
                    title: source.title,
                    url: url,
                    snippet: source.source,
                    faviconURL: faviconURL(for: url)
                )
            }
        }) { result in
            switch result {
            case .success:
                if !streamingReply.isEmpty {
                    let assistantMessage = ChatMessage(text: streamingReply, isUser: false)
                    messages.append(assistantMessage)
                    webSourcesByMessageID[assistantMessage.id] = activeWebSources
                }
                streamingReply = ""
                activeWebSources = []
            case .failure(let error):
                if responseStopped {
                    return
                }
                if !streamingReply.isEmpty {
                    messages.append(ChatMessage(text: streamingReply, isUser: false))
                }
                messages.append(ChatMessage(text: "AI not available: \(error.localizedDescription)", isUser: false))
                streamingReply = ""
                activeWebSources = []
            }
        }
    }
    
    private func retryAssistantResponse(_ assistantMessage: ChatMessage) {
        guard let assistantIndex = messages.firstIndex(where: { $0.id == assistantMessage.id }) else { return }
        guard let promptIndex = previousUserMessageIndex(before: assistantIndex) else { return }
        guard promptIndex >= 0, promptIndex < messages.count else { return }
        
        let promptText = messages[promptIndex].text
        guard !promptText.isEmpty else { return }
        
        if !assistantMessage.text.isEmpty {
            archiveAnswer(assistantMessage.text, forPrompt: promptText)
        }
        
        messages.remove(at: assistantIndex)
        responseStopped = false
        autoScrollEnabled = true
        streamingReply = ""
        
        if aiManager.isLoading {
            aiManager.cancel()
        }
        
        let historyForRetry = Array(messages.prefix(max(0, assistantIndex)))
        startStreaming(message: promptText, history: historyForRetry)
    }
    
    private func editUserMessage(_ userMessage: ChatMessage) {
        guard let userIndex = messages.firstIndex(where: { $0.id == userMessage.id }) else { return }
        let originalPrompt = userMessage.text
        let trimmedPrompt = originalPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return }
        
        // Do NOT archive or remove messages yet. Just place text in input box and store state for editing.
        editingMessageID = userMessage.id
        originalEditingText = trimmedPrompt
        inputText = trimmedPrompt
    }
    
    private func retryCurrentStreamingReply() {
        guard let lastUserMessage = messages.last(where: { $0.isUser }) else { return }
        let promptText = lastUserMessage.text
        
        if !streamingReply.isEmpty {
            archiveAnswer(streamingReply, forPrompt: promptText)
        }
        
        responseStopped = false
        autoScrollEnabled = true
        streamingReply = ""
        
        if aiManager.isLoading {
            aiManager.cancel()
        }
        
        let historyForRetry = messages.filter { $0.id != lastUserMessage.id }
        startStreaming(message: promptText, history: historyForRetry)
    }
    
    private func retryStoppedResponse() {
        guard let lastUserMessage = messages.last(where: { $0.isUser }) else { return }
        let promptText = lastUserMessage.text
        
        if !streamingReply.isEmpty {
            archiveAnswer(streamingReply, forPrompt: promptText)
        }
        
        responseStopped = false
        autoScrollEnabled = true
        streamingReply = ""
        
        if aiManager.isLoading {
            aiManager.cancel()
        }
        
        let historyForRetry = messages.filter { $0.id != lastUserMessage.id }
        startStreaming(message: promptText, history: historyForRetry)
    }
    
    private func archiveAnswer(_ answer: String, forPrompt prompt: String) {
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAnswer.isEmpty else { return }
        archivedAnswers.insert(ArchivedAnswer(prompt: prompt, answer: trimmedAnswer, createdAt: Date()), at: 0)
    }
    
    private func domainName(from urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return "Website" }
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    private func faviconURL(for urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return "" }
        return "https://www.google.com/s2/favicons?domain=\(host)&sz=64"
    }
    
    private func previousUserMessageIndex(before assistantIndex: Int) -> Int? {
        for index in stride(from: assistantIndex - 1, through: 0, by: -1) {
            if messages[index].isUser {
                return index
            }
        }
        return nil
    }
    
    private func copyMessage(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func sources(for message: ChatMessage) -> [WebSearchResult] {
        guard !message.isUser else { return [] }
        return webSourcesByMessageID[message.id] ?? []
    }
}

struct WelcomeHeroView: View {
    let greeting: String
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.22))
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .offset(x: -geometry.size.width * 0.2, y: -geometry.size.height * 0.18)
                        .scaleEffect(pulse ? 1.12 : 0.82)
                        .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: pulse)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.18))
                        .frame(width: geometry.size.width * 0.65, height: geometry.size.width * 0.65)
                        .offset(x: geometry.size.width * 0.22, y: geometry.size.height * 0.18)
                        .scaleEffect(pulse ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: pulse)
                    
                    Circle()
                        .fill(Color.cyan.opacity(0.14))
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        .offset(x: 0, y: geometry.size.height * 0.12)
                        .scaleEffect(pulse ? 1.15 : 0.8)
                        .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: pulse)
                }
            }
            .blur(radius: 10)
            
            VStack(spacing: 18) {
                Text("Welcome")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .kerning(3)
                    .textCase(.uppercase)
                
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: greeting)
            }
            .frame(maxWidth: 440)
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .blur(radius: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
        .onAppear { pulse = true }
    }
}

struct ThinkingIndicator: View {
    let status: String
    let summary: String
    @State private var pulse = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .scaleEffect(pulse ? 1.0 : 0.45)
                        .animation(
                            .easeInOut(duration: 0.55)
                            .repeatForever()
                            .delay(Double(index) * 0.14),
                            value: pulse
                        )
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(status)
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                if !summary.isEmpty {
                    Text(summary)
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .onAppear { pulse = true }
    }
}

struct StoppedResponseDivider: View {
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 1)
            
            Text("You stopped this response")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}

struct AILogView: View {
    @ObservedObject var aiManager: AIManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ScrollView {
                    Text(aiManager.debugLogText)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding()
                }
                .background(Color.black)
                
                HStack {
                    ShareLink(item: aiManager.debugLogText) {
                        Label("Share log", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        UIPasteboard.general.string = aiManager.debugLogText
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button("Clear") {
                        aiManager.clearDebugLog()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("AI Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ready") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ArchivedResponsesView: View {
    @Binding var archivedAnswers: [ArchivedAnswer]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if archivedAnswers.isEmpty {
                    Text("No archived answers yet.")
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                } else {
                    ForEach(archivedAnswers) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Question")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)
                                Spacer()
                                Text(item.createdAt.formatted(date: .numeric, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(item.prompt)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Answer")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                            
                            Text(item.answer)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            
                            HStack {
                                Button {
                                    UIPasteboard.general.string = item.prompt
                                } label: {
                                    Label("Copy question", systemImage: "doc.on.doc")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = item.answer
                                } label: {
                                    Label("Copy answer", systemImage: "doc.on.doc")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color(white: 0.08))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Archived Answers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ready") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct WebResultsSheet: View {
    let results: [WebSearchResult]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            List {
                if results.isEmpty {
                    Text("No online results available.")
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                } else {
                    ForEach(results) { result in
                        Button {
                            if let url = URL(string: result.url) {
                                openURL(url)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .center, spacing: 10) {
                                    AsyncImage(url: URL(string: result.faviconURL)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        Image(systemName: "globe")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 18, height: 18)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    
                                    Text(domainName(from: result.url))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                
                                Text(result.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(result.snippet)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ready") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func domainName(from urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return "Website" }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}

// MARK: - Chat Bubble Styling
struct ChatBubble: View {
    let message: ChatMessage
    let onCopy: () -> Void
    let onRetry: (() -> Void)?
    let onEdit: (() -> Void)?
    let webSources: [WebSearchResult]
    
    init(
        message: ChatMessage,
        onCopy: @escaping () -> Void,
        onRetry: (() -> Void)?,
        onEdit: (() -> Void)?,
        webSources: [WebSearchResult] = []
    ) {
        self.message = message
        self.onCopy = onCopy
        self.onRetry = onRetry
        self.onEdit = onEdit
        self.webSources = webSources
    }
    
    @State private var isShowingWebSources = false
    
    var body: some View {
        HStack(alignment: .top) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(message.text)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.white)
                        .font(.body)
                        .frame(maxWidth: 280, alignment: .trailing)
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 6)
                    
                    HStack(spacing: 10) {
                        Button {
                            onCopy()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        
                        if let onEdit {
                            Button {
                                onEdit()
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(.init(message.text))
                        .foregroundColor(.white)
                        .font(.body)
                        .padding(.vertical, 4)
                        .padding(.trailing, 30)
                    
                    HStack(spacing: 10) {
                        Button {
                            onCopy()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        
                        if let onRetry {
                            Button {
                                onRetry()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if !webSources.isEmpty {
                        Button {
                            isShowingWebSources = true
                        } label: {
                            HStack(spacing: 8) {
                                ForEach(webSources.prefix(3)) { source in
                                    AsyncImage(url: URL(string: source.faviconURL)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        Image(systemName: "globe")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 16, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                Text("Sites")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $isShowingWebSources) {
                            WebResultsSheet(results: webSources)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}
