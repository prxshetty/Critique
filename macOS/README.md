# Critique for macOS

> System-wide AI writing superpowers — **native Swift**, **privacy-first**, and **insanely fast** on Apple Silicon.

[Back to root README](../README.md)

---

## The Critique Experience

Critique for macOS is a premium, native port designed to feel like a first-party part of your Mac.

### Highlights
- **Apple Intelligence Integration**: Native support for Apple's local writing tools and models (macOS 15.1+ and future versions).
- **UI Customization**: Personalized experience with support for custom **Accent Colors** and multiple **Display Styles** (Icon only, Text only, or Both).
- **Truly Native**: Built in Swift/SwiftUI. Uses **~0% CPU** when idle and remains responsive even under load.
- **Horizontal Toolbar**: A modern, floating "pill" interface that stays out of your way until you need it.
- **Purely Focused**: We've stripped out generic chatbot features to focus on what matters: **surgical text transformation**. No distractions, just powerful writing tools.
- **Local LLMs with MLX**: Run state-of-the-art models **fully on-device** on Apple Silicon. No cloud required.
- **Rich Text Aware**: Proofread preserves **RTF formatting** (bold, italics, lists, links) so your documents stay styled.
- **Actively Maintained**: Regularly updated with UI refinements, performance tweaks, and support for the latest Apple Intelligence APIs.

---

## Quick Start

1. **Download** the latest .dmg from [Releases](https://github.com/prxshetty/Critique/releases).
2. **Install** by dragging **Critique.app** into your Applications folder.
3. **Grant Permissions**: macOS will prompt for **Accessibility** (required to read/replace text) and **Screen Recording** (optional).
4. **Choose a Provider**: Set up Apple Intelligence, MLX (native local), Ollama, or a cloud provider (OpenAI, Gemini, Anthropic) in Settings.
5. **Hotkey**: The default is Cmd + Space (or your choice). Select text and invoke Critique to transform your writing.

---

## Differentiators

- **The Toolbar**: Unlike bulky windows, our horizontal toolbar floats elegantly over your workspace.
- **Provider Flexibility**: Mix and match. Use Apple Intelligence or MLX for privacy-sensitive tasks and cloud models for complex research.
- **Custom UI**: Make Critique your own with customizable themes and layouts that match your macOS accent color.
- **Custom Workflows**: Add your own prompts and assign them unique shortcuts in the **Command Editor**.

---

## Contributing

Critique is built for the community. If you'd like to contribute, please check our [**todo.md**](../todo.md) for a list of features, bugs, and improvements we're working on.

---

## System Requirements

- **macOS 14.0 or later** (macOS 15.1+ recommended for Apple Intelligence features).
- **Apple Silicon** recommended for MLX local models (runs on-device for privacy and speed).  
- For development: **Xcode 16+**.

---
## Links & Resources

- [**Development & Troubleshooting**](DEVELOPMENT.md) (Build from source, fix hotkeys)
- [**Contributors**](../CONTRIBUTORS.md)
- [**Media Coverage**](../Media%20Coverage.md)

---

## Privacy

- Everything is stored locally on your device.
- API keys are secured in the macOS Keychain.
- Use **Apple Intelligence** or **MLX** for 100% on-device processing with no network usage.

---
*Distributed under the GNU GPL v3.*
