//
//  Toolbars.swift
//  iosRichTextEditor
//
//  Created by Andrew on 07/12/2025.
//
import SwiftUI
import TextColorPicker

extension View {
    func addToolbars(
        for text: Binding<AttributedString>,
        with selection: Binding<AttributedTextSelection>
    ) -> some View {
        self.modifier(Toolbars(text: text, selection: selection))
    }
}

struct Toolbars: ViewModifier {
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection
    @State var toggleStates: [ToolbarToggle: Bool] = .init(uniqueKeysWithValues: ToolbarToggle.allCases.map { ($0, false) })
    @Environment(\.fontResolutionContext)
    var context

    @State var titlePointSize: Double = 0
    @State var title2PointSize: Double = 0
    @State var title3PointSize: Double = 0
    @State var bodyPointSize: Double = 0
    @State var footnotePointSize: Double = 0

    func body(content: Content) -> some View {
        content
        /// Bold/Italic/Underline/StrikeThrough, Color Buttons
        /// A standard toolbar placed at .keyboard or .bottombar is very fragile inside a NavigationStack, so inset a regular view into the bottom safe area.
            .safeAreaInset(edge: .bottom) {
                HStack {
                    HStack(spacing: 3) {
                        showToggleButtons(ToolbarToggle.basic)
                    }
                    .labelStyle(.iconOnly)
                    /// Create a nice glassy grouping for the four font styling buttons
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    /// Let the color picker stand alone
                    TextColorPicker(text: $text, textSelection: $selection)
                        .font(.title2)
                        .labelsHidden()
                }
            }
        /// Customizable toolbars in the secondary Action placement
            .toolbar(id: "debug", content: debug)
            .toolbar(id: "text", content: textFormatting )
            .toolbar(id: "alignment", content: alignmentFormatting)
            .toolbar(id: "reset", content: resetFormatting)
            .toolbarRole(.editor)
            .task(id: selection) {
                /// Update toggles to match typing attributes at the insertion point
                if selection.isInsertionPoint(in: text) {
                    updateToggleStates()
                }
            }
            .onAppear {
                titlePointSize = Font.title.resolve(in: context).pointSize
                title2PointSize = Font.title2.resolve(in: context).pointSize
                title3PointSize = Font.title3.resolve(in: context).pointSize
                bodyPointSize = Font.body.resolve(in: context).pointSize
                footnotePointSize = Font.footnote.resolve(in: context).pointSize
            }
    }
    func debug() -> some CustomizableToolbarContent {
        ToolbarItem(id: "debug") {
            Button("Debug") {
                var counter = 1
                for value in selection.attributes(in: text) {
                    print("Count: \(counter)")

                    // Resolve the current font and compare against a resolved .title reference
                    let currentFont: Font = value.font ?? .default
                    let resolved = currentFont.resolve(in: context)
                    let resolvedTitle = Font.title.resolve(in: context)

                    // Compare sizing metrics to decide if it still matches Title semantics.
                    // Prefer a metric like pointSize if available; otherwise fall back to a string description.
                    var matchesTitle = false
                    // On Apple platforms, resolved fonts typically expose a pointSize we can compare.
                    matchesTitle = (resolved.pointSize == resolvedTitle.pointSize)
//                    matchesTitle = (String(describing: resolved) == String(describing: resolvedTitle))

                    print("Font: \(currentFont)")
                    print("Resolved isBold: \(resolved.isBold), isItalic: \(resolved.isItalic)")
                    print("Matches .title (by metrics): \(matchesTitle)")

                    // Optional: also show paragraph-related info for context
                    if let alignment = value.alignment { print("Alignment: \(alignment)") }
                    if let lineHeight = value.lineHeight { print("Line height: \(lineHeight)") }

                    counter += 1
                }
            }
        }
    }

    func resetFormatting() -> some CustomizableToolbarContent {
        ToolbarItem(id: "clearformatting") {
            Button("Remove Formatting", systemImage: "xmark", role: .destructive ) {
                text.transformAttributes(in: &selection) { container in
                    container = AttributeContainer()
                }
            }
            .labelStyle(.titleAndIcon)
            .foregroundStyle(.red)
        }
        .customizationBehavior(.reorderable)
    }

    func alignmentFormatting() -> some CustomizableToolbarContent {
        ToolbarItem( id: "textalignment", placement: .secondaryAction ) {
            ControlGroup {
                showToggleButtons(ToolbarToggle.textAlignment)
            }
        }
        .customizationBehavior(.reorderable)
    }

    func textFormatting() -> some CustomizableToolbarContent {
        ToolbarItem(id: "textsize", placement: .secondaryAction ) {
            ControlGroup {
                showToggleButtons(ToolbarToggle.size)
                    .labelStyle(.titleOnly)
            }
        }
        .customizationBehavior(.reorderable)
    }

    /// Layout Helper Function
    func showToggleButtons(_ toggles: [ToolbarToggle] ) -> some View {
        ForEach(toggles) { toggle in
            Toggle(
                toggle.description,
                systemImage: toggle.icon,
                isOn: Binding(
                    get: { toggleStates[toggle] ?? false },
                    set: { _ in
                        runAction( for: toggle )
                        /// Update toggles if a range was highlighted for a change, as otherwise the toggles wont change until the selection changes
                        if !selection.isInsertionPoint(in: text) {
                            updateToggleStates()
                        }
                    }
                )
            )
        }
        .toggleStyle(.button)
        .buttonStyle(.glass)
    }

    /*****************************
        App Actions
    *************************/
    /// perform a toggle of the specificed togglebutton. Note that we do not update the state dictionary here.
    /// that is done automatically based on the selection change.
    func runAction(for toggle: ToolbarToggle) {
        text.transformAttributes(in: &selection) { container in
            // Resolve current font and determine current point size
            let currentFont: Font = container.font ?? .default
            let resolved = currentFont.resolve(in: context)
            switch toggle {
            case .bold:
                container.font = currentFont.bold(!resolved.isBold)
            case .italic:
                container.font = currentFont.italic(!resolved.isItalic)
                //                    let font: Font = container.font ?? .default
                //                    container.font = font.italic(!font.resolve(in: context).isItalic)
            case .underline: container.underlineStyle = container.underlineStyle == .none ? .single : .none
            case .strikethrough: container.strikethroughStyle = container.strikethroughStyle == .none ? .single : .none
            case .leftAlign: container.alignment = container.alignment == .left ? .right : .left
            case .rightAlign: container.alignment = container.alignment == .right ? .left : .right
            case .centerAlign: container.alignment = container.alignment == .center ? .left : .center
            case .extraLarge:
                // Toggle behavior: if we're already at title size, go back to body size; otherwise set to title size
                container.font = container.font == .title ? .body : .title
                restoreBoldandItalic()
            case .large:
                container.font = container.font == .title2 ? .body : .title2
                restoreBoldandItalic()
            case .medium:
                container.font = container.font == .title3 ? .body : .title3
                restoreBoldandItalic()
            case .body:
                container.font = .body
                restoreBoldandItalic()
            case .footnote:
                container.font = container.font == .footnote ? .body : .footnote
                restoreBoldandItalic()
            }
            func restoreBoldandItalic() {
                // Preserve resolved traits (bold/italic) when constructing the new font
                container.font = (container.font ?? .default).bold(resolved.isBold)
                container.font = (container.font ?? .default).italic(resolved.isItalic)
            }
        }
    }

    /// Update the Toggle States dictionary based on the attributes in the current selection. (whether a range or an insertion point)
    func updateToggleStates() {
        let attributes = selection.attributes(in: text)
        let alignments = Array(attributes[\.alignment])
        for toggle in ToolbarToggle.allCases {
            toggleStates[toggle] = switch toggle {
            case .bold:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).isBold }
            case .italic:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).isItalic }
            case .underline:
                attributes[\.underlineStyle].allSatisfy { $0 == .single }
            case .strikethrough:
                attributes[\.strikethroughStyle].allSatisfy { $0 != .none }
            case .leftAlign:
                alignments.allSatisfy { $0 == .left } || alignments.isEmpty
            case .rightAlign: alignments.allSatisfy { $0 == .right }
            case .centerAlign:
                alignments.allSatisfy { $0 == .center }
            case .extraLarge:
                /// The line below will not work if the font has had other formatting styles applied, e.g Bold/Italic
                ///  `attributes[\.font].allSatisfy({$0 == .title })`
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).pointSize == titlePointSize }
            case .large:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).pointSize == title2PointSize }
            case .medium:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).pointSize == title3PointSize }
            case .body:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).pointSize == bodyPointSize }
            case .footnote:
                attributes[\.font].allSatisfy { ($0 ?? .default).resolve(in: context).pointSize == footnotePointSize }
            }
        }
    }
}

#Preview {
    @Previewable @State var text = AttributedString("Hello World\n\nFormat the next line as described:\n Extra Large Title\n\nNow make the last word above <Bold>, and then remove <Bold> formatting.\n\nDoes the `Title` style still show as Extra Large?")
    @Previewable @State var textSelection = AttributedTextSelection()
    NavigationStack {
        TextEditor(text: $text, selection: $textSelection)
            .addToolbars(for: $text, with: $textSelection)
    }
}

// Future options
// Define a custom attribute for recording a font characteristic that we want to set .
// Potentially record whether .rounded, .serif, .monospaced has been applied because those styles cannot be queried.
// set with
// `container[CustomTextAttributes.FontStyleName.self] = "rounded"`
// private enum CustomTextAttributes {
//    struct FontStyleName: AttributedStringKey {
//        typealias Value = String
//        static var name: String { "custom.fontStyleName" }
//    }
// }
