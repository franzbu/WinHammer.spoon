# LattinMellon

On macOS, there is a variety of tools for resizing and moving windows using mouse and keyboard and thus saving the time of having to grab onto edges or corners of windows. However, none of these tools have satisfied me, be it for the lack of fluency or for functional limitations. 

The tool SkyRocket by dbalatero, which uses a transparent canvas for addressing the already mentioned lack of fluency other tools are hampered with, has a solid foundation. Eventually, two things left me wanting, though. The first was the limitation of balatero's tool to resize windows only down/right. Second, the solution with using an additional canvas solved the problem of the lack of fluency, but when moving or reducing the size of a window, the canvas prevents precise window positioniong.

The fork of SkyRocket in this repository, also named SkyRocket, resolves the first issue; windows can be resized all directions with that tool.

LattinMellon also does away with the second issue, namely to having to accept the limitations of using an overlaying canvas. This tool is still in early development state; therefore, the occational hiccup is possible.

LattinMellon can also be used for automatic resizing. You can choose the grid size of the screen, see also 'Usage' below. You best try it out; its intuitive approach should be mostly self-explanatory.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Nevertheless, the animations still show what you can do with this tool.

Manual resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMellon.gif" />


Automatic resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMallon_wm2.gif" />

              

## Installation

This tool requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install LattinMellon.spoon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'LattinMellon.spoon'. 

Alternatively, you can simply paste the following line into a terminal window and press enter:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/LattinMellon.spoon.git ~/.hammerspoon/Spoons/LattinMellon.spoon

```

## Usage

Once you've installed LattinMellon, add this to your `~/.hammerspoon/init.lua` file:

```lua
local LattinMellon = hs.loadSpoon("LattinMellon")

LattinMellon:new({
  -- How much space (in percent) in the middle of each of the four window-margins do you want to reserve for limiting
  -- resizing windows to horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 30,

  -- window manager - choose the size of the grid:
  gridX = 3,
  gridY = 3,

  -- modifier(s) to hold to move a window:
  -- moveModifiers = {'ctrl', 'shift'},
  moveModifiers = { 'alt' },

  -- mouse button to hold to move a window:
  moveMouseButton = 'left',

  -- modifier(s) to hold to resize a window:
  -- resizeModifiers = {'ctrl', 'shift'},
  resizeModifiers = { 'alt' },

  -- mouse button to hold to resize a window:
  resizeMouseButton = 'right',

  -- modifiers to be pressed in addition to moveModifiers
  -- to access additional layers of window positioning and resizing:
  modifierLayerTwo = { 'alt', 'ctrl' },
  modifierLayerThree = { 'alt', 'ctrl', 'cmd' },
  modifierLayerFour = { 'alt', 'ctrl', 'cmd', 'shift' }, -- hyper key
})
```

### Moving

To move a window, hold your `moveModifiers` down, then click `moveMouseButton` and drag the window.

### Resizing

To resize a window, hold your `resizeModifiers` down, then click `resizeMouseButton` and drag the window.

To have the additional possibility to resize windows only horizontally and vertically, enable this functionality by adjusting the option 'margin' to your liking: '30' signifies that 30 percent of the window (15 precent left and right around the middle of each border) is reserved for horizontal-only and vertical-only resizing.


```lua
 +---+---+---+
 | ↖ | ↑ | ↗ |
 +---+---+---+
 | ← | M | → |
 +---+---+---+
 | ↙ | ↓ | ↘ |
 +---+---+---+
```

At the very center of the window there is an erea (M), the size of which depends on the size of the margin for horizontal-only and vertical-only resizing, where you can move the window by pressing the same modifier key and the same mouse button as for resizing. If the margin is set to 0, this area is disabled.

For automatic resizing and positioning of a window, simply move one third or more of the window beyond the left, right, or bottom borders of the screen. Depending on the set grid size, the window snaps into the desired spot.

Version 0.6 intruduces additional modifier keys, which are defined in Hammerspoon's 'init.lua' (otherwise LattinMellon defaults back to the modifiers stated in the exemplary 'init.lua' section above). Using the different layers of modifier keys leads to the following results:

* All layers, starting with the moveModifiers and resizeModifiers, up to modifierLayerFour, can be used for resizing and moving the window within the screen; the different layers lead to a different result - depending on the modifier key(s) pressed - once windows are moved beyond one of the sreen boundaries. 

* Layer one (moveModifier, resizeModifier):
  * window moved past left/right boundaries of screen: depending on the size of the grid established in 'init.lua', windows snap into the first/last column of the screen. The vertical positioning depends on the position of the cursur when moving the window beyond the screen boundary.
  * window moved past bottom boundary of screen: windows snap into full height; width depends on grid size.

* Layer two:
  * left/right: windows snap into second/penultimate column of the screen.
  * bottom: windows snap into full height; width is double of layer one.
 
* Layer three:
  * left/right: window snaps into 2x2 grid, starting from the position where the cursor is moved beyond the screen boundary.
  * bottom: window snaps into with of grid and half of the size of the screen (bottom)
 
* Layer four:
  * left/right: window snaps into left/right half of the screen
  * bottom: same as with layer three, but top half


### Disabling moving/resizing for applications

You can disable move/resize for any application by adding it to the `disabledApps` option:

```lua
LattinMellon:new({
  -- How much space (in percent) in the middle of each of the four window-margins do you want to reserve for limiting 
  -- resizing windows to horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 30,

  -- ...

  -- Applications that cannot be resized:
  disabledApps = {"Alacritty"},
})
```

