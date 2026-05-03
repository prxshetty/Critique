import SwiftUI

class PopupWindow: NSWindow {
  private var didInitialPositioning = false
  private var initialLocation: NSPoint?
  private var retainedHostingView: NSHostingView<PopupWindowContentView>?
  private var trackingArea: NSTrackingArea?
  private let appState: AppState
  private let windowWidth: CGFloat = 305
  var inlineResponseActive: Bool = false
  private var hasCompletedInitialLayout = false
  
  init(appState: AppState) {
    self.appState = appState

    super.init(
      contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: 100),
      styleMask: [.borderless, .fullSizeContentView],
      backing: .buffered,
      defer: true
    )

    self.isReleasedWhenClosed = false

    configureWindow()
    setupTrackingArea()
  }

  private func configureWindow() {
    backgroundColor = .clear
    isOpaque = false
    level = .floating
    collectionBehavior = [.transient, .ignoresCycle]
    hasShadow = false

    let closeAction: () -> Void = { [weak self] in
      // Use WindowManager to dismiss so both the toolbar and the
      // InlineResponseWindow are closed together.
      WindowManager.shared.dismissPopup()
      if let bundleId = self?.appState.previousApplication?.bundleIdentifier {
        NSApp.yieldActivation(toApplicationWithBundleIdentifier: bundleId)
      }
      self?.appState.previousApplication?.activate(from: .current)
    }
    
    // Use a wrapper view that observes changes and triggers window size updates
    let contentView = PopupWindowContentView(
      appState: appState,
      closeAction: closeAction,
      onSizeChange: { [weak self] in
        self?.updateWindowSize()
      }
    )

    let hostingView = FirstResponderHostingView(rootView: contentView)
    hostingView.layer?.backgroundColor = .clear
    hostingView.wantsLayer = true
    hostingView.layer?.cornerRadius = 20
    hostingView.layer?.maskedCorners = [
      .layerMinXMinYCorner,
      .layerMaxXMinYCorner,
      .layerMinXMaxYCorner,
      .layerMaxXMaxYCorner,
    ]
    hostingView.layer?.masksToBounds = true

    self.contentView = hostingView
    retainedHostingView = hostingView

    initialFirstResponder = hostingView
    makeFirstResponder(hostingView)
    makeKey()

    updateWindowSize()

    // Register with WindowManager for lifecycle management/cleanup
    WindowManager.shared.registerPopupWindow(self)
  }

  private var isUpdatingWindowSize = false

  @objc private func updateWindowSize() {
    guard !didCleanup else { return }

    // Re-entrancy guard: if called during an active layout pass (e.g., from a
    // SwiftUI onChange during constraint update), defer to the next run loop tick
    // to avoid the "too many constraint passes" crash.
    guard !isUpdatingWindowSize else { return }
    isUpdatingWindowSize = true
    defer { isUpdatingWindowSize = false }

    let pillHeight = DesignSystem.pillHeight
    
    let contentHeight = pillHeight

    guard contentView != nil else { return }

    let animate = hasCompletedInitialLayout
    hasCompletedInitialLayout = true

    if animate {
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.25
        context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // NOTE: Do NOT call setContentSize here — setFrame already sets the size.
        // Calling both in the same animation block causes a cascading constraint
        // invalidation loop that crashes with "too many constraint passes".
        if let screen = self.screen {
          var frame = self.frame
          let bottomEdge = frame.minY
          frame.size.height = contentHeight
          frame.origin.y = bottomEdge

          if frame.maxY > screen.visibleFrame.maxY {
            frame.origin.y = screen.visibleFrame.maxY - frame.height
          }

          self.animator().setFrame(frame, display: true)
        }
      }, completionHandler: { [weak self] in
        self?.setupTrackingArea()
      })
    } else {
      if let screen = self.screen {
        var frame = self.frame
        let bottomEdge = frame.minY
        frame.size.height = contentHeight
        frame.origin.y = bottomEdge

        if frame.maxY > screen.visibleFrame.maxY {
          frame.origin.y = screen.visibleFrame.maxY - frame.height
        }

        setFrame(frame, display: true)
      }
      setupTrackingArea()
    }

    if !didInitialPositioning {
      didInitialPositioning = true
      positionNearMouse()
    }
  }


  private func setupTrackingArea() {
    guard let contentView = contentView else { return }

    if let existing = trackingArea {
      contentView.removeTrackingArea(existing)
    }

    trackingArea = NSTrackingArea(
      rect: contentView.bounds,
      options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved],
      owner: self,
      userInfo: nil
    )

    if let trackingArea = trackingArea {
      contentView.addTrackingArea(trackingArea)
    }
  }

  private var didCleanup = false

  func cleanup() {
    guard !didCleanup else { return }
    didCleanup = true

    if let contentView = contentView, let trackingArea = trackingArea {
      contentView.removeTrackingArea(trackingArea)
      self.trackingArea = nil
    }

    if let hostingView = retainedHostingView {
      hostingView.removeFromSuperview()
      self.retainedHostingView = nil
    }

    self.contentView = nil
  }

  override func close() {
    cleanup()
    super.close()
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  // Mouse Event Handling
  override func mouseDown(with event: NSEvent) {
    initialLocation = event.locationInWindow
  }

  override func mouseDragged(with event: NSEvent) {
    guard
      contentView != nil,
      let initialLocation = initialLocation,
      let screen = screen
    else { return }

    let currentLocation = event.locationInWindow
    let deltaX = currentLocation.x - initialLocation.x
    let deltaY = currentLocation.y - initialLocation.y

    var newOrigin = frame.origin
    newOrigin.x += deltaX
    newOrigin.y += deltaY

    let padding: CGFloat = 20
    let screenFrame = screen.visibleFrame
    newOrigin.x = max(
      screenFrame.minX + padding,
      min(newOrigin.x, screenFrame.maxX - frame.width - padding)
    )
    newOrigin.y = max(
      screenFrame.minY + padding,
      min(newOrigin.y, screenFrame.maxY - frame.height - padding)
    )

    setFrameOrigin(newOrigin)
  }

  override func mouseUp(with event: NSEvent) {
    initialLocation = nil
  }

  // Window Positioning

  func screenAt(point: NSPoint) -> NSScreen? {
    for screen in NSScreen.screens {
      if screen.frame.contains(point) {
        return screen
      }
    }
    return nil
  }

  func positionNearMouse() {
    let mouseLocation = NSEvent.mouseLocation
    guard
      let screen = NSScreen.screens.first(where: {
        $0.frame.contains(mouseLocation)
      }) ?? NSScreen.main
    else { return }

    let padding: CGFloat = 10
    var windowFrame = frame
    windowFrame.size.width = windowWidth

    windowFrame.origin.x = mouseLocation.x - (windowWidth / 2)
    windowFrame.origin.y = mouseLocation.y - windowFrame.height - padding

    windowFrame.origin.x = max(
      screen.visibleFrame.minX + padding,
      min(
        windowFrame.origin.x,
        screen.visibleFrame.maxX - windowWidth - padding
      )
    )

    if windowFrame.minY < screen.visibleFrame.minY {
      windowFrame.origin.y = mouseLocation.y + padding
    }

    setFrame(windowFrame, display: true)
  }

  // Close via ESC Key
  override func keyDown(with event: NSEvent) {
    if event.keyCode == 53 {
      self.close()
    } else {
      super.keyDown(with: event)
    }
  }
}

// Note: Window delegate is managed by WindowManager.
// PopupWindow level is set to .popUpMenu when it becomes key (handled in WindowManager.windowDidBecomeKey).

class FirstResponderHostingView<Content: View>: NSHostingView<Content> {
  override var acceptsFirstResponder: Bool { true }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }
}

// MARK: - SwiftUI Wrapper for Observation

/// A wrapper view that observes state changes using SwiftUI's native observation
/// and triggers window size updates via a callback. This replaces manual
/// observation loops with cleaner SwiftUI patterns.
struct PopupWindowContentView: View {
  @Bindable var appState: AppState
  let closeAction: () -> Void
  let onSizeChange: () -> Void
  
  var body: some View {
    ToolbarView(
      appState: appState,
      closeAction: closeAction
    )
    // Use SwiftUI's native onChange to observe state changes.
    // IMPORTANT: All calls to onSizeChange() are dispatched async to break the
    // synchronous chain. If SwiftUI's onChange fires during an active layout/constraint
    // pass, calling setFrame synchronously causes the "too many constraint passes" crash.
    .onChange(of: appState.commandManager.commands.count) { _, _ in
      DispatchQueue.main.async { onSizeChange() }
    }
    .onChange(of: AppSettings.shared.isInlineResponseActive) { _, _ in
      DispatchQueue.main.async { onSizeChange() }
    }
    .onChange(of: appState.toolbarViewModel.inlineResponseHeight) { _, _ in
      WindowManager.shared.syncResponsePanel()
    }
    .onChange(of: appState.toolbarViewModel.inlineResponseViewModel?.hasContentToDisplay) { _, newValue in
      // This fires the moment the first AI response arrives — the critical trigger
      // to create and position the InlineResponseWindow for the first time.
      if newValue == true {
        WindowManager.shared.syncResponsePanel()
      }
    }
    .onChange(of: appState.toolbarViewModel.inlineResponseViewModel != nil) { _, _ in
      WindowManager.shared.syncResponsePanel()
    }
  }
}
