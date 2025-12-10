//
//  ContentView.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//

import SwiftUI

struct RichTextEditor: View {
    @State private var text: AttributedString = ""
    @State private var selection = AttributedTextSelection()
    @State private var lastInsertionPoint: AttributedString.Index = AttributedString("").startIndex
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            TextEditor( text: $text , selection: $selection )
                .padding()
                .scrollBounceBehavior(.basedOnSize)
                .navigationTitle("ioS Editor")
                .focused($isFocused)
                .toolbars(for: $text, with: $selection, withFocus: $isFocused)
        }
        .onAppear {
            // Move the insertion point to the start of the text (or, the last saved point if restored)
            self.selection = AttributedTextSelection(insertionPoint: lastInsertionPoint)
        }
        .onChange(of: selection, initial: false) { (oldValue, newValue) in
            guard oldValue != newValue else { return }
            // Save the insertion point for (potential) restore
            if case .insertionPoint(let index) = newValue.indices(in: text) {
                lastInsertionPoint = index
            }
        }

    }
}
extension View {
    func toolbars(
        for text: Binding<AttributedString>,
        with selection: Binding<AttributedTextSelection>,
        withFocus isFocused: FocusState<Bool>.Binding
    ) -> some View {
        self.modifier(Toolbars(text: text, selection: selection, withFocus: isFocused))

    }
}


#Preview {
    RichTextEditor()
}
