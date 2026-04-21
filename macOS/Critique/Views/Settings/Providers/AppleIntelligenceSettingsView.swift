import SwiftUI
import FoundationModels

struct AppleIntelligenceSettingsView: View {
    @Bindable var settings: AppSettings
    
    enum Status {
        case available
        case unavailable(Reason)
    }
    
    enum Reason {
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case unknown
    }
    
    @State private var availability: Status = .available
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            // Availability Configuration
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Status:")
                        .foregroundStyle(.secondary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        
                        Text(statusText)
                            .foregroundStyle(.primary)
                            .fontWeight(.medium)
                        
                        if case .unavailable(let reason) = availability, reason == .modelNotReady {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                    
                    if case .unavailable(let reason) = availability {
                        Text(reasonDescription(for: reason))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 250, alignment: .leading)
                        
                        if reason == .appleIntelligenceNotEnabled {
                            Button("Open System Settings") {
                                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Apple-Intelligence-Settings")!)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            refreshAvailability()
        }
    }
    
    private var statusText: String {
        switch availability {
        case .available:
            return "Ready"
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return "Not Compatible"
            case .appleIntelligenceNotEnabled: return "Disabled"
            case .modelNotReady: return "Preparing..."
            case .unknown: return "Unavailable"
            }
        }
    }
    
    private var statusIcon: String {
        switch availability {
        case .available:
            return "checkmark.circle.fill"
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return "xmark.octagon.fill"
            case .appleIntelligenceNotEnabled: return "minus.circle.fill"
            case .modelNotReady: return "clock.fill"
            case .unknown: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    private var statusColor: Color {
        switch availability {
        case .available: return .green
        case .unavailable(let reason):
            return reason == .modelNotReady ? .orange : .red
        }
    }
    
    private func reasonDescription(for reason: Reason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "This Mac does not support Apple Intelligence. An Apple Silicon (M1 or later) chip is required."
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is currently disabled in System Settings."
        case .modelNotReady:
            return "The model is still being prepared by macOS. This may take a few minutes."
        case .unknown:
            return "An unknown error occurred while checking Apple Intelligence availability."
        }
    }
    
    private func refreshAvailability() {
        if #available(macOS 26.0, *) {
            let modelAvailability = SystemLanguageModel.default.availability
            switch modelAvailability {
            case .available:
                availability = .available
            case .unavailable(let reason):
                switch reason {
                case .deviceNotEligible:
                    availability = .unavailable(.deviceNotEligible)
                case .appleIntelligenceNotEnabled:
                    availability = .unavailable(.appleIntelligenceNotEnabled)
                case .modelNotReady:
                    availability = .unavailable(.modelNotReady)
                @unknown default:
                    availability = .unavailable(.unknown)
                }
            }
        } else {
            availability = .unavailable(.deviceNotEligible)
        }
    }
}

