import SwiftUI
import AppKit

struct ToolbarInputField: NSViewRepresentable {
    @Binding var text: String
    let textColor: NSColor
    let cursorColor: NSColor
    let isEditable: Bool
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> PremiumToolbarTextField {
        let textField = PremiumToolbarTextField()
        textField.delegate = context.coordinator
        textField.target = context.coordinator
        textField.action = #selector(Coordinator.submit)
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.bezelStyle = .roundedBezel
        textField.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        textField.lineBreakMode = .byTruncatingTail
        textField.maximumNumberOfLines = 1
        textField.usesSingleLineMode = true
        textField.isAutomaticTextCompletionEnabled = false
        textField.cell?.wraps = false
        return textField
    }

    func updateNSView(_ nsView: PremiumToolbarTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }

        nsView.textColor = textColor
        nsView.insertionPointColor = cursorColor
        nsView.isEditable = isEditable
        nsView.isSelectable = isEditable

        if isEditable {
            nsView.alphaValue = 1
        } else {
            if nsView.window?.firstResponder === nsView.currentEditor() {
                nsView.window?.makeFirstResponder(nil)
            }
            nsView.alphaValue = 0.01
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        let onSubmit: () -> Void

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self._text = text
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }

        @objc func submit() {
            onSubmit()
        }
    }
}

final class PremiumToolbarTextField: NSTextField {
    var insertionPointColor: NSColor = .white {
        didSet { applyInsertionPointColor() }
    }

    override func becomeFirstResponder() -> Bool {
        let becameFirstResponder = super.becomeFirstResponder()
        applyInsertionPointColor()
        return becameFirstResponder
    }

    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        applyInsertionPointColor()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyInsertionPointColor()
    }

    private func applyInsertionPointColor() {
        guard let fieldEditor = self.window?.fieldEditor(true, for: self) as? NSTextView else {
            return
        }
        fieldEditor.insertionPointColor = insertionPointColor
    }
}
