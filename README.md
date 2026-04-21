<div align="center">
  <img src="docs/logo.png" width="200" height="200" alt="Critique Logo">
  <h1>Critique</h1>
</div>

> **System-wide AI writing superpowers.** Minimal, privacy-first, and insanely fast text transformation for macOS.

Critique is a lightweight, distraction-free writing assistant for macOS. It supports local Apple Silicon to provide private, powerful AI refinement across every application, with or without the need for external APIs.

Built with Swift and Apple MLX—fast, private, and works on all apps.

---

## Highlights

- **Surgical Text Transformation**: Select text anywhere and invoke Critique with your hotkey. Your text is instantly replaced with the AI-optimized version.
- **Truly Native**: Built in Swift/SwiftUI. Uses ~0% CPU when idle and remains responsive even under load.
- **Privacy-First**: No data collection. Use local models for 100% on-device processing.
- **Rich Text Aware**: Proofread preserves RTF formatting (bold, italics, etc.) so your documents stay styled.
- **Customizable**: Create your own "tones" with custom instructions and shortcuts.

---

## Quick Start

1. **Download** the latest `.dmg` from [Releases](https://github.com/prxshetty/Critique/releases).
2. **Install** by dragging **Critique.app** into your Applications folder.
3. **Permissions**: Grant **Accessibility** access (required to read/replace text).
4. **Setup**: Choose your provider in Settings:
   - **Cloud**: OpenAI, Google (Gemini), Anthropic, Mistral, OpenRouter.
   - **Local**: **Apple Intelligence**, **MLX** (on-device), or **Ollama**.

> [!IMPORTANT]
> **System Requirements:**
> - **macOS 14.0+** is required for Accessibility API features.
> - **macOS 15.4+** is required for native **Apple Intelligence** features.
> - **Apple Silicon** is recommended for MLX on-device inference.

---

## Providers & Models

Critique lets you mix & match based on your needs:
- **Local (Privacy)**: Use **Apple Intelligence** or **MLX on Apple Silicon** for low-latency, on-device inference.
- **Cloud (Power)**: Use GPT-5, Claude 4.6, or Gemini Pro for complex tasks.
- **OpenAI-Compatible**: Seamlessly connect to **Ollama** or other local servers.

---

## License & Credits

Critique is distributed under the GNU General Public License v3.0.  
*Based on the [WritingTools](https://github.com/theJayTea/WritingTools) project.*

---
