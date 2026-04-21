//
//  AppearanceSettingsPane.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct AppearanceSettingsPane<SaveButton: View>: View {
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    var showOnlyApiSetup: Bool
    let saveButton: SaveButton

    @State private var sandboxText: String = "Test your theme here!"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
            // Settings Form
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Theme:")
                            .foregroundStyle(.secondary)
                        Text("App appearance")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    
                    Picker("", selection: $settings.themeStyle) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .frame(width: 180, alignment: .leading)
                    .onChange(of: settings.themeStyle) { _, _ in
                        needsSaving = true
                    }
                }
                
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Layout:")
                            .foregroundStyle(.secondary)
                        Text("Interface style")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    
                    Picker("", selection: $settings.popupLayout) {
                        ForEach(PopupLayout.allCases) { layout in
                            Text(layout.localizedName).tag(layout)
                        }
                    }
                    .frame(width: 180, alignment: .leading)
                    .onChange(of: settings.popupLayout) { _, _ in
                        needsSaving = true
                    }
                }
                
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Button Style:")
                            .foregroundStyle(.secondary)
                        Text("Icon/Text")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    
                    Picker("", selection: $settings.commandDisplayStyle) {
                        ForEach(CommandDisplayStyle.allCases) { style in
                            Text(style.localizedName).tag(style)
                        }
                    }
                    .frame(width: 180, alignment: .leading)
                    .onChange(of: settings.commandDisplayStyle) { _, _ in
                        needsSaving = true
                    }
                }
                
                if settings.popupLayout == .toolbar {
                    GridRow {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Default Tone:")
                                .foregroundStyle(.secondary)
                            Text("Initial style")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        
                        Picker("", selection: $settings.primaryTone) {
                            ForEach(WritingOption.allCases) { tone in
                                Text(tone.localizedName).tag(tone)
                            }
                        }
                        .frame(width: 180, alignment: .leading)
                        .onChange(of: settings.primaryTone) { _, _ in
                            needsSaving = true
                        }
                    }
                }

                GridRow(alignment: .top) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Sandbox:")
                            .foregroundStyle(.secondary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Type text here to test...", text: $sandboxText, axis: .vertical)
                            .font(.system(.body, design: .serif))
                            .lineLimit(1...5)
                            .padding(10)
                            .background(Color.primary.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .textFieldStyle(.plain)
                            .frame(width: 320)
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
