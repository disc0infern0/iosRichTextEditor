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
Rather than create two custom views for the toolbar, the approach here is to attempt to use native SwiftUI toolbars. 
I'm not sure it's a total success honestly, as CustomizableToolbarContent cannot be easily mixed with other code to control the actions from each code, and view modifier is needed to control state.

## Color Picker
I started this exercise as a mac app, and the color picker on the mac app, is, being kind, weird, or if not being kind, downright ugly. 
This code thus replaces the color picker with aa custom version which has a number of immprovements
a) The central circle always updates to show the pencil colour. (The native one only changes when you change the colour).
b) It has a neat animation of the rainbow colours to draw the eye and reinforce the notion that this button is for changing the colour. (Animation is disabled for those that have set the accessibility option to reduce motion )

## Updating toolbar status
To accurately assess the current attributes, and determine which toggles should be highlighed for the current selection, this code uses the ```selection.attributes``` property, and avoids use of a probe to create an array of all containers.

---

# Miscellaneous Notes

I have noticed that when setting "Extra Large" font, as an example, then when this is made bold, the attributes no longer match "Extra Large", but only the Bold font, and thus the "Extra Large" toggle button is not highlighted. This is also the case for italic, but is not true for underline and strikethrough, both of which show the expected toggles highlighted.

The last insertion point code herein is solely for use with a future verion of the app that saves and restores data either to disk or to SwiftData. 

Ideally it would be possible to convert to and from markdown, but that likely requires maintaining a tree of the structure because of the nested nature of some of the markdown. (Tables notably).
Storing the tree and maintaining it whilst typing, and allowing seamless switching of WYSIWYG to the code table behind it (a la Wordperfect 5.1 for those that remember it) is the work of another day. 

---

I'll aim to update this code periodically as it contains some useful reference material, and I hope it's been useful for anyone reading here.

best wishes,
Andrew



