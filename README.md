# 💫 LattinMellon

It should be stressed that this tool is not for everybody and certainly not for the average user. Only go for it if you are accustomed to, or at the very least interested in using your mouse less and your keyboard more in order to get the management of the windows on your screen(s) done more efficiently.

On macOS, there is a variety of tools for resizing and moving windows getting the keyboard involved, saving the time of having to time-consumingly grab onto edges or corners of windows. However, none of these tools have satisfied me, partly for the lack of fluency and mostly for functional limitations. 

LattinMellon has been inspired by dbalatero's tool SkyRocket, which uses a transparent canvas for addressing the already mentioned lack of fluency many tools are hampered with. SkyRocket has some limitations, though. The first is the limitation to resize windows only down/right. Second, the idea of using an additional canvas in SkyRocket solves the problem regarding the lack of fluency, but when moving or reducing the size of a window, the canvas prevents precise window positioning.

LattinMellon addresses these shortcomings and adds some useful window management; besides moving and resizing windows by placing the cursor in any part of them, LattinMellon can also be used for automatic positioning and resizing of windows with a simple flick of the mouse. You best try it out; its intuitive approach is mostly self-explanatory.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Nevertheless, the animations still give you an idea of how this tool works.

Manual resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMellon.gif" />


Automatic resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/LattinMallon_wm2.gif" />

              

## Installation

This tool requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install LattinMellon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'LattinMellon.spoon'. 

Alternatively, you can simply paste the following line into a terminal window and execute it:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/LattinMellon.spoon.git ~/.hammerspoon/Spoons/LattinMellon.spoon

```

## Usage

Once you've installed LattinMellon, add this to your `~/.hammerspoon/init.lua` file:

```lua
local LattinMellon = hs.loadSpoon("LattinMellon")

LattinMellon:new({
  -- How much space (in percent) in the middle of each of the four window-margins do you want to reserve for limiting
  -- resizing windows to horizontally and vertically? 0 disables this function, 100 disables diagonal resizing:
  margin = 30,

  -- modifier(s) to hold to move (left mouse button) or resize (right mouse button) a window:
  moveAndResizeModifier = { 'alt' },

  -- additional modifiers:
  OMmodifier = { 'alt', 'ctrl' },
  TATmodifier = { 'alt', 'ctrl', 'cmd' },
  SATmodifier = { 'alt', 'ctrl', 'cmd', 'shift' }, -- hyper key
})
```

### Manual Moving

To move a window, hold your `moveAndResizeModifier`, OM-, TAT-, or SATmodifier key(s) down, then click the left mouse button and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things start to get interesting because then window management with automatic resizing and positioning come into play - more about that in a minute.


### Manual Resizing

To manually resize a window, hold your `moveAndResizeModifier`, OM-, TAT-, or SATmodifier key(s) down, then click the right mouse button in any part of the window and drag the window. If a window is resized beyond the borders of the screen, it will automatically snap back within the limits of the screen.

To have the additional possibility to precisely resize windows horizontally-only and vertically-only, the option 'margin' can be set to a value higher than '0'. '30', for example, signifies that 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing.


```lua
 +---+---+---+
 | ↖ | ↑ | ↗ |
 +---+---+---+
 | ← | M | → |
 +---+---+---+
 | ↙ | ↓ | ↘ |
 +---+---+---+
```

At the very center of the window there is an erea (M), the size of which depends on the size of the just described margin for horizontal-only and vertical-only resizing. In the M-area of a window, you can also move the window by pressing the resizeMouseButton. If 'margin' in 'init.lua' is set to 0, the 'M' area is disabled alongside with the horizontal-only and vertical-only resizing.


### Automatic Positioning and Resizing

For automatic resizing and positioning of a window, you simply have to move 10 percent or more of the window beyond the left, right, or bottom borders of your screen.

As long as windows are resized, or moved within the borders of the screen, it makes no difference which of the modifier keys you use. However, once a window is moved beyond the screen borders (10 or more percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* moveAndResizeModifier key: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* OMmodifier key:
  * Similar to moveAndResizeModifier key; however, imagine your screen as having an underlying 3x3 grid rather than the 2x2 grid.
 
* TATmodifier key:
  * To be added.
 
* SATmodifier key:
  * To be added.
 

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

