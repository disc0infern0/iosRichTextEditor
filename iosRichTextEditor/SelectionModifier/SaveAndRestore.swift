//
//  SaveAndRestore.swift
//  iosRichTextEditor
//
//  Created by Andrew on 27/01/2026.
//
import SwiftUI
import TextColorPicker

extension View {
    func saveAndRestore( _ selection: Binding<AttributedTextSelection>, in text: Binding<AttributedString> ) -> some View {
        self.modifier(SaveAndRestore(selection: selection, text: text))
    }
}

struct SaveAndRestore: ViewModifier {
    @Binding var selection: AttributedTextSelection
    @Binding var text: AttributedString

    @State private var lastInsertionPoint: AttributedString.Index = AttributedString("").startIndex

    func body(content: Content) -> some View {
        content
            .task {
                // Move the insertion point to the start of the text (or, the last saved point if restored)
                self.selection = AttributedTextSelection(insertionPoint: lastInsertionPoint)
            }
            .onChange(of: selection, initial: false) { oldValue, newValue in
                guard oldValue != newValue else { return }
                // Save the insertion point for (potential) restore
                if case .insertionPoint(let index) = newValue.indices(in: text) {
                    lastInsertionPoint = index
                }
            }
    }
}
