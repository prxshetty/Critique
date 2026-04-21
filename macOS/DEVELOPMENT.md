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

## Distributing (Free Method)

If you don't have a paid Apple Developer account, you can still distribute Critique using the provided `package.sh` script.

### 1. Create the Release Package
Run the following command in the `macOS` directory:

```bash
chmod +x package.sh
./package.sh
```

This will create a **Critique.dmg** on your desktop.

### 2. Guide for your Users
Since the app isn't notarized, users will see a security warning. You should provide these instructions on your website or GitHub release page:

> **How to Open Critique:**
> 1. Download and open the `.dmg`.
> 2. Drag **Critique** into your Applications folder.
> 3. **Right-click** Critique in your Applications folder and select **Open**.
> 4. Click **Open** again on the security prompt. (You only need to do this once!)

---

## Troubleshooting

### `xcodebuild` error in terminal?
If you see an error about `CommandLineTools`, run this to point your terminal to the full version of Xcode:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```
