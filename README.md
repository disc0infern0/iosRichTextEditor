#  iOS Rich Text Editor

This code is inspired by the inimitabale Stewart Lynch, in his series that he generously
makes public on youtube.
This particular example is based on this video:
https://www.youtube.com/watch?v=-hKpuysa6PM

Within the code I have taken different approaches to a number of logistical problems,
not least among which is how best to maintain the state of each button shown in the menu, and how to manage the display and looping over all of the various formatting buttons. 

# Key differences:

## Formatting buttons
Display of a formatting button is managed by a Toggle, displayed in the buttonstyle.
This means that we have only to manage an isOn: property for each toggle.
This code uses an enum to hold cases for each button, and a dictionary of those toggles controls the state.
This approach allows very little code repetition, and makes management of the buttons somewhat easier.

## Toolbars.
the first iteration of this project aimed to use all native SwiftUI toolbars.
For iOS in particular, this required use of the .keyboard placement within a NavigationStack, which unfortunately always generated layout errors at runtime.
To resolve this, the Bold/Italic/Underline/Strikethrough toggles are now placed in a small glassy view inset inthe safe area at the bottom of the screen.
Using secondary action toolbars for the remaining font toggles works well.
Overall, I'm happy with the way this has turned out. It looks like a native iOS 26 app.

## Color Picker
I started this exercise as a mac app, and the color picker on the mac app, is, being kind, weird, or if not being kind, downright ugly. 
This code now uses a TextColorPicker which is available separately in its own package. It can be direct ColorPicker replacement on iOS, iPadOS and macOS.
As the name suggests, it also can operate on AttributedStrings in an intuitive manner. 

## Updating toolbar status
To accurately assess the current attributes, and determine which toggles should be highlighed for the current selection, this code uses the ```selection.attributes``` property, and avoids use of a probe to create an array of all containers.
---

# Miscellaneous Notes / Bug Fixes

After applying Bold or Italic styles to text previously formatted with a size characteristic, such as "Extra Large", it is no longer possible to tell if the size is "Extra Large" by checking for that characteristic directly. This issue is now resolved within the code by first getting the font size for the "Extra Large" font, and then checking for that size. 
This corrects a bug with the first release. 


The last insertion point code herein is solely for use with a future verion of the app that saves and restores data either to disk or to SwiftData. 

Ideally it would be possible to convert to and from markdown, but that likely requires maintaining a tree of the structure because of the nested nature of some of the markdown. (Tables notably).
Storing the tree and maintaining it whilst typing, and allowing seamless switching of WYSIWYG to the code table behind it (a la Wordperfect 5.1 for those that remember it) is the work of another day. 

---

I'll update this code periodically as it contains some useful reference material, and I hope it's been useful for anyone reading here.

best wishes,
Andrew



