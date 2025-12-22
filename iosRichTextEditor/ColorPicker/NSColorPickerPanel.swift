import SwiftUI

#if os(macOS)
import AppKit
/// Create a new NSColorPanel object, complete with its delegate, NSColorChanging, so that we can communicate
/// color changes back to SwiftUI via a submitted closure that is instantiated by the new setup(:) function
final class NSColorPickerPanel: NSColorPanel, NSColorChanging {
    static let customshared = NSColorPickerPanel()

    typealias ColorChanger = ((Color)->Void)
    var submitColorChange: ColorChanger = { _ in }

    func changeColor(_ sender: NSColorPanel?) {
        /// convert the NSColor to a SwiftUI color and submit to SwiftUI
        if let sender { submitColorChange(Color(sender.color)) }
    }

    func setup(with colorChanger: @escaping ColorChanger, showsAlpha: Bool = true) {
        self.submitColorChange = colorChanger

        /// Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating

        // All continuous reporting of color changes
        isContinuous = true

        /// Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior.insert(.fullScreenAuxiliary)

        /// Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        /// Since there is no title bar make the window moveable by dragging on the background
        isMovableByWindowBackground = true

        /// Hide when unfocused
        hidesOnDeactivate = true

        /// Hide all traffic light buttons except close button
        standardWindowButton(.closeButton)?.isHidden = false
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        /// Sets animations accordingly
        animationBehavior = .utilityWindow

        /// Determine whether or not to show alpha values and an opacity slider
        self.showsAlpha = showsAlpha

        /// The following two lines are not strictly necessary since this class is the first responder
        /// and should automatically then receive the color change request.
        /// The two lines below, with the @objc function, guarantee this. [ Obj C .. eugh.]
        self.setTarget(self) // Set self as the target for color changes
        self.setAction(#selector(handleColorChange(_:))) // send to this objc function
    }

    @objc private func handleColorChange(_ sender: NSColorPanel?) {
        changeColor(sender)
    }

    /// Close automatically when out of focus, e.g. outside click
    override func resignMain() {
        super.resignMain()
        close()
    }

    /// `canBecomeKey` so the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }

    /// without the line below, clicking away from the panel will not close it.
    override var canBecomeMain: Bool {
        return true
    }
}

#endif
