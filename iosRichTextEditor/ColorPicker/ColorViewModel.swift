//
//  ColorViewModel.swift
//  toolbars
//
//  Created by Andrew on 20/12/2025.
//

import SwiftUI

extension EnvironmentValues {
    /// The owning entity for this in the view hierarchy will be the view modifier; MyColorPicker
    @Entry var colorViewModel = ColorViewModel()
}

@Observable
final class ColorViewModel {
    var selectedColor: Color = .primary
    var centerColor: Color = .primary

    // Activation of the picker
#if os(macOS)
    let panel = NSColorPickerPanel.customshared
    func setupPanel() {
        panel.setup(with: newSelectedColor, showsAlpha: true)
        panel.close()
    }
    func showColorPicker() {
        panel.color = NSColor(centerColor)
        panel.makeKeyAndOrderFront(nil)
    }
#else
    func showColorPicker() {
        colorPickerToggle.toggle()
    }
    // Define mock State and Binding variables for a boolean toggle
    // controlling whether the UIColorPicker is shown for iOS.
    var colorPickerToggle: Bool = false
    var colorPickerToggleBinding: Binding<Bool> {
        .init(get: { self.colorPickerToggle }, set: { self.colorPickerToggle = $0 })
    }
#endif
    /// Define a function to be sent to the picker so we can receive color updates.
    func newSelectedColor(_ newColor: Color) {
        selectedColor = newColor
    }

    /// update the center of the color picker to the current colour
    func updateCenterColor(text: AttributedString, selection: AttributedTextSelection) {
        // first get list of unique, optional colours in the selection
        // If no colors have been set, the set will contain one Optional(nil) value
        let colors = Set(selection.attributes(in: text)[\.foregroundColor].map{ $0 })

        if colors.isEmpty {  // should never be the case, but lets assume things might change.
            centerColor = .primary
        } else if colors.count == 1 {
            let first = colors.first! ?? .primary //the first color is still an optional
            centerColor = first
        } else { // For ranges of more than one colour, show the secondary colour
            centerColor = .secondary
        }
    }

    /// update the selected text to match the newly selected color
    func updateText(text: inout AttributedString, selection: inout AttributedTextSelection) {
        text.transformAttributes(in: &selection) { container in
            container.foregroundColor = selectedColor
        }
    }
}
