import SwiftUI

struct ResponseSettingsPane: View {
    @Bindable var settings = AppSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 24) {
                    // Window Behavior Section
                    GridRow(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Open in Window:")
                                .foregroundStyle(.secondary)
                            Text("Response Style")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Built-in Commands", isOn: $settings.openBuiltInCommandsInResponseView)
                            Toggle("My Custom Commands", isOn: $settings.openCustomCommandsInResponseView)
                            Toggle("Manual Input (Ask Critique)", isOn: $settings.openManualInstructionsInResponseView)
                            
                            Text("Opens the AI's response in a new window instead of replacing your selected text directly.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 320, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }

                    // Generation Section
                    GridRow(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Generation:")
                                .foregroundStyle(.secondary)
                            Text("AI Engine")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Stream responses", isOn: $settings.useStreamingResponse)
                            Toggle("Show multiple iterations (Max 3)", isOn: $settings.useMultiIteration)
                            
                            Text("Generates three variations in parallel. This will always open a window so you can choose the best output.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 320, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }

                    // Interactions Section
                    GridRow(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Interactions:")
                                .foregroundStyle(.secondary)
                            Text("Keyboard")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Enter to Accept Response", isOn: $settings.enterToAcceptInlineResponse)
                            
                            Text("Allows you to press Enter to instantly replace the selected text with the AI response.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 320, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .toggleStyle(.checkbox)
    }
}