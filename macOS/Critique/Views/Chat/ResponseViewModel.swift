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
    
    private let selectedText: String
    private let option: WritingOption?
    private let provider: any AIProvider
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
        
        // Add an empty streaming message
        let streamingMessage = ChatMessage(role: "assistant", content: "", isStreaming: true)
        messages.append(streamingMessage)
        
        currentTask = Task {
            do {
                try await provider.processTextStreaming(
                    systemPrompt: systemPrompt,
                    userPrompt: userPrompt,
                    images: images,
                    onChunk: { [weak self] chunk in
                        guard let self = self, !Task.isCancelled else { return }
                        if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                            self.messages[index].content += chunk
                        }
                    }
                )
                
                // Finalize streaming
                if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                    self.messages[index].isStreaming = false
                }
            } catch {
                if let index = self.messages.firstIndex(where: { $0.id == streamingMessage.id }) {
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
}
