//
//  ContentView.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//

import SwiftUI

struct RichTextEditor: View {
    @State private var noteName: String?
    @State private var text: AttributedString = ""
    @State private var selection = AttributedTextSelection()
    @State private var lastInsertionPoint: AttributedString.Index = AttributedString("").startIndex

    var body: some View {
        NavigationStack {
            TextEditor( text: $text , selection: $selection )
                .addToolbars(for: $text, with: $selection)
                .navigationTitle(noteName ?? "Rich Text Editor")
                .toolbarTitleDisplayMode(.inline)
                .scrollBounceBehavior(.basedOnSize)
        }
        .task {
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


#Preview {
    RichTextEditor()
}
