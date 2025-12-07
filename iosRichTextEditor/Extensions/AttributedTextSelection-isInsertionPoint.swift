//
//  AttributedTextSelection-isInsertionPoint.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//


//
// AttributedTextSelection isInsertionPoint
//  toggles
//
//  Created by Andrew on 04/12/2025.
//
import SwiftUI

extension AttributedTextSelection {
    /// Avoid having to use the awful if case let syntax in the main code
    func isInsertionPoint(in text: AttributedString) -> Bool {
        if case .insertionPoint = self.indices(in: text) {
            return true
        }
        return false
    }
}
