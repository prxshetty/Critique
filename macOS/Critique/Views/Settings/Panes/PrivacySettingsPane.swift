//
//  PrivacySettingsPane.swift
//  Critique
//
//  Created by Antigravity on 19.04.26.
//

import SwiftUI
import ApplicationServices

struct PrivacySettingsPane<SaveButton: View>: View {
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    var showOnlyApiSetup: Bool
    let saveButton: SaveButton
    
    @State private var isAccessibilityGranted = AXIsProcessTrusted()
    @State private var isScreenRecordingGranted = PermissionsHelper.checkScreenRecording()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Settings Form
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
                    // Accessibility
                    GridRow(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Accessibility:")
                                .foregroundStyle(.secondary)
                            Text("Required")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                
                                Button(isAccessibilityGranted ? "Granted" : "Request Access") {
                                    PermissionsHelper.requestAccessibility()
                                    refreshStatuses()
                                }
                                .buttonStyle(.bordered)
                                .disabled(isAccessibilityGranted)
                            }
                            
                            Text("Required to simulate ⌘C/⌘V for copying your selection and pasting results back into the original app.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 320, alignment: .leading)
                        }
                    }
                                     // Screenshot OCR Toggle
                    GridRow(alignment: .top) {
                        Text("OCR Features:")
                            .gridColumnAlignment(.trailing)
                            .frame(width: 110, alignment: .trailing)
                            .padding(.top, 4)
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Enable Screenshot OCR", isOn: $settings.wantsScreenshotOCR)
                                .toggleStyle(.checkbox)
                                .onChange(of: settings.wantsScreenshotOCR) {
                                    needsSaving = true
                                }
                            
                            Text("Allows you to run OCR on screenshot snippets. Requires Screen Recording permission.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 320, alignment: .leading)
                        }
                    }
                    
                    if settings.wantsScreenshotOCR {
                        Divider()
                            .gridCellColumns(2)
                            .padding(.vertical, 8)
                        
                        // Screen Recording
                        GridRow(alignment: .top) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Screen Recording:")
                                    .foregroundStyle(.secondary)
                                Text("Optional")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .gridColumnAlignment(.trailing)
                            .frame(width: 110, alignment: .trailing)
                            .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    
                                    
                                    Button(isScreenRecordingGranted ? "Granted" : "Request Access") {
                                        PermissionsHelper.requestScreenRecording { granted in
                                            isScreenRecordingGranted = granted
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(isScreenRecordingGranted)
                                }
                                
                                Text("Critique does not record your screen; it only captures the area you explicitly select for OCR.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: 320, alignment: .leading)
                            }
                        }
                    }
                    // Refresh Status
                    GridRow(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Permissions:")
                                .foregroundStyle(.secondary)
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 110, alignment: .trailing)
                        .padding(.top, 4)
                        
                        Button("Refresh Status") {
                            refreshStatuses()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        }
        .onAppear {
            refreshStatuses()
        }
    } 
    
    private func refreshStatuses() {
        isAccessibilityGranted = AXIsProcessTrusted()
        isScreenRecordingGranted = PermissionsHelper.checkScreenRecording()
    }
}

private struct BulletPoint: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}

#Preview {
    PrivacySettingsPane(needsSaving: .constant(false), showOnlyApiSetup: false, saveButton: EmptyView())
}
