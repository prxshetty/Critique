# Critique

> **System-wide AI writing superpowers.** Minimal, privacy-first, and insanely fast text transformation for macOS.

Critique is a native writing assistant that supercharges your workflow. With one hotkey, instantly proofread, rewrite, or summarize text across any application.

---

## ⚡ Highlights

- **Surgical Text Transformation**: Select text anywhere and invoke Critique (`Cmd + Space`). Your text is instantly replaced with the AI-optimized version.
- **Truly Native**: Built in Swift/SwiftUI. Uses ~0% CPU when idle and remains responsive even under load.
- **Privacy-First**: No data collection. Keys are secured in the macOS Keychain. Use local models for 100% on-device processing.
- **Rich Text Aware**: Proofread preserves RTF formatting (bold, italics, etc.) so your documents stay styled.
- **Customizable**: Create your own "magic buttons" with custom instructions and shortcuts.

---

## 🚀 Quick Start

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

## 🧠 Providers & Models

Critique lets you mix & match based on your needs:
- **Local (Privacy)**: Use **Apple Intelligence** or **MLX on Apple Silicon** for low-latency, on-device inference.
- **Cloud (Power)**: Use GPT-4o, Claude 3.5, or Gemini Pro for complex tasks.
- **OpenAI-Compatible**: Seamlessly connect to **Ollama** or other local servers.

---

## 📄 License & Contributing

Critique is distributed under the GNU General Public License v3.0.  
Interested in contributing? Check our [todo.md](todo.md).

---

[**Development & Build Instructions**](README's%20Linked%20Content/To%20Run%20Critique%20Directly%20from%20the%20Source%20Code.md)
