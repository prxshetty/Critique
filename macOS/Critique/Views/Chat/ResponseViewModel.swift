import SwiftUI
import Observation
import AppKit

@Observable
@MainActor
final class ResponseViewModel {
    var messages: [ChatMessage] = []
    var fontSize: CGFloat = 13 // Default font size
    var isProcessing: Bool = false
    var showCopyConfirmation: Bool = false    
    var iterations: [String] = []
    var selectedIterationIndex: Int = 0
    
    private let selectedText: String
    private let option: WritingOption?
    private let provider: any AIProvider
    let systemPrompt: String
    let userPrompt: String
    let images: [Data]
    private let continuationSystemPrompt: String?
    
    private var currentTask: Task<Void, Never>?

    // Initializer 1: For existing content
    init(
        content: String,
        selectedText: String,
        option: WritingOption? = nil,
        provider: any AIProvider,
        continuationSystemPrompt: String? = nil
    ) {
        self.selectedText = selectedText
        self.option = option
        self.provider = provider
        self.systemPrompt = ""
        self.userPrompt = ""
        self.images = []
        self.continuationSystemPrompt = continuationSystemPrompt
        
        // Add the initial message
        self.messages = [ChatMessage(role: "assistant", content: content)]
    }

    // Initializer 2: For starting a new streaming request
    init(
        selectedText: String,
        option: WritingOption? = nil,
        provider: any AIProvider,
        systemPrompt: String,
        userPrompt: String,
        images: [Data],
        continuationSystemPrompt: String? = nil
    ) {
        self.selectedText = selectedText
        self.option = option
        self.provider = provider
        self.systemPrompt = systemPrompt
        self.userPrompt = userPrompt
        self.images = images
        self.continuationSystemPrompt = continuationSystemPrompt
        
        // Start processing immediately
        self.startInitialRequest(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            images: images
        )
    }

    private func startInitialRequest(systemPrompt: String, userPrompt: String, images: [Data]) {
        isProcessing = true
        
        // Use a single placeholder for both paths
        let placeholder = ChatMessage(role: "assistant", content: "", isStreaming: true)
        messages.append(placeholder)

        let settings = AppSettings.shared
        currentTask = Task {
            do {
                if settings.useMultiIteration {
                    try await withThrowingTaskGroup(of: String.self) { group in
                        for _ in 0..<3 {
                            group.addTask {
                                try await self.provider.processText(
                                    systemPrompt: systemPrompt,
                                    userPrompt: userPrompt,
                                    images: images,
                                    streaming: false
                                )
                            }
                        }
                        
                        for try await result in group {
                            self.iterations.append(result)
                            
                            // Show the first one immediately as it arrives
                            if self.iterations.count == 1 {
                                if let index = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                                    self.messages[index].content = result
                                    self.messages[index].isStreaming = false
                                    self.selectedIterationIndex = 0
                                }
                            }
                        }
                    }
                } else if settings.useStreamingResponse {
                    try await provider.processTextStreaming(
                        systemPrompt: systemPrompt,
                        userPrompt: userPrompt,
                        images: images,
                        onChunk: { [weak self] chunk in
                            guard let self = self, !Task.isCancelled else { return }
                            if let index = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                                self.messages[index].content += chunk
                            }
                        }
                    )
                    
                    if let index = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                        self.messages[index].isStreaming = false
                        let content = self.messages[index].content
                        if !content.isEmpty {
                            self.iterations = [content]
                        }
                    }
                } else {
                    let result = try await provider.processText(
                        systemPrompt: systemPrompt,
                        userPrompt: userPrompt,
                        images: images,
                        streaming: false
                    )
                    
                    if let index = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                        self.messages[index].content = result
                        self.messages[index].isStreaming = false
                        self.iterations = [result]
                        self.selectedIterationIndex = 0
                    }
                }
            } catch {
                if let index = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                    self.messages[index].content += "\n\nError: \(error.localizedDescription)"
                    self.messages[index].isStreaming = false
                }
            }
            isProcessing = false
        }
    }

    func copyContent() {
        // Copy only the assistant messages
        let allAssistantContent = messages
            .filter { $0.role == "assistant" }
            .map { $0.content }
            .joined(separator: "\n\n")
        
        if allAssistantContent.isEmpty { return }
        
        let pb = NSPasteboard.general
        pb.prepareForNewContents(with: [])
        pb.writeObjects([allAssistantContent as NSString])
        
        showCopyConfirmation = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            showCopyConfirmation = false
        }
    }

    func startFollowUpQuestion(
        _ question: String,
        onCompletion: @escaping () -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        guard !isProcessing else { return }
        
        isProcessing = true
        
        // Add user question
        messages.append(ChatMessage(role: "user", content: question))
        
        // Add empty assistant response
        let streamingMessage = ChatMessage(role: "assistant", content: "", isStreaming: true)
        messages.append(streamingMessage)
        
        currentTask = Task {
            defer {
                isProcessing = false
                onCompletion()
            }
            
            do {
                // Construct conversation history for follow-up
                let history = messages.filter { $0.id != streamingMessage.id }
                    .map { "\($0.role == "user" ? "User" : "Assistant"): \($0.content)" }
                    .joined(separator: "\n\n")
                
                let followUpPrompt = """
                Previous Conversation:
                \(history)
                
                New Question:
                \(question)
                """
                
                try await provider.processTextStreaming(
                    systemPrompt: continuationSystemPrompt,
                    userPrompt: followUpPrompt,
                    images: [],
                    onChunk: { [weak self] chunk in
                        guard let self = self, !Task.isCancelled else { return }
                        if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                            self.messages[index].content += chunk
                        }
                    }
                )
                
                if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                    self.messages[index].isStreaming = false
                }
            } catch {
                onFailure(error.localizedDescription)
                if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                    self.messages.remove(at: index)
                }
            }
        }
    }

    func cancelOngoingTasks() {
        currentTask?.cancel()
        provider.cancel()
        isProcessing = false
    }

    func selectIteration(index: Int) {
        guard iterations.indices.contains(index) else { return }
        selectedIterationIndex = index
        
        let content = iterations[index]
        if let msgIndex = messages.lastIndex(where: { $0.role == "assistant" }) {
            messages[msgIndex].content = content
        }
    }
}
