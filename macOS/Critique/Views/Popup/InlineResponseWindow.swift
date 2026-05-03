import SwiftUI
import AppKit

class InlineResponseWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 305, height: 100),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        self.isReleasedWhenClosed = false
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.level = .popUpMenu
        // Allow the panel to become key so SwiftUI buttons (e.g. iteration dots) work
        self.isMovable = false
    }
    
    // Keep canBecomeKey false so PopupWindow stays the key window at all times.
    // This ensures ESC and click-outside dismiss still work correctly.
    // Button interactivity is handled via acceptsFirstMouse on InlineResponseHostingView.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func updatePosition(relativeTo toolbarFrame: NSRect, contentHeight: CGFloat) {
        var newFrame = self.frame
        newFrame.size.width = toolbarFrame.width
        newFrame.size.height = contentHeight
        newFrame.origin.x = toolbarFrame.origin.x
        newFrame.origin.y = toolbarFrame.maxY + 8
        self.setFrame(newFrame, display: true, animate: false)
    }
}

/// A hosting view that accepts first mouse so that SwiftUI buttons
/// inside a non-activating NSPanel can still receive click events.
class InlineResponseHostingView<Content: View>: NSHostingView<Content> {
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}