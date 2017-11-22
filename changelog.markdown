# Changelog

`git log` is another good way to peer into the innards of this repository.



# 7.3 series

## 7.3.0.8

- Audited #19 - Investigate item linking in text areas
  -  Reverted some code to the original author's implementation.  This fixes a freeze issue.
  -  See also #23 - Reproduce linking freeze

## 7.3.0.7

- Done/implemented #19 - Investigate item linking in text areas
  -  Thanks to casualshammy for the reminder
- Began intermediate usage documentation in `usage.intermediate.markdown`


## 7.3.0.6

- Tinkered with #14 - Change the font of the main list
- Fixed list tooltip functionality:  Comments at the top of a file are shown as a tooltip when mousing over the list.


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


# saiket's earlier changelog

- 5.0.0.1
  -  Moved editor line numbering into an optional module.
- 4.3.0.1
  -  Added text coloring controls to the editor while not in Lua mode.
  -  Added an IterateChildren method to folder objects, usable as `for Child in Folder:IterateChildren() do ... end`.
  -  Folders that temporarily open while dragging a list entry now close afterwards if nothing was dropped into them.
  -  Separated list's search functionality into its own optional module.
- 4.2.0.3
  -  Added multiple undo and redo to the editor, controllable with <Ctrl+Z> and <Ctrl+Shift+Z> or left and right arrow buttons at the top-right of the window.
  -  The editor now remembers cursor positions, so you can close or swap scripts without losing your place.
- 4.2.0.2
  -  Added a new default library script named "Libs/RegisterForSave" to allow other scripts to save variables between sessions. See <_DevPad/_DevPad.DefaultScripts.lua> if you want to copy it into your existing pad.
  -  While dragging an object in the list window, folders will only expand if you hold your mouse over them briefly.
  -  Folders can now be opened and closed by simply clicking their names. Also, they now temporarily close while being dragged.
- 4.2.0.1
  -  Slash command now only prints the run script's name if more than one match was found.
  -  Added a faint line highlight to the editor.
  -  Scripts and folders can now be broadcast over the guild officer channel.
- 4.1.0.1 Fixed buggy scrollbar behavior in 4.1.
- 4.0.6.1 The Lua syntax highlighting option now also controls "raw text" mode, allowing you to see and edit UI Escape Sequences. When disabled, chat links become clickable inside the editor.
- 4.0.3.1 Initial release.
