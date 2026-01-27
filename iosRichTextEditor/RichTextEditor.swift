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

    var body: some View {
        NavigationStack {
            TextEditor( text: $text, selection: $selection )
                .addToolbars(for: $text, with: $selection)
                .navigationTitle(noteName ?? "Rich Text Editor")
                .toolbarTitleDisplayMode(.inline)
                .scrollBounceBehavior(.basedOnSize)
        }
        // .saveAndRestore($selection, in: $text) // Future use
    }
}

#Preview {
    RichTextEditor()
}
