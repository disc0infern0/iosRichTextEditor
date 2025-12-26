//
//  ColourPickerStyle.swift
//  toolbars
//
//  Created by Andrew on 17/12/2025.
//
import SwiftUI

/// Quick configuration variables for the colour picker icon
enum ColourPickerStyle {
    // Rainbow Colors from the mnemonic: Richard Of York Gave Battle In Vain
    static let violet: Color = Color(red: 155/255, green: 38/255, blue: 182/255) // No violet colour predefined :S
    static let rainbowColors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, violet, .red]
    static let rainbowStrokeWidth = 3.0
    static let rainbowAnimationDuration = 4.2
    /// How much to shrink the central filled circle that shows the current colour. Shrinking reveals the spinning colour wheel behind it.
    static let shrinkRatio = 0.8 // the outer wheel will always be 20% of the view's size.
}
/// A colour picker that indicates its function by both a circular moving pattern, and an inner circle that has an
/// outline of the background color, and is filled with the current text color,
struct ColorPickerIcon: View  {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection
    @State var colorViewModel = ColorViewModel()
    @State private var rotation = 0.0
    @State private var textFrame = CGRect.zero

    /// Essentially this is 3 concentric circles, but managing the proportions of each circle by setting their
    /// sizes individually, and/or by setting insets, is difficult to do for all text sizes we want to align with.
    /// *We need the outer edge of the circle to align with the size of the text, and ensure that the whole view
    /// responds to dynamic text sizing and isnt clipped by it's surroundings.*
    ///
    /// We are going to cheat a little by using Symbols inside a Text view to ensure alignment with the
    /// surrounding text;-  A Zstack of circle (an outer edge only) and circle.fill (same size, but filled in).
    /// Then if we shrink that a little, and overlay it on a spinnign colour wheel, we have the 3 concentric
    /// circles we want, and we only have to manage one number - the amount to shrink. If we set this as
    /// a proportionate value of its current size, say 80%, then it should always scale correctly, and reveal
    /// the correct amount of the colour wheel.
    ///
    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .foregroundStyle( colorViewModel.mesh(colorViewModel.centerColor))
            Image(systemName: "circle")
                .foregroundStyle(.background)
        }
        .scaleEffect(ColourPickerStyle.shrinkRatio)

        .background(
            // Moving rainbow outer circle
            Circle()
                .inset(by: ColourPickerStyle.rainbowStrokeWidth/2)
                .stroke(AngularGradient(colors: ColourPickerStyle.rainbowColors, center: UnitPoint(x: 0.5, y: 0.5), angle: Angle.degrees(360)),
                        lineWidth: ColourPickerStyle.rainbowStrokeWidth)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: ColourPickerStyle.rainbowAnimationDuration)
                    .repeatForever(autoreverses: false), value: rotation)
                .task {
                    if reduceMotion { return }
                    rotation = 360
                }
        )
        .onTapGesture {
            colorViewModel.showColorPicker()
        }
        .withColorPicker(for: $text, selection: $selection)
        .environment( \.colorViewModel, colorViewModel )
    }
}

#Preview("icon") {
    @Previewable @State var text: AttributedString = "The quick red fox"
    @Previewable @State var selection = AttributedTextSelection()

    HStack {
        Text("Pick a color")
        ColorPickerIcon(text: $text, selection: $selection)
    }
    .border(.secondary.opacity(0.2))
    .frame(width: 300, height: 300)

    //    .font(.largeTitle)
    //    .font(.title)
    //    .font(.title2)
    //    .font(.title3)
    .font(.body)

}

#Preview("mesh") {
    @Previewable @State var colorViewModel = ColorViewModel()
    let colors: [Color] = [.red, .blue ]
    Text("\(Image(systemName: "circle.fill"))")
        .foregroundStyle( colorViewModel.mesh(colors) )
        .font(.largeTitle)
}
