//
//  GeneralSettingsPane.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import KeyboardShortcuts
import AppKit

struct GeneralSettingsPane<SaveButton: View>: View {
    @Bindable var appState: AppState
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    var showOnlyApiSetup: Bool
    let saveButton: SaveButton

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
            // Settings Form
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                // Keyboard Shortcut
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Activation:")
                            .foregroundStyle(.secondary)
                        Text("Global Shortcut")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    
                    KeyboardShortcuts.Recorder(
                        for: .showPopup,
                        onChange: { _ in
                            needsSaving = true
                        }
                    )
                }
                
                GridRow {
                    Spacer().gridCellUnsizedAxes(.horizontal)
                    Text("Press this key combination to summon Critique from any application.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 300, alignment: .leading)
                }

                // Restart Onboarding
                GridRow(alignment: .top) {
                    Text("Onboarding:")
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 4)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Restart Onboarding...") {
                            settings.hasCompletedOnboarding = false
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.bordered)
                        
                        Text("This will reset your setup progress and close the app so you can see the welcome screen on next launch.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 300, alignment: .leading)
                    }
                }
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(24)
        }
    }
}