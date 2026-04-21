import SwiftUI
import ApplicationServices
import Observation

private let logger = AppLogger.logger("PopupView")

@MainActor
@Observable
final class PopupViewModel {
  var isEditMode: Bool = false
  var showingClassicGrid: Bool = false
}

struct PopupView: View {
  @Bindable var appState: AppState
  @Bindable var viewModel: PopupViewModel
  @Bindable private var settings = AppSettings.shared
  @Environment(\.colorScheme) var colorScheme

  @State private var customText: String = ""
  @State private var isCustomLoading: Bool = false
  @State private var processingCommandId: UUID? = nil

  @State private var showingCommandsView = false
  @State private var editingCommand: CommandModel? = nil

  // Error handling
  @State private var showingErrorAlert = false
  @State private var errorMessage = ""
  
  // Track in-flight custom instruction task to prevent races
  @State private var customInstructionTask: Task<Void, Never>?
  
  // Focus management for accessibility
  @FocusState private var isTextFieldFocused: Bool

  let closeAction: () -> Void

  // Grid layout for two columns
  private let columns = [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8),
  ]

  var body: some View {
    Group {
      if settings.popupLayout == .toolbar && !viewModel.isEditMode {
        ToolbarView(
          appState: appState,
          closeAction: closeAction,
          moreAction: {
            showingCommandsView = true
          }
        )
      } else {
        classicGridView
      }
    }
    .alert("Error", isPresented: $showingErrorAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage)
    }
    .sheet(item: $editingCommand) { command in
      let binding = Binding(
        get: { command },
        set: { updatedCommand in
          appState.commandManager.updateCommand(updatedCommand)
          editingCommand = nil
        }
      )

      CommandEditor(
        command: binding,
        onSave: {
          editingCommand = nil
        },
        onCancel: {
          editingCommand = nil
        },
        commandManager: appState.commandManager
      )
    }
    .sheet(isPresented: $showingCommandsView) {
      CommandsView(commandManager: appState.commandManager)
    }
    .onChange(of: editingCommand) { _, newValue in
      WindowManager.shared.setPopupDismissSuppressed(
        newValue != nil,
        reason: .commandEditorSheet
      )
    }
    .onChange(of: showingCommandsView) { _, newValue in
      WindowManager.shared.setPopupDismissSuppressed(
        newValue,
        reason: .commandsManagerSheet
      )
    }
  }

  @ViewBuilder
  private var classicGridView: some View {
    VStack(spacing: 16) {
      // Top bar with buttons
      HStack {
        Button(action: {
          if viewModel.isEditMode {
            viewModel.isEditMode = false
          } else if viewModel.showingClassicGrid {
            withAnimation(.spring(duration: 0.3)) {
              viewModel.showingClassicGrid = false
            }
          } else {
            closeAction()
          }
        }) {
          Image(systemName: viewModel.showingClassicGrid && !viewModel.isEditMode ? "chevron.left" : "xmark")
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(width: 28, height: 28)
            .background(Color(.controlBackgroundColor))
            .clipShape(.circle)
        }
        .buttonStyle(.plain)
        .help(viewModel.isEditMode ? "Exit Edit Mode" : (viewModel.showingClassicGrid ? "Back" : "Close"))
        
        Spacer()

        Button(action: {
          viewModel.isEditMode.toggle()
        }) {
          Image(
            systemName: viewModel.isEditMode ? "checkmark" : "square.and.pencil"
          )
          .font(.body)
          .foregroundStyle(.secondary)
          .frame(width: 28, height: 28)
          .background(Color(.controlBackgroundColor))
          .clipShape(.circle)
        }
        .buttonStyle(.plain)
      }
      .padding(.top, 8)
      .padding(.horizontal, 8)

      if !appState.selectedText.isEmpty || !appState.selectedImages.isEmpty {
        commandButtonsGrid
          .padding(.horizontal, 16)
      }

      if viewModel.isEditMode {
        Button(action: { showingCommandsView = true }) {
          HStack {
            Image(systemName: "plus.circle.fill")
            Text("Manage Commands")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color(.controlBackgroundColor))
          .clipShape(.rect(cornerRadius: DesignSystem.buttonCornerRadius))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 8)
    .windowBackground(shape: RoundedRectangle(cornerRadius: 20))
    .overlay(
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(DesignSystem.tokens(for: settings.themeStyle).borderColor(colorScheme), lineWidth: 1.0)
    )
    .clipShape(.rect(cornerRadius: 20))
  }

  // MARK: - Command Buttons Grid

  @ViewBuilder
  private var commandButtonsGrid: some View {
    let grid = LazyVGrid(columns: columns, spacing: 8) {
      ForEach(appState.commandManager.commands) { command in
        CommandButton(
          command: command,
          isEditing: viewModel.isEditMode,
          isLoading: processingCommandId == command.id,
          onTap: {
            processingCommandId = command.id
            Task {
              await processCommandAndCloseWhenDone(command)
            }
          },
          onEdit: {
            editingCommand = command
          },
          onDelete: {
            logger.debug("Deleting command: \(command.name)")
            appState.commandManager.deleteCommand(command)
          }
        )
      }
    }

    if #available(macOS 26, *) {
      GlassEffectContainer(spacing: 0) {
        grid
      }
    } else {
      grid
    }
  }

  private func processCommandAndCloseWhenDone(
    _ command: CommandModel
  ) async {
    defer { processingCommandId = nil }

    do {
      _ = try await CommandExecutionEngine.shared.executeCommand(
        command,
        source: .popup,
        closePopupOnInlineCompletion: closeAction
      )
    } catch let error as CommandExecutionEngineError {
      logger.error("Error processing command: \(error.localizedDescription)")
      errorMessage = error.localizedDescription
      showingErrorAlert = true
    } catch {
      logger.error("Error processing command: \(error.localizedDescription)")
      errorMessage = error.localizedDescription
      showingErrorAlert = true
    }
  }
}

// MARK: - Preview

#Preview("Popup View - Default") {
  @Previewable @State var appState = {
    let state = AppState.shared
    state.selectedText = """
      This is some sample text that has been selected by the user. \
      It could be a paragraph from a document, an email, or any other text \
      that needs to be processed by the AI writing tools.
      """
    return state
  }()
  
  @Previewable @State var viewModel = PopupViewModel()
  
  PopupView(
    appState: appState,
    viewModel: viewModel,
    closeAction: {
      print("Close action triggered")
    }
  )
  .frame(width: 400, height: 500)
}
