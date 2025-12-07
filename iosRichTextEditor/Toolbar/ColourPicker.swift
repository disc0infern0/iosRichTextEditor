//
//  ColourPickerStyle.swift
//  iosRichTextEditor
//
//  Created by Andrew on 06/12/2025.
//


import SwiftUI

/// Quick configuration variables for the colour picker
enum ColourPickerStyle {
    static let height = 24.0
    // Rainbow Colors from the mnemonic: Richard Of York Gave Battle In Vain
    static let violet: Color = Color(red: 155/255, green: 38/255, blue: 182/255) // No violet colour predefined :S
    static let rainbowColors: [Color] = [.red, .red, .orange, .yellow, .green, .blue, .indigo, violet]
    static let rainbowStrokeWidth = 3.0
    static let rainbowAnimationDuration = 8.0
    static let pickerInset = rainbowStrokeWidth + 0.5
    static let shrinkRatio = 0.6

}

/// A colour picker that indicates its function by both a circular moving pattern, and an inner circle that shows the current text color
/// On macOS and on iOS, the inner colour does not change with the text selection, the inner colour only changes when you change text colour.
/// On macOS, using the picker will change the colour of any text highlighted, however on iOS you have to make the change manually.
/// On macOS, the native picker has a weird shape, which this replaces.
struct MyColorPicker: View  {
    @Binding var selection: AttributedTextSelection
    @Binding var text: AttributedString

    @State var pickerColor: Color = .primary
    @State var centerColor: Color = .primary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation = 0.0
    static let rainbowColors = [ Color.yellow, Color.orange, Color.red,  Color.purple, Color.blue, Color.green ]
    
    var body: some View {
        /// Defer updates to the pickerColor to avoid updates during view updates (A bug?)
        var colorBinding: Binding<Color> {
            Binding(
                get: { self.pickerColor },
                set: { newValue in
                    Task {
                        self.pickerColor = newValue
                    }
                }
            )
        }
        // Inner circle showing the picker color
        Circle()
            .inset(by: ColourPickerStyle.pickerInset)
            .fill(centerColor)
            .allowsHitTesting(false)
            .containerRelativeFrame(.horizontal ) { length, axis  in ColourPickerStyle.shrinkRatio * length}
            .background(
                // Moving rainbow outer circle
                Circle()
                    .stroke(LinearGradient(colors: ColourPickerStyle.rainbowColors, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: ColourPickerStyle.rainbowStrokeWidth)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: ColourPickerStyle.rainbowAnimationDuration)
                        .repeatForever(autoreverses: false), value: rotation)
                    .allowsHitTesting(false)
                    .task {
                        guard !reduceMotion else { return }
                        rotation = 360
                    }
            )
            .overlay(
                ColorPicker("Text Color", selection: colorBinding, supportsOpacity: true)
                    .opacity(0.02)
                // the mac color picker is a weird shape, so make the hit box a circle
                    .contentShape(Circle())
                    .labelsHidden()
            )
            .task(id: selection) {
                // update the center of the color picker to the current colour
                // first get list of unique, non optional colours in the selection
                let colors = Set(selection.attributes(in: text)[\.foregroundColor].map{ $0 ?? .primary })
                if colors.isEmpty { centerColor = .primary } // likely to never hit this case because nil seems to be returned in the list of colours
                else if colors.count == 1 { centerColor = colors.first! }
                // For ranges of more than one colour, show the secondary colour
                else { centerColor = .secondary }
            }
            .task(id: pickerColor ) {
                centerColor = pickerColor
                #if os(iOS)
                // On ioS, you have to add the colour manually, whereas on mac, you dont
                text.transformAttributes(in: &selection) { container in
                    container.foregroundColor = centerColor
                }
                #endif
            }
    }
}
#Preview {
    @Previewable @State var selection = AttributedTextSelection()

    @Previewable @State var text: AttributedString = ""
    MyColorPicker(selection: $selection, text: $text)
        .border(Color.blue)
}
