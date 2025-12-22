//
//  TogglingColorPicker.swift
//  toolbars
//
//  Created by Andrew on 19/12/2025.
//
import SwiftUI

/// The heart and soul of the color picker.
/// This sets up the viewmodel and controls all the updates to the selected text and the color displayed in the color picker icon
struct MyColorPicker: ViewModifier {
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection
    @State var colorViewModel = ColorViewModel()

    func body(content: Content) -> some View {

        content
            .task(id: colorViewModel.selectedColor) {
                // A new color has been selected, so update the text and the color picker centre
                colorViewModel.updateText(text: &text, selection: &selection)
                colorViewModel.centerColor = colorViewModel.selectedColor
            }
            .task(id: selection) {
                // The cursor has moved in the text, so update the color picker centre to show the current text color
                colorViewModel.updateCenterColor( text: text, selection: selection)
            }
#if os(macOS)
            .task { colorViewModel.setupPanel() }  // On macOS, prepare a floating panel of colours
#elseif os(iOS)
        // On iOS, present the colour picker in a bottom sheet
            .sheet(isPresented: colorViewModel.colorPickerToggleBinding) {
                ColorPickerPanel(text: $text, selection: $selection, currentCentre: colorViewModel.centerColor,
                                 submitColorChange: colorViewModel.newSelectedColor )
                .presentationDetents([.noAlpha, .withAlpha])
                .presentationDragIndicator(.hidden)
            }
#else
            .task {
                fatalError("Color Picker has not yet been implemented on this platform.")
            }
#endif
            .environment( \.colorViewModel, colorViewModel )
    }
}
extension View {
    func withColorPicker(for text: Binding<AttributedString>, selection: Binding<AttributedTextSelection>) -> some View {
        modifier(MyColorPicker(text: text, selection: selection) )
    }
}

extension PresentationDetent {
    static let noAlpha = Self.height(395)
    static let withAlpha = Self.height(590)
}
