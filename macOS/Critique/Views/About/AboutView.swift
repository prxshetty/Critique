import SwiftUI

private enum AboutURLs {
    static let emailPranam = URL(string: "mailto:prxshetty@gmail.com")
    static let releases = URL(string: "https://github.com/prxshetty/Critique/releases")
}

struct AboutView: View {
    @Bindable private var settings = AppSettings.shared
    private var updateChecker = UpdateChecker.shared

    private var appVersion: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        if let shortVersion, let buildVersion, shortVersion != buildVersion {
            return "\(shortVersion) (\(buildVersion))"
        }

        return shortVersion ?? buildVersion ?? "Unknown"
    }

    @ViewBuilder
    private func safeLink(_ title: String, destination: URL?) -> some View {
        if let destination {
            Link(title, destination: destination)
                .buttonStyle(.link)
        } else {
            Text(title)
                .foregroundStyle(.secondary)
                .help("Link unavailable")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Branding Header
            VStack(spacing: 8) {
                Image("MenuBarIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 84, height: 84)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 8)
                
                Text("Critique")
                    .font(.title)
                    .bold()
                
                Text("Native, privacy-first AI writing superpower")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Version \(appVersion)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Updates Section
            VStack(spacing: 16) {
                Group {
                    if updateChecker.isCheckingForUpdates {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Checking for updates...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if let error = updateChecker.checkError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else if updateChecker.updateAvailable {
                        Text("Update available!")
                            .font(.caption)
                            .bold()
                    } else if updateChecker.hasCheckedForUpdates {
                        Text("Critique is up to date")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                .frame(height: 10)
                
                Button(action: {
                    if updateChecker.updateAvailable {
                        updateChecker.openReleasesPage()
                    } else {
                        Task { await updateChecker.checkForUpdates() }
                    }
                }) {
                    Text(updateChecker.updateAvailable ? "Download" : "Check for Updates")
                        .frame(minWidth: 140)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            .padding(.bottom, 48)
            
            // Footer
            Text("~ Pranam")
                .font(.system(size: 10, weight: .light, design: .monospaced))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 16)
        }
        .frame(width: 380, height: 420)
        .windowBackground(theme: .standard, shape: Rectangle())
    }
}
