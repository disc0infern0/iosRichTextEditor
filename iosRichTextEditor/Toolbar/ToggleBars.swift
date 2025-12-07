//
//  ToggleBar.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//


//
//  FormatStyleButtons.swift
//  toggles
//
//  Created by Andrew on 26/11/2025.
//

import SwiftUI
struct ToggleBars {

    @Binding var text: AttributedString
    @Binding var selection : AttributedTextSelection
    @Binding var toggleStates: [ToolbarToggle: Bool]
    let context: Font.Context
    
    func basicFormatting() -> some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "basic", placement: .bottomBar) {
                /// A controlGroup will keep the controls within it together
                ControlGroup {
                    ShowToggleButtons(ToolbarToggle.basic)
                }
                .task(id: selection) {
                    /// Update toggles to match typing attributes at the insertion point
                    if selection.isInsertionPoint(in: text) {
                        updateToggleStates()
                    }
                }
            }
            ToolbarItem(id: "colorpicker", placement: .bottomBar) {
                MyColorPicker(selection: $selection, text: $text)
            }
        }
        .customizationBehavior(.reorderable)
    }

    func moreFormatting() -> some CustomizableToolbarContent {
        Group {
            ToolbarItem( id: "textalignment", placement: .secondaryAction ) {
                ControlGroup {
                    ShowToggleButtons(ToolbarToggle.textAlignment)
                }
            }
            .customizationBehavior(.reorderable)

            ToolbarItem(id: "textsize", placement: .secondaryAction ) {
                ControlGroup {
                    ShowToggleButtons(ToolbarToggle.size)
                        .labelStyle(.titleOnly)
                }
            }
            .customizationBehavior(.reorderable)
        }

    }
}

extension ToggleBars {
    func ShowToggleButtons(_ toggles: [ToolbarToggle] ) -> some View {
        ForEach ( toggles )  { toggle in
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
    }

    /// App Actions
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

