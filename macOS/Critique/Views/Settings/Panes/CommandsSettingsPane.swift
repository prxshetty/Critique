//
//  CommandsSettingsPane.swift
//  Critique
//
//  Created by Critique on 19.04.26.
//

import SwiftUI

struct CommandsSettingsPane<SaveButton: View>: View {
    @Bindable var appState: AppState
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    var showOnlyApiSetup: Bool
    let saveButton: SaveButton

    @State private var selectedCommandID: UUID?
    @State private var showingResetAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Master-Detail Command Manager (Safari "Profiles" Style)
            HStack(spacing: 0) {
                // Left Sidebar (Master)
                VStack(spacing: 0) {
                    List(selection: $selectedCommandID) {
                        Section("Built-in") {
                            ForEach(appState.commandManager.builtInCommands) { cmd in
                                CommandSidebarRow(command: cmd)
                                    .tag(cmd.id)
                            }
                        }
                        
                        Section("Custom") {
                            ForEach(appState.commandManager.customCommands) { cmd in
                                CommandSidebarRow(command: cmd)
                                    .tag(cmd.id)
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    .scrollContentBackground(.hidden)
                    .frame(width: 180)
                    
                    Divider()
                    
                    // Action Bar
                    HStack(spacing: 12) {
                        Button {
                            let newCommand = CommandModel(name: "New Command", prompt: "", icon: "pencil")
                            appState.commandManager.addCommand(newCommand)
                            selectedCommandID = newCommand.id
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.plain)
                        .help("Add Custom Command")
                        
                        Button {
                            if let id = selectedCommandID, let cmd = appState.commandManager.commands.first(where: { $0.id == id }), !cmd.isBuiltIn {
                                appState.commandManager.deleteCommand(cmd)
                                selectedCommandID = nil
                            }
                        } label: {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedCommandID == nil || (appState.commandManager.commands.first(where: { $0.id == selectedCommandID })?.isBuiltIn == true))
                        .help("Remove Custom Command")
                        
                        Spacer()
                        
                        Button {
                            showingResetAlert = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .buttonStyle(.plain)
                        .help("Reset Built-in Commands")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(Color.primary.opacity(0.02))
                .frame(width: 180)
                
                Divider()
                
                // Right Detail
                ZStack {
                    Color.primary.opacity(0.01) // slight emphasis on the editor side
                    if let id = selectedCommandID, let binding = binding(for: id) {
                        InlineCommandEditor(command: binding, commandManager: appState.commandManager)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "hand.point.up.left")
                                .font(.largeTitle)
                                .foregroundStyle(.tertiary)
                            Text("Select a command to edit")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert("Reset Built-in Commands", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                appState.commandManager.resetToDefaults()
                selectedCommandID = nil
            }
        } message: {
            Text("This will reset all built-in commands to their original settings, restore any deleted built-in commands, and keep your custom commands. This action cannot be undone.")
        }
    }
    
    private func binding(for id: UUID) -> Binding<CommandModel>? {
        guard let initialCommand = appState.commandManager.commands.first(where: { $0.id == id }) else {
            return nil
        }
        return Binding(
            get: {
                appState.commandManager.commands.first(where: { $0.id == id }) ?? initialCommand
            },
            set: { newValue in
                appState.commandManager.updateCommand(newValue)
            }
        )
    }
}

// Minimal row for the sidebar
struct CommandSidebarRow: View {
    let command: CommandModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: command.icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 16)
            Text(command.name)
        }
        .padding(.vertical, 2)
    }
}
