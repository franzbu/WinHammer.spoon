# 💫 LattinMellon

It should be stressed that this tool is not for everybody and certainly not for the average user. Only try it out if you are accustomed or interested in using your mouse less and your keyboard more in oder to get things done faster.

On macOS, there is a variety of tools for resizing and moving windows using mouse and keyboard and thus saving the time of having to grab onto edges or corners of windows. However, none of these tools have satisfied me, be it for the lack of fluency or for functional limitations. 

The tool SkyRocket by dbalatero, for example, which uses a transparent canvas for addressing the already mentioned lack of fluency other tools are hampered with, provides a solid foundation. Eventually, two things left me wanting, though. The first was the limitation of balatero's tool to resize windows only down/right. Second, the solution with using an additional canvas solved the problem of the lack of fluency, but when moving or reducing the size of a window, the canvas prevents precise window positioning.

The fork of SkyRocket in this repository, also named SkyRocket, resolves the first limitation; windows can be resized all directions with that tool.

However, LattinMellon also does away with the second limitation, namely having to use a canvas.

LattinMellon can also be used for automatic positioning and resizing of windows with a simple flick of your mouse. You best try it out; its intuitive approach is mostly self-explanatory.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Nevertheless, the animations still show what you can do with this tool.

Manual resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMellon.gif" />


Automatic resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMallon_wm2.gif" />

              

## Installation

This tool requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install LattinMellon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'LattinMellon.spoon'. 

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

### Manual Moving

To move a window, hold your `moveModifiers` or any higher level modifier key(s) down, then click `moveMouseButton` and drag the window. If a window is dragged up to ten percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the limits of the screen. If it is dragged beyond that limit, it starts getting interesting because then automatic resizing and positioning come into play - more about that below.


### Manual Resizing

To resize a window, hold your `resizeModifiers` or any higher level modifier key(s) down, then click `resizeMouseButton` and drag the window. If a window is resized beyond the borders of the screen, it will automatically snap back within the limits of the screen.

To have the additional possibility to precisely resize windows horizontally-only and vertically-only, the option 'margin' has to be set to a value higher than '0': '30', for example, signifies that 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing.


```lua
 +---+---+---+
 | ↖ | ↑ | ↗ |
 +---+---+---+
 | ← | M | → |
 +---+---+---+
 | ↙ | ↓ | ↘ |
 +---+---+---+
```

At the very center of the window there is an erea (M), the size of which depends on the size of the just described margin for horizontal-only and vertical-only resizing. In the M-part of a window, you can also move the latter by pressing the resizeMouseButton. If the margin is set to 0, the 'M' area is disabled alongside with the horizontal-only and vertical-only resizing.


### Automatic Positioning and Resizing

For automatic resizing and positioning of a window, you simply have to move one third or more of the window beyond the left, right, or bottom borders of the screen. Depending on the grid size set in 'init.lua', the window snaps into the according position and size. As has been mentioned, windows can be moved with the `moveModifiers`, `resizeModifiers` (cursor in the middle of the windows), or any of the higher level modifiers. 

As long as windows are resized, or moved within the borders of the screen, it makes no difference which one of the various modifier keys (resizeModifiers, moveModifiers, modifierLayerTwo, modifierLayerThree, modifierLayerFour) is used. However, once a window is moved beyond the screen borders (ten or more percent of the window size is beyond), different positioning and resizing scenarios take place; they are as follows:

* Layer one (moveModifier, resizeModifier):
  * If windows are moved past the left/right borders of screen: depending on the size of the grid (gridX, gridY) established in 'init.lua', windows snap into the corresponding grid position in the first/last column of the screen. The vertical grid position correlates with the position of the cursur when moving the window beyond the screen border.
  * If windows are moved past the bottom border of screen: windows snap into full height; width depends on grid size.

* Layer two:
  * left/right: windows snap into second/penultimate column of the screen.
  * bottom: windows snap into full height; width is two grids.
 
* Layer three:
  * left/right: window snaps into 2x2 grid, starting from the position where the cursor is moved beyond the screen border.
  * bottom: window snaps into width of grid and the bottom half of the size of the screen.
 
* Layer four:
  * left/right: imagine the window border divided into three equally long parts: if you cross the screen border in the middle third, the window snaps into left (or right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into occupying the respective quarter of the screen.
  * bottom: window snaps into width of grid and the top half of the size of the screen.


### Disabling moving/resizing for certain applications

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

