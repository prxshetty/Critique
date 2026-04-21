# Critique

> **Minimal, system-wide AI writing tool. Built for being simple.**

Critique is an open-source writing assistant that supercharges your workflow. With one hotkey, you can instantly proofread, rewrite, or summarize text across any application.

---

## ✨ What is Critique?

Critique is an **Apple Intelligence-inspired application for macOS only(for now) that supercharges your writing with an AI LLM** (cloud-based or local).

With one hotkey press system-wide, it lets you fix grammar, optimize text according to your instructions, summarize content (webpages, YouTube videos, etc.), and more.

---

## ⚡ What can I do with Critique, exactly?

### 1️⃣ Hyper-intelligent Writing Tools:
- Select _any_ text on your PC and invoke Critique with `ctrl+space`.
- Choose **Proofread**, **Rewrite**, **Friendly**, **Professional**, **Concise**, or even enter **custom instructions** (e.g., _"add comments to this code"_, _"make it title case"_, _"translate to French"_).
- Your text will instantly be replaced with the AI-optimized version. Use `ctrl+z` to revert.

### 2️⃣ Powerful content summarization that you can chat with:
- Select all text in any webpage, document, email, etc., with `ctrl+a`, or select the transcript of a YouTube video (from its description).
- Choose **Summary**, **Key Points**, or **Table** after invoking Critique.
- Get a pop-up summary with clear and beautiful formatting (with Markdown rendering), saving you hours.
- Chat with the summary if you'd like to learn more or have questions.

### 3️⃣ Go wild with your own buttons!
- They're your own magic buttons. Dream, and it'll magically be done with AI.

### 4️⃣ Chat with an LLM anytime in a click:
- Press `ctrl+space` without selecting text to start a conversation with your LLM _(for privacy, chat history is deleted when you close the window)_.

## 🌟 Why Choose Critique?

Aside from being the only Windows/Linux program like Apple's Writing Tools, and the only way to use them on an Intel Mac or in the EU:

- **More intelligent than Apple's Writing Tools and Grammarly Premium:** Apple uses a tiny 3B parameter model, while Critique lets you use much more advanced models for free (e.g., Gemini 2.0 Flash [~30B]). Grammarly's rule-based NLP can't compete with LLMs.
- **Completely free and open-source:** No subscriptions or hidden costs. Bloat-free and uses **~0% of your CPU** even when actively using it.
- **Versatile AI LLM support:** Jump in quickly with the **free Gemini API & Gemini 2.0**, or an extensive range of **local LLMs** (via Ollama [[instructions]](https://github.com/prxshetty/Critique?tab=readme-ov-file#-optional-ollama-local-llm-instructions-for-windowslinux-v7-onwards), llama.cpp, KoboldCPP, TabbyAPI, vLLM, etc.) or **cloud-based LLMs** (ChatGPT, Mistral AI, etc.) through Critique's OpenAI-API-compatibility.
- **Does not mess with your clipboard, and works system-wide.**
- **Privacy-focused**: Your API key and config files stay on *your* device. NO logging, diagnostic collection, tracking, or ads. Invoked *only* on your command. Local LLMs keep your data on your device & work without the internet.
- **Supports multiple languages:** Works with any language and translates text better than Google Translate (type "translate to [language]" in `Describe your change...`).
- **Code support:** Fix, improve, translate, or add comments to code with `Describe your change...`."
- **Themes, Dark Mode, & Customization**: Choose between **2 themes**: a blurry gradient theme and a plain theme that resembles the Windows + V pop-up! Also has full **dark mode** support. **Set your own hotkey** for quick access.

## ✅ **1 Minute Installation**

### **🪟 Windows**:
1. Go to the [Releases](https://github.com/prxshetty/Critique/releases) page and download the latest `Critique.zip` file.
2. Extract it to your desired location (recommended: `Documents` or `App Data/Local`), run `Critique.exe`, and enjoy! :D

*Note: Critique is a portable app. If you extract it into a protected folder (e.g., Program Files), you must run it as administrator at least on first launch so it can create/edit its config files (in the same folder as its exe).*

**PS: Go to Critique's Settings (from its tray icon at the bottom right of the taskbar) to enable starting Critique on boot.**

### **🐧 Linux (work-in-progress)**:
[Run it from the source code](https://github.com/prxshetty/Critique/blob/main/README's%20Linked%20Content/To%20Run%20Critique%20Directly%20from%20the%20Source%20Code.md)

Critique works well on x11. On Wayland, there are a few caveats:
- [it works on XWayland apps](https://github.com/prxshetty/Critique/issues/34#issuecomment-2461633556)
- [and it works if you disable Wayland for individual Flatpaks with Flatseal.](https://github.com/prxshetty/Critique/issues/93#issuecomment-2576511041)

<a id="macos"></a>
### 🍎 macOS
The macOS version is a **native Swift port**, developed by [Arya Mirsepasi](https://github.com/Aryamirsepasi). View the [README inside the macOS folder](https://github.com/prxshetty/Critique/tree/main/macOS) to learn more.

To install it:
1. Go to the [Releases](https://github.com/prxshetty/Critique/releases) page and download the latest macOS `.dmg` file.
2. Open the `.dmg` file, also open a Finder Window, and drag the `Critique.app` into the Applications folder. That's it!

**Note:** macOS 14 or later is required due to accessibility API requirements.

---

#### 💎 Why the macOS port is special

- **Truly native**: Built in Swift (SwiftUI + AppKit where needed) for a fast, polished Mac experience.
- **Private & on-device**: Run **local LLMs with MLX** on Apple Silicon — no internet required for on-device models.
- **Rich-text aware**: **Proofread preserves RTF formatting** (bold, italics, lists, links) so your documents keep their look while errors disappear.
- **Your workflows, your way**: **Edit and add your own commands** and assign custom shortcuts.
- **Multilingual by design**: App UI supports **English, German, French, and Spanish**, and commands work in many more languages.
- **Choice of intelligence**: Connect to top providers or go fully local — switch any time.
- **Themes**: Multiple themes (including dark mode) to match your desktop vibe.

#### 🧠 Providers & Models on macOS

- Cloud: **OpenAI, Google (Gemini), Anthropic, Mistral, OpenRouter**  
- Local: **Ollama** (via OpenAI-compatible endpoint) and **MLX on Apple Silicon** for first-class, low-latency on-device inference  
- You can mix & match: keep sensitive work on-device with MLX, use cloud models when you need the biggest brains.

#### 🖱️ System-wide magic on macOS

- Works across most Mac apps — select text, invoke Critique, and instantly **Proofread**, **Rewrite**, **Change tone**, or **Summarize**.
- Start a **quick chat** with your chosen model without selecting text.

> **Tip:** If your shortcut clashes with Spotlight or Input Source switching, set a custom hotkey in Critique **and/or** adjust macOS settings under  
> **System Settings → Keyboard → Keyboard Shortcuts** (Spotlight / Input Sources).

#### 🔐 First-launch permissions (macOS)

For full functionality, macOS will prompt you to grant:
- **Accessibility** (to read/replace selected text)
- **Screen Recording** (for certain apps that restrict text access)

You can manage these under **System Settings → Privacy & Security**.

#### ⚙️ Power features (macOS)

- **Command editor**: Create reusable buttons for your own prompts and assign shortcuts.
- **Model flexibility**: Bring your own API keys. Switch providers per task.
- **Document-friendly**: RTF-preserving **Proofread** keeps your formatting intact.
- **Localization**: UI in **EN/DE/FR/ES**; commands happily work with many languages.
- **Theming**: Choose from multiple themes, including dark mode.

#### 🧩 Troubleshooting (macOS)

- **Hotkey not firing?** Change the shortcut in Critique and make sure nothing else uses the same combo (Spotlight / Input Sources).  
- **No text replacement in a specific app?** Ensure **Accessibility** is enabled for Critique; for some apps, **Screen Recording** is also required.  
- **Local model issues?** Confirm your Ollama/MLX model is running and the base URL/model name are correct in Settings.

---

## 👀 Tips

#### 1️⃣ Summarise a YouTube video from its transcript:

https://github.com/user-attachments/assets/dd4780d4-7cdb-4bdb-9a64-e93520ab61be

#### 2️⃣ Make Critique work better in MS Word: the `ctrl+space` keyboard shortcut is mapped to "Clear Formatting", making you lose paragraph indentation. Here's how to improve this:
P.S.: Word's rich-text formatting (bold, italics, underline, colours...) will be lost on using Critique. A Markdown editor such as [Obsidian](https://obsidian.md/) has no such issue.

https://github.com/user-attachments/assets/42a3d8c7-18ac-4282-9478-16aab935f35e

## 🔒 Privacy

I believe strongly in protecting your privacy. Critique:
- Does not collect or store any of your writing data by itself. It doesn't even collect general logs, so it's super light and privacy-friendly.
- Lets you use local LLMs to process your text entirely on-device.
- Only sends text to the chosen AI provider (encrypted) when you *explicitly* use one of the options.
- Only stores your API key locally on your device.

Note: If you choose to use a cloud based LLM, refer to the AI provider's privacy policy and terms of service.

## ✨ Options Explained

- **Proofread:** The smartest grammar & spelling corrector. Sorry not sorry, Grammarly Premium.
- **Rewrite:** Improve the phrasing of your text.
- **Make Friendly/Professional:** Adjust the tone of your text.
- **Custom Instructions:** Tailor your request (e.g., "Translate to French") through `Describe your change...`.

The following options respond in a pop-up window (with markdown rendering, selectable text, and a zoom level that saves & applies on app restarts):
- **Summarize:** Create clear and concise summaries.
- **Extract Key Points:** Highlight the most important points.
- **Create Tables:** Convert text into a formatted table. PS: You can copy & paste the table into MS Word.

## 🦙 (Optional) Ollama Local LLM Instructions [for Windows/Linux v7 onwards]:
These instructions are for Critique Windows/Linux v7+, using its native Ollama provider:
1. [Download](https://ollama.com/download) and install Ollama.
2. Choose an LLM from [here](https://ollama.com/library). Recommended: `Llama 3.1 8B` (~8GB RAM of VRAM required).
3. Run `ollama pull llama3.1:8b` in your terminal to download it.
4. Open Critique Settings and simply select the Ollama AI Provider. The default model name is already `Llama 3.1 8B`.
5. That's it! **Enjoy Critique with _absolute_ privacy and no internet connection!** 🎉 From now on, you'll simply need to launch Ollama and Critique into the background for it to work.

## 🦙 (Optional) Ollama Local LLM Instructions:
These instructions are for any Critique version, using the OpenAI-Compatible provider:
1. [Download](https://ollama.com/download) and install Ollama.
2. Choose an LLM from [here](https://ollama.com/library). Recommended: `Llama 3.1 8B` (~8GB RAM of VRAM/RAM required).
3. Run `ollama pull llama3.1:8b` in your terminal to download Llama 3.1.
4. In Critique, set the `OpenAI-Compatible` provider with:
   - API Key: `ollama` (PS: For most local LLM providers, any random string here will suffice.)
   - API Base URL: `http://localhost:11434/v1`
   - API Model: `llama3.1:8b`
5. That's it! **Enjoy Critique with _absolute_ privacy and no internet connection!** 🎉 From now on, you'll simply need to launch Ollama and Critique into the background for it to work.

## 🐞 Known Issues
1. (Being investigated) On some devices, Critique does not work correctly with the default hotkey.
   
   To fix it, simply change the hotkey to **ctrl+`** or **ctrl+j** and restart Critique. PS: If a hotkey is already in use by a program or background process, Critique may not be able to intercept it. The above hotkeys are usually unused.

2. The initial launch of the `Critique.exe` might take unusually long — this seems to be because AV software extensively scans this new executable before letting it run. Once it launches into the background in RAM, it works instantly as usual.

## 👨‍💻 To Run Critique Directly from the Source Code

[Instructions here!](https://github.com/prxshetty/Critique/blob/main/README's%20Linked%20Content/To%20Run%20Critique%20Directly%20from%20the%20Source%20Code.md)


## 👨‍💻 To Compile the Application Yourself:

[Instructions here!](https://github.com/prxshetty/Critique/blob/8713e5a5de63a7892b05a43b9753172e692768fb/README's%20Linked%20Content/To%20Compile%20the%20Application%20Yourself.md)

## 🌟 Contributors

Critique would not be where it is today without its amazing contributors:

### 🪟🐧 Windows & Linux version:
**1. [momokrono](https://github.com/momokrono):**

Added Linux support, switched to the pynput API to improve Windows stability. Added Ollama API support, the core logic for customisable buttons, and localization. Fixed misc. bugs and added graceful termination support by handling SIGINT signal.

@momokrono has been incredibly kind and helpful, and I'm forever grateful to have him as a contributor. Not only has he provided extensive help with code, but he's also played a big role in managing GitHub issues. - Jesai

**2. [Cameron Redmore (CameronRedmore)](https://github.com/CameronRedmore):**

Extensively refactored Critique and added OpenAI Compatible API support, streamed responses, and the chat mode when no text is selected.

**3. [Soszust40 (Soszust40)](https://github.com/Soszust40):**

Helped add dark mode, the plain theme, tray menu fixes, and UI improvements.

**4. [Alok Saboo (arsaboo)](https://github.com/arsaboo):**

Helped improve the reliability of text selection.

**5. [raghavdhingra24](https://github.com/raghavdhingra24):**

Made the rounded corners anti-aliased & prettier.

**6. [ErrorCatDev](https://github.com/ErrorCatDev):**

Significantly improved the About window, making it scrollable and cleaning things up. Also improved our .gitignore & requirements.txt.

**7. [Vadim Karpenko](https://github.com/Vadim-Karpenko):**

Helped add the start-on-boot setting!

### 🍎 macOS version:
#### A native Swift port created entirely by **[Arya Mirsepasi](https://github.com/Aryamirsepasi)**! This was a big endeavour and he's done an increadble job.

Over so many emails, @Aryamirsepasi has been someone I truly look up to, and it's rare to find people as kind as him. We're incredibly grateful for all his contributions here! — Jesai

**1. [Joaov41](https://github.com/Joaov41):**

Developed the amazing picture processing functionality in Gemini for Critique, allowing the app to now work with images in addition to text!

**2. [drankush](https://github.com/drankush):**

Fixed an issue that caused the app to fail in completing requests when the OpenAI provider was configured with a custom Base URL (e.g., for Groq or other compatible services).

**3. [gdmka](https://github.com/gdmka):**

- Added the change that makes the ResponseView remember the user’s preferred text size across app launches. 
- Implemented ability to set custom provider per each command. 


## 🤝 Contributing

I welcome contributions! :D

If you'd like to improve Critique, please feel free to open a Pull Request or get in touch with me (email below).

If there are major changes on your mind, it may be a good idea to get in touch before working on it.

## 📬 Contact

Email: jesaitarun@gmail.com

Made with ❤️ by a high school student. Check out my other app, [Bliss AI](https://play.google.com/store/apps/details?id=com.jesai.blissai), a free AI tutor!

## 📄 License

Distributed under the GNU General Public License v3.0.
