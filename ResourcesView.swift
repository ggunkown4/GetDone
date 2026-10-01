import SwiftUI

// MARK: - Resources View
struct ResourcesView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var selectedFilter: SourceFilter
    
    // Order stored via AppStorage
    @AppStorage("resourcesOrder") private var resourcesOrderRaw: String = "drive,classroom"
    
    // View Options
    @State private var sortOption: SortOption = .date
    @State private var sortDirection: SortDirection = .descending
    @State private var timeFilter: TimeFilter = .all
    
    // Folder Navigation Status
    @State private var folderHistory: [DriveFile] = []
    @State private var currentFolder: DriveFile? = nil
    
    // LOCAL CACHE: stores files per folderId ("root" for the root folder)
    @State private var folderCache: [String: [DriveFile]] = [:]
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 20)
    ]
    
    private var currentFolderKey: String {
        currentFolder?.id ?? "root"
    }
    
    private var currentFiles: [DriveFile] {
        if let cached = folderCache[currentFolderKey], !cached.isEmpty {
            return cached
        }
        return auth.driveFiles
    }
    
    private var resourcesOrder: [String] {
        let items = resourcesOrderRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let validItems = items.filter { $0 == "drive" || $0 == "classroom" }
        return validItems.isEmpty ? ["drive", "classroom"] : validItems
    }
    
    private var filterDateBoundary: Date? {
        let calendar = Calendar.current
        switch timeFilter {
        case .all: return nil
        case .lastWeek: return calendar.date(byAdding: .day, value: -7, to: Date())
        case .lastMonth: return calendar.date(byAdding: .month, value: -1, to: Date())
        case .lastYear: return calendar.date(byAdding: .year, value: -1, to: Date())
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(resourcesOrder, id: \.self) { sourceKey in
                            if sourceKey == "drive" && (selectedFilter == .all || selectedFilter == .drive) {
                                displayFilesSection
                            }
                            
                            if sourceKey == "classroom" && (selectedFilter == .all || selectedFilter == .classroom) {
                                classroomSectionView
                            }
                        }
                        
                        if selectedFilter == .all && currentFiles.isEmpty && auth.classroomItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("You don't have any resources yet.")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .onChange(of: auth.driveFiles.map(\.id)) { _ in
            if !auth.driveFiles.isEmpty {
                folderCache[currentFolderKey] = auth.driveFiles
            }
        }
        .onChange(of: selectedFilter) { newValue in
            if newValue == .all {
                resetFolderNavigation()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if selectedFilter != .all {
                    Button {
                        withAnimation {
                            selectedFilter = .all
                            resetFolderNavigation()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline.bold())
                            if horizontalSizeClass == .regular {
                                Text("All")
                                    .font(.subheadline.bold())
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Section(header: Text("Sort by")) {
                        Picker("Sort option", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                    Section(header: Text("Order")) {
                        Picker("Direction", selection: $sortDirection) {
                            ForEach(SortDirection.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                    Section(header: Text("Time Filter")) {
                        Picker("Filter", selection: $timeFilter) {
                            ForEach(TimeFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.subheadline.bold())
                        if horizontalSizeClass == .regular {
                            Text("View")
                                .font(.subheadline.bold())
                        }
                    }
                    .foregroundColor(.white)
                }
                
                Menu {
                    Picker("Source", selection: $selectedFilter) {
                        ForEach(SourceFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .font(.subheadline.bold())
                        if horizontalSizeClass == .regular {
                            Text("Source")
                                .font(.subheadline.bold())
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Folder Navigation Functions
    private func navigateToFolder(_ folder: DriveFile) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = .drive 
            if let previous = currentFolder {
                folderHistory.append(previous)
            }
            currentFolder = folder
        }
        
        if folderCache[folder.id] == nil {
            auth.loadFilesForFolder(folderId: folder.id)
        }
    }
    
    private func goBackInFolders() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if !folderHistory.isEmpty {
                currentFolder = folderHistory.removeLast()
            } else {
                currentFolder = nil
            }
        }
        
        if folderCache[currentFolderKey] == nil {
            auth.loadFilesForFolder(folderId: currentFolder?.id)
        }
    }
    
    private func resetFolderNavigation() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentFolder = nil
            folderHistory.removeAll()
        }
        if folderCache["root"] == nil {
            auth.loadFilesForFolder(folderId: nil)
        }
    }
    
    // MARK: - Subview: Drive Files
    @ViewBuilder
    private var displayFilesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let folder = currentFolder {
                    Button(action: goBackInFolders) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                            Text(folderHistory.isEmpty ? "Google Drive" : (folderHistory.last?.name ?? "Previous"))
                                .font(.title3.bold())
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    Text("›").font(.title3.bold()).foregroundColor(.gray)
                    Text(folder.name).font(.title3.bold()).foregroundColor(.white).lineLimit(1)
                    Spacer()
                } else {
                    if selectedFilter == .all {
                        Button {
                            withAnimation { selectedFilter = .drive }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Google Drive").font(.title2.bold()).foregroundColor(.white)
                                Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Google Drive").font(.title2.bold()).foregroundColor(.white)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            
            let filesToShow = currentFiles
            
            if filesToShow.isEmpty && !auth.isLoadingData {
                VStack(spacing: 16) {
                    Image(systemName: "folder").font(.system(size: 50)).foregroundColor(.gray)
                    Text(currentFolder != nil ? "This folder is empty" : "Your Drive is empty").foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                let baseFiles = filesToShow.filter { file in
                    guard let boundary = filterDateBoundary else { return true }
                    return file.date >= boundary 
                }
                
                let sortedFiles = baseFiles.sorted { (file1, file2) -> Bool in
                    let isFolder1 = file1.mimeType == "application/vnd.google-apps.folder"
                    let isFolder2 = file2.mimeType == "application/vnd.google-apps.folder"
                    
                    if isFolder1 != isFolder2 { return isFolder1 }
                    
                    if sortOption == .name {
                        return sortDirection == .ascending ? file1.name < file2.name : file1.name > file2.name
                    } else {
                        return sortDirection == .ascending ? file1.date < file2.date : file1.date > file2.date
                    }
                }
                
                let showFiles = (selectedFilter == .all && currentFolder == nil)
                ? Array(sortedFiles.prefix(6))
                : sortedFiles
                
                if showFiles.isEmpty {
                    Text("No files found with these filters.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                } else {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(showFiles) { file in
                            ResourceIconView(file: file) { selectedFolder in
                                navigateToFolder(selectedFolder)
                            }
                            .onAppear {
                                if selectedFilter == .drive, file.id == showFiles.last?.id {
                                    auth.loadMoreFilesForFolder(folderId: currentFolder?.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if auth.isLoadingMoreFiles {
                        ProgressView("Loading more...")
                            .tint(.white)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }
                }
            }
        }
    }
    
    // MARK: - Subview: Classroom Items
    @ViewBuilder
    private var classroomSectionView: some View {
        if auth.classroomItems.isEmpty {
            if selectedFilter == .classroom {
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap").font(.system(size: 50)).foregroundColor(.gray)
                    Text("No materials or assignments found").foregroundColor(.gray)
                }
                .padding(.top, 40)
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                if selectedFilter == .all {
                    Button {
                        withAnimation { selectedFilter = .classroom }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Google Classroom").font(.title2.bold()).foregroundColor(.white)
                            Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Google Classroom").font(.title2.bold()).foregroundColor(.white).padding(.horizontal, 20)
                }
                
                let baseItems = auth.classroomItems.filter { item in
                    guard let boundary = filterDateBoundary else { return true }
                    return item.date >= boundary
                }
                
                let sortedItems = baseItems.sorted { item1, item2 in
                    if sortOption == .name {
                        return sortDirection == .ascending ? item1.title < item2.title : item1.title > item2.title
                    } else {
                        return sortDirection == .ascending ? item1.date < item2.date : item1.date > item2.date
                    }
                }
                
                let visibleItems = selectedFilter == .all 
                ? Array(sortedItems.prefix(4)) 
                : sortedItems
                
                if visibleItems.isEmpty {
                    Text("No items found with these filters.").foregroundColor(.gray).padding(.horizontal, 20)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(visibleItems) { item in
                            if item.type == .announcement {
                                AnnouncementBarView(item: item)
                                    .onAppear {
                                        if selectedFilter == .classroom, item.id == visibleItems.last?.id {
                                            auth.loadMoreClassroomItems()
                                        }
                                    }
                            } else {
                                ClassroomItemCardView(item: item)
                                    .onAppear {
                                        if selectedFilter == .classroom, item.id == visibleItems.last?.id {
                                            auth.loadMoreClassroomItems()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if auth.isLoadingMoreClassroomItems {
                        ProgressView("Loading more Classroom items...")
                            .tint(.white)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Drive & Classroom Helper Views
struct ResourceIconView: View {
    let file: DriveFile
    var onFolderTap: ((DriveFile) -> Void)? = nil
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            let isFolder = file.mimeType == "application/vnd.google-apps.folder"
            if isFolder {
                onFolderTap?(file)
            } else if let linkString = file.webViewLink, let url = URL(string: linkString) {
                openURL(url)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(backgroundColorForType(file.mimeType))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: iconForType(file.mimeType))
                        .font(.system(size: 36))
                        .foregroundColor(iconColorForType(file.mimeType))
                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                let isFolder = file.mimeType == "application/vnd.google-apps.folder"
                
                VStack(spacing: 2) {
                    Text(file.name)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if !isFolder {
                        Text(file.dateFormatted)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(height: 32, alignment: .top)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func iconForType(_ type: String?) -> String {
        guard let type = type else { return "doc.fill" }
        if type.contains("folder") { return "folder.fill" }
        if type.contains("document") || type.contains("pdf") { return "doc.text.fill" }
        if type.contains("spreadsheet") { return "tablecells.fill" }
        if type.contains("presentation") { return "play.rectangle.fill" }
        if type.contains("image") { return "photo.fill" }
        if type.contains("video") { return "video.fill" }
        if type.contains("audio") { return "waveform" }
        if type.contains("zip") || type.contains("rar") { return "doc.zipper" }
        return "doc.fill"
    }
    
    private func backgroundColorForType(_ type: String?) -> Color {
        guard let type = type else { return Color.white.opacity(0.1) }
        if type.contains("folder") { return Color.blue.opacity(0.2) }
        return Color.white.opacity(0.1)
    }
    
    private func iconColorForType(_ type: String?) -> Color {
        guard let type = type else { return .gray }
        if type.contains("folder") { return .blue }
        if type.contains("document") { return .blue }
        if type.contains("pdf") { return .red }
        if type.contains("spreadsheet") { return .green }
        if type.contains("presentation") { return .orange }
        if type.contains("image") || type.contains("video") { return .purple }
        return .white
    }
}

struct AnnouncementBarView: View {
    let item: ClassroomItem
    @Environment(\.openURL) var openURL
    var body: some View {
        Button { if let url = URL(string: item.url) { openURL(url) } } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(item.subjectName).font(.caption.bold()).foregroundColor(.white).padding(.horizontal, 10).padding(.vertical, 4).background(item.color).clipShape(Capsule())
                    Text("Announcement").font(.caption2.bold()).foregroundColor(item.color)
                    Spacer()
                    Text(item.dateFormatted).font(.caption2).foregroundColor(.gray)
                }
                if let bodyText = item.text, !bodyText.isEmpty {
                    Text(bodyText).font(.subheadline).foregroundColor(.white).multilineTextAlignment(.leading).lineLimit(4)
                }
            }
            .padding(14).background(item.color.opacity(0.12)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(item.color.opacity(0.35), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}

struct ClassroomItemCardView: View {
    let item: ClassroomItem
    @Environment(\.openURL) var openURL
    var body: some View {
        Button { if let url = URL(string: item.url) { openURL(url) } } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(item.color.opacity(0.2)).frame(width: 46, height: 46)
                    Image(systemName: item.type == .assignment ? "doc.text.fill" : "book.fill").font(.title3).foregroundColor(item.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.subjectName).font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 3).background(item.color).clipShape(Capsule())
                        Spacer()
                        Text(item.dateFormatted).font(.caption2).foregroundColor(.gray)
                    }
                    Text(item.title).font(.subheadline.bold()).foregroundColor(.white).lineLimit(2)
                }
            }
            .padding(12).background(Color.white.opacity(0.06)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(item.color.opacity(0.25), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}
