# ColorPicker

A replacement for the stock colorpicker used in iOS and macOS, offering a couple of minor differences:
- The picker icon and the launch of the color panel are separated and controlled/configured separately.
- The picker icon animates its surrounding color ring.
- If used with AttributedString, the inner color ring always reflects the current color either at the cursor or over the selection. (In the case of a selection spanning multiple colors, a gradient is shown of (up to 4) the unique colors highlighted )
- In iOS, the color panel launches correctly from a keyboard-bound toolbar. (The stock picker is bugged.)
- In macOS, the picker icon is consistent with how it appears on iOS, with the animated outer ring and auto-updating center color.

In use, the color panel is dismissed simply by clicking away from it.

## Overview

The main driver for this color picker was the bug on iOS that made launching the color picker unusable from a keyboard bound toolbar.
Using only SwiftUI, I was not able to find a solution I was happy with. The keyboard needs to be hidden, and at the same time, you need to click on the color picker control.
I noticed however that the stock formatting bar (right click attributed text, then font.. more.. ) shows a color picker icon that correctly hides the keyboard before launching.
It seemed impossible to replicate in SwiftUI, so I assumed this was/is still using UIKit, and so a journey began into the worlds of UIKit and AppKit..

The main architecture of the color picker ended up being comprised of:
- A central view model ('''ColorViewModel''')to hold the current and selected color, together with a variety of methods for launching the color panels.
- A view modifier to :
    - instantiate the view model and add it to the environment
    - For iOS, create a bottom sheet toggled by a State variable owned by the view modifer.
    - Detect changes to the text selection and call the view model to update the current color as expected.
    - Detect changes in the color panel, and call the view model to update the selected text to the selected color.
- A Color picker icon (```ColorPickerIcon```) that uses the viewmodel to show the color panel 'button'. The animated outer ring uses an AngularGradient of rainbow colors.
- An iOS color panel, and a macOS color panel. See below for further details.

### UIKit - UIColorPickerPanel

A fairly straightforward Representabale struct of the UIColorPickerViewController class. A co-ordinator is setup as the delegate which then communicates color changes back to the view model via a closure sent to it.
If we are being picky, the naming of "UIColorPickerPanel" is a little off as it's not really a panel, however I prefer naming consistency for easier maintenance.
I would have liked to be able to make the view float over the window behind it, but that wasn't possible (with my current knowledge at least!), so it is launched as a bottom sheet, with two custom presentation detents setup; The smaller one makes the main color panel swatches appear fully visible, and then the second, larger, detent shows the opacity slider, and custom color swatches.

### AppKit - NSColorPickerPanel

I have little experience with AppKit, and naively assumed that there would be an NS prefixed version of the UIColorPickerViewController. 
Sadly this turned out to not be the case, and thus ruled out a simple set of code using typealiases. 
Happily however the NSColorPanel turned out to be easy to use, and did not even require use of a bridging Representable.

Launching a NSColorPanel is straightforward, you just instantiate an instance of it, either by the static ```.shared``` property, or by a subclass. It is designed to never actually de-init, but will only hide upon execution of the ```.close``` method.
If you were wondering, that's why the panel is immediateley closed after it is created.
After finishing up the code and configuration for a new class that inherits from NSColorPanel, it turned out that I didnt need any customisation to it other than setting the delegate to handle the color change.
I could therefore just have used the stock NSColorPanel.shared object, but now that the new one is wired up, I've left it as is in case any future tweaks require the full range of customisation offered by a subclass.

# To Do
- A little further tweaking would mean that both the AttributedString parameters could be made optional, and then it could be used as a standalone color picker regardless of what the color is being picked for. 
- Further to the above, separate into its own package
- ~~Update the color picker icon to show an angular gradient of the colors in the selected range, if that selected range has more than one color. ~~ Done!
