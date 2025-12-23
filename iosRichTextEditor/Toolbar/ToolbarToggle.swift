//
//  ToolbarToggle.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//


import SwiftUI

/// A toggle that will be added to the UI.
/// Each toggle has it's own icon and description. It may also be assigned into an array of related toggles for logical grouping of controls in the UI.
public enum ToolbarToggle: String, CaseIterable, Identifiable, RawRepresentable, CustomStringConvertible {
    case bold,  italic, underline, strikethrough, extraLarge, Large, Medium, Body, Footnote, leftAlign, rightAlign, centerAlign
    public var id: String { rawValue }
    /// Instead of producing the label within a switch, set description and icon properties separately
    /// so that we can use the new Button/Toggle api, and also the description can be used for easier debugging
    /// (via CustomStringConvertible)
    public var description: String { self.properties.text }
    public var icon: String { self.properties.icon }
    public var properties: (icon: String, text: String) {
        switch self {
            case .bold: ("bold", "Bold")
            case .italic: ("italic", "Italic")
            case .underline: ("underline", "Underline")
            case .strikethrough: ("strikethrough", "Strikethrough")
            case .leftAlign: ("text.alignleft", "Left Align")
            case .centerAlign: ("text.aligncenter", "Center Align")
            case .rightAlign: ("text.alignright", "Right Align")
            case .extraLarge: ("textformat.size.larger", "Extra Large")
            case .Large: ("textformat.size.larger", "Large")
            case .Medium: ("textformat.alt", "Medium")
            case .Body: ("textformat.size.smaller", "Body")
            case .Footnote: ("textformat.size.smaller", "Footnote")
        }
    }

    /// Helpful groupings for the view layout
    static let basic: [ToolbarToggle] = [.bold,  .italic, .underline, .strikethrough]
    static let size: [ToolbarToggle] = [.extraLarge, .Large, .Medium, .Body, .Footnote]
    static let textAlignment: [ToolbarToggle] = [.leftAlign, .centerAlign, .rightAlign]
    static func members(of groups: [LayoutGroup]) -> [ToolbarToggle] {
        groups.reduce([], {$0 + $1.members})
    }
    enum LayoutGroup {
        case Basic, Size, TextAlignment
        //Allow easy concatenation of groups with the array parameter
        var members: [ToolbarToggle] {
            switch self {
                case .Basic: ToolbarToggle.basic
                case .Size: ToolbarToggle.size
                case .TextAlignment: ToolbarToggle.textAlignment
            }
        }
    }
}

