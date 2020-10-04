# Changelog

`git log` is another good way to peer into the innards of this repository.



# 8.x - Battle for Azeroth (BfA)


## UNRELEASED retail 8.3.7.1, classic 1.13.1

Shadowlands beta testing

- Tested for Shadowlands beta 9.0.2.36086
- [SetBackdrop](https://github.com/Stanzilla/WoWUIBugs/wiki/9.0.1-Consolidated-UI-Changes#backdrop-system-changes) rough fix.
  -  Items to investigate are noted with "[Issue #29](https://github.com/spiralofhope/_DevPad.GUI/issues/29)"


## retail 8.3.0.0, classic 1.13.0

- TOC bump
- Confirmed compatibility with classic.


## 8.3.0.0

- TOC bump



## 8.2.5.1

- Style update

 
## 8.1.0.0

- TOC bump


## 8.0.1.2

- Fixed #25 - Revisit scaling
  -  Apparently fixed at Blizzard's end.
- Reformatted to convert tabs to spaces.
  -  This will make it far easier to accept pull requests.


## 8.0.1.1

- Fixed  #26 - Re-implemented linking functionality to non-script texts.



# 7.x - Legion


## 7.3.2.0

- TOC bump


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

I don't know if these version numbers map to game versions.

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
