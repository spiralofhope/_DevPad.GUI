# _DevPad.GUI

An 
[addon](http://blog.spiralofhope.com/?p=17845)
for 
[World of Warcraft](http://blog.spiralofhope.com/?p=2987).
The GUI component for [_DevPad](https://github.com/spiralofhope/_DevPad), a notepad for Lua scripts and mini-addons.

NOTE:  This addon requires [_DevPad](https://github.com/spiralofhope/_DevPad)

----

[source code](https://github.com/spiralofhope/_DevPad.GUI)
 · [home page](http://blog.spiralofhope.com/?p=17397)
 · [releases](https://github.com/spiralofhope/_DevPad.GUI/releases)
 · [latest beta](https://github.com/spiralofhope/_DevPad.GUI/archive/master.zip)



# Notes

- This is A fork of 
[saiket's _DevPad.GUI](https://github.com/Saiket/wow-saiket/tree/master/_DevPad.GUI).
- I am a documentation guy, not a programmer.  It is unlikely I can make any large changes.
  -  If you are a developer, I am happy to:
     -  Accept GitHub pull requests.
     -  Add you as a contributor on GitHub.
     -  Hand this project over!



# Installation

Since it's a regular addon, it's manually installed the same as every other addon would be.

1) [Download _DevPad](https://github.com/spiralofhope/_DevPad/releases) 
and
   [Download _DevPad.GUI](https://github.com/spiralofhope/_DevPad.GUI/releases) 

2) Extract them to your `Interface\AddOns` folder.

Perhaps your game is installed to one of:

  `C:\Program Files\World of Warcraft` <br />
  `C:\Program Files\World of Warcraft (x86)` 

.. and so you would extract the contents of your downloaded archive to something like:

  `C:\Program Files\World of Warcraft\_retail_\Interface\AddOns` 

.. and so you would end up with two separate folders, like:

  `C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\_DevPad` <br />
  `C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\_DevPad.GUI`

.. and inside them would be the files.  For example, you would have these two files:

  `C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\_DevPad\DevPad.toc` <br />
  `C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\_DevPad.GUI\DevPad.toc`


- [Curse blog entry on manually installing AddOns](https://support.curse.com/hc/en-us/articles/204270005)
- [Curse FAQ on manually installing AddOns](https://mods.curse.com/faqs/wow-addons#manual)


# Configuration / Usage

## Basic Usage

- `/devpad` will open the GUI.
- At the top-right of the window are icons.
- Click the `new script` icon.
- Type the name of your script.  To change a script name, `double-click` on the selected item on the left.
- Type your script on the right-window.
- Within the right-window is an icon at its top-left, for running a script.



## Intermediate Usage

See the included `usage.intermediate.markdown` for notes.



## Advanced Usage

Notes will be forthcoming.

I have created some fairly advanced scripts I'd like to add as examples.


## Updating the built-in examples

An outstanding feature is to have a separate location for example scripts, to have 
[updateable documentation](https://github.com/spiralofhope/_DevPad/issues/7).

For now, edit your `_DevPad.DefaultScripts.lua`.  Perhaps it is:

  `C:\Program Files\World of Warcraft\Interface\AddOns\_DevPad\_DevPad.DefaultScripts.lua`

Each example script will be found therein.  The 
[_DevPad changelog](https://github.com/spiralofhope/_DevPad/blob/master/changelog.markdown) 
will be kept up-to-date with changes to the example scripts.



# Problems and suggestions

([issues list](https://github.com/spiralofhope/_DevPad.GUI/issues))


### Problems

- If you seen an error, disable all addons but this one and re-test before creating an issue.
  -  If you have multiple addons installed, errors you think are for one addon may actually be for another.  No really, disable everything else.
- Search through [the issues list](https://github.com/spiralofhope/_DevPad.GUI/issues) before creating an issue.
- Always quote errors.
  -  There are several helpful addons to catch errors.  Try something like TekErr ([github](https://github.com/TekNoLogic/tekErr) &middot;  [wowinterface](http://www.wowinterface.com/downloads/info6681) &middot; [curse](https://mods.curse.com/project/103101) &middot; [curseforge](https://www.curseforge.com/projects/103101/))
- Do your best to give the exact steps you took to reproduce your problem.
  -  If this is only an occasional or unpredictable problem, then you'll need to do your best to give your opinion.


### Suggestions

- I am a documentation guy, not a programmer.  It is unlikely I can make any large changes.
- Describe your suggestion _really_ well.
- Explain why you want your suggestion.
  -  Do you _really really_ want it?
  -  Do you _need_ it?
  -  Are you currently doing something unusual or annoying which the feature would help simplify or make easier?
- Explain why other users would agree with your suggestion.
