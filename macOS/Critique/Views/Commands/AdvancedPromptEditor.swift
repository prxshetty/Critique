import SwiftUI

/// Advanced editor for structured prompt editing with individual fields for each property
struct AdvancedPromptEditor: View {
    @Binding var promptStructure: PromptStructure

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 20) {
            // --- Role ---
            GridRow(alignment: .top) {
                LabelColumn(title: "Role:", subtitle: "Persona")
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("e.g., proofreading assistant, summarization expert", text: $promptStructure.role)
                        .textFieldStyle(.roundedBorder)
                    Text("Define the assistant's role or persona.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // --- Task ---
            GridRow(alignment: .top) {
                LabelColumn(title: "Task:", subtitle: "Primary")
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("e.g., correct grammar and spelling errors", text: $promptStructure.task)
                        .textFieldStyle(.roundedBorder)
                    Text("Describe exactly what the assistant should do.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // --- Rules & Output ---
            GridRow(alignment: .top) {
                LabelColumn(title: "Output:", subtitle: "Rules")
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Output format (e.g., only corrected text)", text: $promptStructure.rules.output)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Acknowledge secondary content", isOn: Binding(
                            get: { promptStructure.rules.effectiveAcknowledgeContent },
                            set: { promptStructure.rules.acknowledgeContent = $0 }
                        ))
                        Toggle("Add explanations/commentary", isOn: Binding(
                            get: { promptStructure.rules.effectiveAddExplanations },
                            set: { promptStructure.rules.addExplanations = $0 }
                        ))
                        Toggle("Engage with user requests in text", isOn: Binding(
                            get: { promptStructure.rules.engageWithRequests ?? false },
                            set: { promptStructure.rules.engageWithRequests = $0 }
                        ))
                        Toggle("Treat input as content only", isOn: Binding(
                            get: { promptStructure.rules.inputIsContent ?? true },
                            set: { promptStructure.rules.inputIsContent = $0 }
                        ))
                        Toggle("Preserve original formatting", isOn: Binding(
                            get: { promptStructure.rules.preserveFormatting ?? false },
                            set: { promptStructure.rules.preserveFormatting = $0 }
                        ))
                    }
                    .toggleStyle(.checkbox)
                }
            }

            // --- Preservation ---
            GridRow(alignment: .top) {
                LabelColumn(title: "Preserve:", subtitle: "Options")
                
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                        Toggle("Tone", isOn: Binding(get: { promptStructure.rules.preserve.tone ?? false }, set: { promptStructure.rules.preserve.tone = $0 }))
                        Toggle("Style", isOn: Binding(get: { promptStructure.rules.preserve.style ?? false }, set: { promptStructure.rules.preserve.style = $0 }))
                        Toggle("Format", isOn: Binding(get: { promptStructure.rules.preserve.format ?? false }, set: { promptStructure.rules.preserve.format = $0 }))
                        Toggle("Meaning", isOn: Binding(
                            get: { promptStructure.rules.preserve.coreMessage ?? promptStructure.rules.preserve.coreMeaning ?? false },
                            set: { promptStructure.rules.preserve.coreMessage = $0; promptStructure.rules.preserve.coreMeaning = $0 }
                        ))
                    }
                    .toggleStyle(.checkbox)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Language Preservation:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("e.g., input, English, auto", text: Binding(
                            get: { promptStructure.rules.preserve.language ?? "input" },
                            set: { promptStructure.rules.preserve.language = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 150)
                    }
                }
            }

            // --- Advanced Options ---
            GridRow {
                Color.clear.frame(width: 110)
                
                DisclosureGroup("Advanced Configuration") {
                    VStack(alignment: .leading, spacing: 24) {
                        // Style Section
                        AdvancedSection(title: "Style Guidelines") {
                            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                                PickerRow(title: "Tone:", selection: Binding(
                                    get: { promptStructure.style?.tone ?? "neutral" },
                                    set: { if promptStructure.style == nil { promptStructure.style = PromptStructure.Style() }; promptStructure.style?.tone = $0 == "neutral" ? nil : $0 }
                                )) {
                                    Text("Neutral").tag("neutral"); Text("Formal").tag("formal"); Text("Casual").tag("casual")
                                }
                                PickerRow(title: "Voice:", selection: Binding(
                                    get: { promptStructure.style?.voice ?? "neutral" },
                                    set: { if promptStructure.style == nil { promptStructure.style = PromptStructure.Style() }; promptStructure.style?.voice = $0 == "neutral" ? nil : $0 }
                                )) {
                                    Text("Neutral").tag("neutral"); Text("First Person").tag("first person"); Text("Third Person").tag("third person")
                                }
                                FieldRow(title: "Personality:", text: Binding(
                                    get: { promptStructure.style?.personality ?? "" },
                                    set: { if promptStructure.style == nil { promptStructure.style = PromptStructure.Style() }; promptStructure.style?.personality = $0.isEmpty ? nil : $0 }
                                ))
                            }
                        }

                        // Constraints Section
                        AdvancedSection(title: "Constraints") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    FieldRow(title: "Min Len:", text: Binding(
                                        get: { promptStructure.constraints?.minLength.map(String.init) ?? "" },
                                        set: { if promptStructure.constraints == nil { promptStructure.constraints = PromptStructure.Constraints() }; promptStructure.constraints?.minLength = Int($0) }
                                    ))
                                    FieldRow(title: "Max Len:", text: Binding(
                                        get: { promptStructure.constraints?.maxLength.map(String.init) ?? "" },
                                        set: { if promptStructure.constraints == nil { promptStructure.constraints = PromptStructure.Constraints() }; promptStructure.constraints?.maxLength = Int($0) }
                                    ))
                                }
                                FieldRow(title: "Avoid Words:", text: Binding(
                                    get: { promptStructure.constraints?.avoidWords?.joined(separator: ", ") ?? "" },
                                    set: { if promptStructure.constraints == nil { promptStructure.constraints = PromptStructure.Constraints() }; let words = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }; promptStructure.constraints?.avoidWords = words.isEmpty ? nil : words }
                                ))
                            }
                        }

                        // Formatting Section
                        AdvancedSection(title: "Formatting Rules") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                                Toggle("Markdown", isOn: Binding(get: { promptStructure.formattingRules?.useMarkdown ?? false }, set: { if promptStructure.formattingRules == nil { promptStructure.formattingRules = PromptStructure.FormattingRules() }; promptStructure.formattingRules?.useMarkdown = $0 }))
                                Toggle("Headers", isOn: Binding(get: { promptStructure.formattingRules?.useHeaders ?? false }, set: { if promptStructure.formattingRules == nil { promptStructure.formattingRules = PromptStructure.FormattingRules() }; promptStructure.formattingRules?.useHeaders = $0 }))
                                Toggle("Lists", isOn: Binding(get: { promptStructure.formattingRules?.useLists ?? false }, set: { if promptStructure.formattingRules == nil { promptStructure.formattingRules = PromptStructure.FormattingRules() }; promptStructure.formattingRules?.useLists = $0 }))
                                Toggle("Tables", isOn: Binding(get: { promptStructure.formattingRules?.useTables ?? false }, set: { if promptStructure.formattingRules == nil { promptStructure.formattingRules = PromptStructure.FormattingRules() }; promptStructure.formattingRules?.useTables = $0 }))
                            }
                            .toggleStyle(.checkbox)
                        }

                        // Process Steps
                        AdvancedSection(title: "Process Steps") {
                            TextEditor(text: Binding(
                                get: { promptStructure.steps?.joined(separator: "\n") ?? "" },
                                set: { let steps = $0.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }; promptStructure.steps = steps.isEmpty ? nil : steps }
                            ))
                            .frame(height: 80)
                            .font(.system(.caption, design: .monospaced))
                            .padding(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Helper UI Components

private struct LabelColumn: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .gridColumnAlignment(.trailing)
        .frame(width: 110, alignment: .trailing)
        .padding(.top, 4)
    }
}

private struct AdvancedSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            content
        }
    }
}

private struct PickerRow<Content: View>: View {
    let title: String
    @Binding var selection: String
    let content: Content
    
    init(title: String, selection: Binding<String>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        GridRow {
            Text(title).foregroundStyle(.secondary).font(.caption)
            Picker("", selection: $selection) { content }
                .labelsHidden()
                .controlSize(.small)
                .frame(maxWidth: 150)
        }
    }
}

private struct FieldRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(.secondary).font(.caption)
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .controlSize(.small)
        }
    }
}
