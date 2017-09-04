# Changelog

`git log` is another good way to peer into the innards of this repository.



# 7.3 series

## 7.3.0.5

- Implemented #6 - Configuration


## 7.3.0.4

- Fixed #1 - Cursor doesn't line up with active line


## 7.3.0.3

- Re-enabled the modules I disabled for testing.
  -  Whoops.
  

## 7.3.0.2

- `_DevPad.GUI.Editor.lua` had its style aggressively changed.
- Slightly-brightened the current line's highlighting.
- Fixed #1 - Cursor doesn't line up with active line
- Font size can now be changed in steps of 1 (down from 2)
  -  The fix for #1 was a scaling issue, and this is meant to make up for the side-effect of enlarged text.


## 7.3.0.1

- Fixed #2 - PlaySound errors
  -  7.3.0 introduced PlaySound() changes.
  -  Referenced https://www.townlong-yak.com/framexml/ptr/SoundKitConstants.lua
