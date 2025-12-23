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
    var centerColor: [Color] = [.primary]

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
    func updateCenterColor(text: AttributedString, selection: AttributedTextSelection, colorScheme: ColorScheme) {
        var defaultTextColor: Color { colorScheme == .dark ? .white : .black }

        // Get a list of the unique, optional colours in the selection
        // If no colors have been set, the set will still contain one Optional(nil) value
        let colors = Set(selection.attributes(in: text)[\.foregroundColor].map{ $0  ?? defaultTextColor })
        // now make the result an array
            .map{ $0 }

        if colors.isEmpty {  // should never be the case, but lets assume things might change.
            centerColor = [defaultTextColor]
//        } else if colors.count == 1 {
//            let first = colors.first! ?? defaultTextColor //the first color is still an optional
//            centerColor = [first]
        } else { // For ranges of more than one colour, show the secondary colour
            centerColor = colors
        }
    }

    /// update the selected text to match the newly selected color
    func updateText(text: inout AttributedString, selection: inout AttributedTextSelection) {
        text.transformAttributes(in: &selection) { container in
            container.foregroundColor = selectedColor
        }
    }

    /// Create a mesh gradient for the center of the color picker icon
    func mesh(_ colours: [Color]) -> MeshGradient {
    let points : [SIMD2<Float>] =
    colours.count == 3 ? [ [0,0], [0.6,0.0], [1,0],[0,1],[0.6,1], [1,1]] : [ [0,0], [1, 0], [0,1], [1,1] ]
    let c = colours.first ?? .primary
    let meshcolors = switch colours.count {
        case 0,1: [c,c,c,c]
        case 2,3:  colours + colours
        default: colours
    }
    return MeshGradient(width: colours.count == 3 ? 3 : 2, height: 2, points: points, colors: meshcolors)
}
}
