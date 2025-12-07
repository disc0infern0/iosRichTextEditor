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
        let togglebars = ToggleBars(text: $text, selection: $selection, toggleStates: $toggleStates, context: context)
        content
            .toolbarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar(id: "more") { togglebars.moreFormatting() }
            .toolbar(id: "basic") { togglebars.basicFormatting() }
            .toolbar(id: "reset") {
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
    }
}
