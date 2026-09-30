# GetDone App - Vibe Coding Protocol

Hello future Codex session! You are working on "GetDone", a Swift Playgrounds iPad app. 
Instead of testing code locally on this Linux server, you are attached to an autonomous "Vibe Coding" loop that directly interacts with the user's iPad via GitHub Actions and Pushcut.

## The Workflow (How we code here)
1. **The User Prompts:** The user will tell you what feature to add or fix to the iOS app.
2. **You Code:** Write or modify the Swift files located inside `Sources/AppModule/`. (Do NOT use `apply_patch` for large sweeping changes, just write to the files). 
3. **You Push:** Commit the changes and push them to the `main` branch. 
   **CRITICAL MUST-DO:** Because this Codex environment has a restricted network sandbox, you **MUST** use the `require_escalated` parameter in your `exec_command` tool when running `git push`, otherwise the push will silently fail!
4. **The Magic Happens:** GitHub Actions will automatically catch your push, verify it compiles, and trigger a Pushcut webhook. This webhook forces the user's iPad to instantly pull the new code and open it on their screen.
5. **Feedback:** The user will tap "Run" on their iPad and simply tell you about any errors or UI tweaks needed.

## Codebase Rules
- **Structure:** This is an Apple `.swiftpm` package. ALL Swift code belongs in `Sources/AppModule/`. 
- **Dependencies:** Do not alter `Package.swift` unless explicitly adding a new package dependency. The target is properly configured to `Sources/AppModule`.
- **Compilation:** Do NOT try to test-compile SwiftUI code on this Linux server using `swiftc`. It will fail because Linux does not have the UIKit/SwiftUI SDKs. Just write it, push it, and let GitHub Actions/the iPad do the compiling.

## System Context
- Remote Repo: `git@github.com:ggunkown4/GetDone.git`
- SSH: The deploy key is already configured in `~/.ssh/config`.
