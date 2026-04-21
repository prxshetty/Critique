import Foundation
import FoundationModels
import Observation

@available(macOS 26.0, *)
@Generable
struct StructuredAssistantResponse {
    @Guide(description: "The final generated text content. Adhere strictly to the rules and output format specified in the instructions.")
    let outputContent: String
}

@MainActor
class AppleIntelligenceProvider: AIProvider {
    var isProcessing: Bool = false
    
    func processText(systemPrompt: String?, userPrompt: String, images: [Data], streaming: Bool) async throws -> String {
        if #available(macOS 26.0, *) {
            let model = SystemLanguageModel.default
            guard case .available = model.availability else {
                throw NSError(domain: "AppleIntelligence", code: -2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is currently unavailable. Please check your system settings."])
            }
            
            isProcessing = true
            defer { isProcessing = false }
            
            // Use instructions for the system prompt and structured output for the result
            let session = LanguageModelSession(instructions: systemPrompt ?? "You are a helpful assistant.")
            let response = try await session.respond(to: userPrompt, generating: StructuredAssistantResponse.self)
            
            return response.content.outputContent
        } else {
            throw NSError(domain: "AppleIntelligence", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence requires macOS 15.4 or later."])
        }
    }
    
    func processTextStreaming(
        systemPrompt: String?,
        userPrompt: String,
        images: [Data],
        onChunk: @escaping @Sendable @MainActor (String) -> Void
    ) async throws {
        if #available(macOS 26.0, *) {
            let model = SystemLanguageModel.default
            guard case .available = model.availability else {
                throw NSError(domain: "AppleIntelligence", code: -2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is currently unavailable. Please check your system settings."])
            }
            
            isProcessing = true
            defer { isProcessing = false }
            
            // For streaming, we still use raw text. We append a reminder to follow the system instructions strictly.
            let explicitInstructions = (systemPrompt ?? "") + "\n\nIMPORTANT: Output only the requested content according to the instructions above."
            
            let session = LanguageModelSession(instructions: explicitInstructions)
            let stream = session.streamResponse(to: userPrompt)
            
            var fullContent = ""
            for try await snapshot in stream {
                let content = snapshot.content
                if content.count > fullContent.count {
                    let delta = String(content.suffix(content.count - fullContent.count))
                    fullContent = content
                    onChunk(delta)
                }
            }
        } else {
            throw NSError(domain: "AppleIntelligence", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence requires macOS 15.4 or later."])
        }
    }
    
    func cancel() {
        // Task-based cancellation is handled automatically by the caller
    }
}
