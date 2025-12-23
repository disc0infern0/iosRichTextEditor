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
    static let pickerInset = 2.5
    static let shrinkRatio = 0.95
    static let iOSIconSize = 25.0
}

/// A colour picker that indicates its function by both a circular moving pattern, and an inner circle that shows the current text color
struct ColorPickerIcon: View  {
    @Environment(\.colorViewModel) var colorViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation = 0.0

    var body: some View {
//#if os(macOS)
//        let centerColor: Color = colorViewModel.centerColor
//#else
//        // For some reason iOS shows a dull grey as the primaryColor, which is not the default typing color
//        // The default typing color is either black or white depending upon the colorScheme.
//        // Here we manually correct use of .primary (which is set when no color is detected in the selection )
//        var centerColor: Color {
//            if colorViewModel.centerColor == .primary { colorScheme == .dark ? .white : .black }
//            else { colorViewModel.centerColor }
//        }
//#endif
        // Inner circle showing the picker color
        Circle()
            .inset(by: ColourPickerStyle.pickerInset + ColourPickerStyle.rainbowStrokeWidth/2)
            .fill( colorViewModel.mesh(colorViewModel.centerColor))
            // By default, the outercircle is bigger than other toolbar text icons, so shrink it down [ without setting a specific size ]
//            .scaleEffect(ColourPickerStyle.shrinkRatio)
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
        #if os(iOS)
            .frame(width: ColourPickerStyle.iOSIconSize, height: ColourPickerStyle.iOSIconSize)
        #endif
            .onTapGesture {
                colorViewModel.showColorPicker()
            }
    }


}



#Preview("icon") {
    @Previewable @State var colorViewModel = ColorViewModel()
    colorViewModel.centerColor = [.red, .blue]
    return ColorPickerIcon()
        .border(Color.blue)
        .environment( \.colorViewModel, colorViewModel )
        .frame(width: 30, height: 30)
}

#Preview("mesh") {
    @Previewable @State var colorViewModel = ColorViewModel()
    let colors: [Color] = [.red, .blue ]
    Circle()
        .fill( colorViewModel.mesh(colors) )
        .frame(width: 30)
}
