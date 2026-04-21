# Development & Troubleshooting

## Build From Source (macOS)

You can build the Critique macOS app using Xcode 15 or later:

### Option A — Xcode Project
1. git clone https://github.com/prxshetty/Critique.git
2. Navigate to macOS/ and open Critique.xcodeproj.
3. Select the **Writing Tools** target -> **Signing & Capabilities** -> choose your Development Team.
4. Set **Deployment Target** to **macOS 14.0** or higher.
5. Build and Run Cmd+R.

### Option B — Swift Package
1. Open the repo root or the macOS/ folder in Xcode.
2. Let Xcode resolve Swift Packages.
3. Configure **Signing** and **Deployment Target** (macOS 14.0+).
4. Build and Run Cmd+R.

> **Note**: The first debug run will trigger macOS permission prompts for Accessibility and Screen Recording. Accept them and restart the app if necessary.

---

## Compilation (Windows)

Detailed instructions for compiling the Windows application can be found in:
README's Linked Content/To Compile the Application Yourself.md

---

## Troubleshooting

### Hotkey not firing?
- Ensure the shortcut doesn't clash with system defaults (Spotlight, Input Sources).
- Try setting a unique combo like Ctrl + J or Opt + Space.

### Text replacement not working?
- Verify **Accessibility** permissions under System Settings -> Privacy & Security.
- Some apps require **Screen Recording** permissions to allow text capture.

### Local model issues?
- **MLX**: Ensure the model is downloaded and selected in Settings.
- **Ollama**: Verify the server is running (ollama serve) and the model name matches exactly.
