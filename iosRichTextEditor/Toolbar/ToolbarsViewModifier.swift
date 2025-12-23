//
//  Toolbars.swift
//  iosRichTextEditor
//
//  Created by Andrew on 07/12/2025.
//
import SwiftUI

struct Toolbars: ViewModifier {
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection
    @State var toggleStates: [ToolbarToggle: Bool] = .init(uniqueKeysWithValues: ToolbarToggle.allCases.map{ ($0, false)})
    @Environment(\.fontResolutionContext) var context

    func body(content: Content) -> some View {
        content
        /// Bold/Italic/Underline/StrikeThrough, Color Buttons
        /// A standard toolbar placed at .keyboard or .bottombar is very fragile inside a NavigationStack, so inset a regular view into the bottom safe area.
            .safeAreaInset(edge: .bottom) {
                HStack {
                    HStack(spacing: 3)  {
                        ForEach (ToolbarToggle.basic) { toggle in
                            ShowToggleButton(toggle)
                        }
                        .buttonStyle(.glass)
                        .labelStyle(.iconOnly)
                    }
                    /// Create a nice glassy grouping for the four font styling buttons
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    /// Let the color picker stand alone
                    ColorPickerIcon()
                }
            }
        /// Customizable toolbars in the secondary Action placement
            .toolbar(id: "text", content: textFormatting )
            .toolbar(id: "alignment", content: alignmentFormatting)
            .toolbar(id: "reset", content: resetFormatting)
            .toolbarRole(.editor)
            .withColorPicker(for: $text, selection: $selection)
            .task(id: selection) {
                /// Update toggles to match typing attributes at the insertion point
                if selection.isInsertionPoint(in: text) {
                    updateToggleStates()
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
            .buttonStyle(.glass)
        }
        .customizationBehavior(.reorderable)
    }


    func alignmentFormatting() -> some CustomizableToolbarContent {
        ToolbarItem( id: "textalignment", placement: .secondaryAction ) {
            ControlGroup {
                ForEach ( ToolbarToggle.textAlignment ) {
                    toggle in
                    ShowToggleButton(toggle)
                }

            }
        }
        .customizationBehavior(.reorderable)
    }
    func textFormatting() -> some CustomizableToolbarContent {
        ToolbarItem(id: "textsize", placement: .secondaryAction ) {
            ControlGroup {
                ForEach ( ToolbarToggle.size ) {
                    toggle in
                    ShowToggleButton(toggle)
                }
                .labelStyle(.titleOnly)
            }
        }
        .customizationBehavior(.reorderable)
    }

    /// Helper Function

    func ShowToggleButton(_ toggle: ToolbarToggle ) -> some View {
        Toggle(
            toggle.description, systemImage: toggle.icon,
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
        .toggleStyle(.button)
    }


    /*****************************
        App Actions
    *************************/
    /// perform a toggle of the specificed togglebutton. Note that we do not update the state dictionary here.
    /// that is done automatically based on the selection change.
    func runAction(for toggle: ToolbarToggle) {
        text.transformAttributes(in: &selection) { container in
            switch toggle {
                case .bold:
                    let font = container.font ?? .default
                    container.font = font.bold(!font.resolve(in: context).isBold)
                case .italic:
                    let font: Font = container.font ?? .default
                    container.font = font.italic(!font.resolve(in: context).isItalic)
                case .underline: container.underlineStyle = container.underlineStyle == .none ? .single : .none
                case .strikethrough: container.strikethroughStyle =  container.strikethroughStyle == .none ? .single : .none
                case .leftAlign: container.alignment = container.alignment == .left ? .right : .left
                case .rightAlign: container.alignment = container.alignment == .right ? .left : .right
                case .centerAlign: container.alignment = container.alignment == .center ? .left : .center
                case .extraLarge: container.font = container.font == .title ? .body : .title
                case .Large: container.font = container.font == .title2 ? .body : .title2
                case .Medium: container.font = container.font == .title3 ? .body : .title3
                case .Body: container.font = .body
                case .Footnote: container.font = container.font == .footnote ? .body : .footnote
            }
        }
    }

    /// Update the Toggle States dictionary based on the attributes in the current selection. (whether a range or an insertion point)
    func updateToggleStates() {
        let attributes = selection.attributes(in: text)
        for toggle in ToolbarToggle.allCases {
            toggleStates[toggle] = switch toggle {
                case .bold: attributes[\.font].allSatisfy({($0 ?? .default).resolve(in: context).isBold })
                case .italic: attributes[\.font].allSatisfy({($0 ?? .default).resolve(in: context).isItalic })
                case .underline: attributes[\.underlineStyle].allSatisfy({$0 == .single})
                case .strikethrough: attributes[\.strikethroughStyle].allSatisfy({$0 != .none})
                case .leftAlign: attributes[\.alignment].allSatisfy({$0 == .left})
                case .rightAlign: attributes[\.alignment].allSatisfy({$0 == .right})
                case .centerAlign: attributes[\.alignment].allSatisfy({$0 == .center})
                case .extraLarge: attributes[\.font].allSatisfy({$0 == .title })
                case .Large: attributes[\.font].allSatisfy({$0 == .title2 })
                case .Medium: attributes[\.font].allSatisfy({$0 == .title3 })
                case .Body: attributes[\.font].allSatisfy({$0 == .body })
                case .Footnote: attributes[\.font].allSatisfy({$0 == .footnote })
            }
        }
    }
}


