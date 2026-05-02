import SwiftUI
import Observation

@Observable
@MainActor
final class ToolbarViewModel {
    var customText: String = ""
    var isToolbarProcessing: Bool = false {
        didSet { refreshProcessingState() }
    }
    var selectedCommandID: UUID? = nil
    var executionTask: Task<Void, Never>? = nil
    var inlineResponseViewModel: ResponseViewModel? = nil {
        didSet { refreshProcessingState() }
    }
    
    var isProcessing: Bool = false
    
    /// Updates the local processing state by checking both toolbar tasks 
    /// and the active response's state.
    func refreshProcessingState() {
        isProcessing = isToolbarProcessing || (inlineResponseViewModel?.isProcessing ?? false)
    }
    
    /// Transient runtime value: exact height of the inline response content,
    /// measured by InlineResponseView and used by PopupWindow to size itself.
    var inlineResponseHeight: CGFloat = 0
    
    func reset() {
        customText = ""
        isToolbarProcessing = false
        selectedCommandID = nil
        executionTask?.cancel()
        executionTask = nil
        inlineResponseViewModel?.cancelOngoingTasks()
        inlineResponseViewModel = nil
        inlineResponseHeight = 0
    }
}
