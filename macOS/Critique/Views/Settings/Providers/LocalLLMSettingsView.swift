import SwiftUI
import Observation

struct LocalLLMSettingsView: View {
    @Bindable var llmProvider: LocalModelProvider
    @Bindable private var settings = AppSettings.shared

    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false

    init(provider: LocalModelProvider) {
        _llmProvider = Bindable(wrappedValue: provider)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !llmProvider.isPlatformSupported {
                platformNotSupportedView
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isHeader)
            } else {
                supportedPlatformView
                    .accessibilityElement(children: .contain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // --- Delete Alert ---
        .alert("Delete Model", isPresented: $showingDeleteAlert, presenting: llmProvider.selectedModelType) { modelType in
            Button("Cancel", role: .cancel) { }
            Button("Delete") {
                Task {
                    do {
                        try await llmProvider.deleteModel()
                    } catch {
                        llmProvider.lastError = "Failed to delete \(modelType.displayName): \(error.localizedDescription)"
                    }
                }
            }
        } message: { modelType in
            Text("Are you sure ?")
        }
        // --- General Error Alert ---
        .alert("Local LLM Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { llmProvider.lastError = nil }
        } message: {
            Text(llmProvider.lastError ?? "An unknown error occurred.")
        }
        .onChange(of: llmProvider.lastError) { _, newValue in
            // Show the alert if a new error is set by the provider
            if newValue != nil {
                showingErrorAlert = true
            }
        }
    }
    
    private var platformNotSupportedView: some View {
        GroupBox {
            VStack(alignment: .center, spacing: 12) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
                
                Text("Apple Silicon Required")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Local LLM processing is only available on Apple Silicon (M-series) devices. Please select a different AI Provider.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var supportedPlatformView: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            // Model Selection
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Model:")
                        .foregroundStyle(.secondary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 4) {
                    Picker("", selection: $settings.selectedLocalLLMId) {
                        Text("None Selected").tag(String?.none)
                        ForEach(LocalModelType.allCases) { modelType in
                            Text(modelType.displayName)
                                .tag(String?.some(modelType.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 250, alignment: .leading)
                    .help("Select a local model. Vision-capable models can process images.")
                    
                    if let selectedModel = llmProvider.selectedModelType {
                        Text(selectedModel.isVisionModel ? "This model is vision-capable." : "Text-only model.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 250, alignment: .leading)
                    }
                }
                .frame(width: 250, alignment: .leading)
            }

            // Status Display
            if let selectedModelType = llmProvider.selectedModelType {
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Status:")
                            .foregroundStyle(.secondary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)

                    VStack(alignment: .leading, spacing: 8) {
                        modelActionView(for: selectedModelType)

                        if let error = llmProvider.lastError {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Error: \(error)")
                        }
                    }
                    .frame(width: 250, alignment: .leading)
                }
            }

            // Advanced Directory Settings
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Advanced:")
                        .foregroundStyle(.secondary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 8) {
                    Button("Open Models Directory") {
                        llmProvider.revealModelsFolder()
                    }
                    .buttonStyle(.bordered)
                    .help("Open the folder where local models are stored.")
                    
                    Text("Manage your downloaded models in Finder.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func modelActionView(for modelType: LocalModelType) -> some View {
        switch llmProvider.loadState {
        case .idle, .checking:
            HStack(spacing: 8) {
                ProgressView().controlSize(.small)
                Text("Checking status...")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Checking model status")

        case .needsDownload:
            if !llmProvider.isDownloading {
                HStack(spacing: 8) {
                    Button("Download Model") {
                        llmProvider.startDownload()
                    }
                    .buttonStyle(.borderedProminent)
                    .help("Download the selected model for offline use.")

                    if llmProvider.lastError != nil && llmProvider.retryCount < 3 {
                        Button("Retry Download") {
                            llmProvider.retryDownload()
                        }
                        .buttonStyle(.bordered)
                        .help("Try downloading again if the previous attempt failed.")
                    }
                }
            }

        case .downloaded, .loaded:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Ready")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Delete Model") {
                        showingDeleteAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .help("Remove the downloaded model from disk.")
                    .disabled(llmProvider.isDownloading || llmProvider.running)
                }
            }

        case .loading:
            HStack(spacing: 8) {
                ProgressView().controlSize(.small)
                Text("Loading...")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Loading model")

        case .error:
            if llmProvider.lastError?.contains("download") == true && llmProvider.retryCount < 3 {
                Button("Retry Download") {
                    llmProvider.retryDownload()
                }
                .disabled(llmProvider.isDownloading)
                .buttonStyle(.bordered)
                .help("Try downloading again if the previous attempt failed.")
            } else {
                Text("Cannot proceed due to error.")
                    .foregroundStyle(.red)
            }
        }

        if llmProvider.isDownloading {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Downloading...")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: { llmProvider.cancelDownload() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .accessibilityLabel("Cancel download")
                    }
                    .buttonStyle(.plain)
                    .help("Cancel the current download.")
                }
                ProgressView(value: llmProvider.downloadProgress) {
                    Text("\(Int(llmProvider.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .animation(.linear, value: llmProvider.downloadProgress)
                .accessibilityLabel("Download progress")
            }
        }
    }
}
