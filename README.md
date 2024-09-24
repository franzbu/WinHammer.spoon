# LattinMellon

LattinMellon is a window manager for macOS (tested in macOS Sequoia and Sonoma); windows can be snapped into dynamically changing grid positions with a flick of your mouse. Additionally, windows can be resized and moved without having to position your mouse pointer; any area within the window will do. An optional feature is the use of LattinMellon alongside AeroSpace; in this case windows can be moved to other spaces (called workspaces in AeroSpace) using LattinMellon.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Be also aware that the animations show an earlier stage of development; with the most recent version, indicators at the borders of the screen guide the positioning and resizing of windows.


Automatic window resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/demo2.gif" />

Manual window resizing and positioning:

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/demo1.gif" />
         

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

  -- modifier(s) to hold to move (left mouse button) or resize (right mouse button) a window:
  modifier1 = { 'alt' }, -- also a group of modifiers such as { 'alt', 'cmd' } is possible
  modifier2 = { 'ctrl' },

})
```

### Manual Moving

To move a window, hold your `modifier1` or `modifier2` key(s) down, then click the left mouse button and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things start to get interesting because then window management with automatic resizing and positioning comes into play - more about that in a minute.


### Manual Resizing

To manually resize a window, hold your  `modifier1` or `modifier2` key(s) down, then click the right mouse button in any part of the window and drag the window. If a window is resized beyond the borders of the screen, it will automatically snap back within the limits of the screen.

To have the additional possibility of precisely resizing windows horizontally-only and vertically-only, 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing.


```lua
 +---+---+---+
 | ↖ | ↑ | ↗ |
 +---+---+---+
 | ← | M | → |
 +---+---+---+
 | ↙ | ↓ | ↘ |
 +---+---+---+
```

At the very center of the window there is an erea (M) where you can also move the window by pressing the right mouse button. 


### Automatic Positioning and Resizing

For automatic resizing and positioning of a window, you simply have to move between 10 and 80 percent of the window beyond the left, right, or bottom (no upper limit here) borders of your screen using your left mouse button. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use  `modifier1` or `modifier2`. However, once a window is moved beyond the screen borders (between 10 and 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* `modifier1`: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* `modifier2`: 
  * The difference to `modifier1` is that your screen has an underlying 3x3 grid rather than a 2x2 grid. This means that windows snap into the left column of the 3x3 grid when dragged beyond the left screen border and into the right column when dragged beyond the right screen border. In both cases, if the `modifier2` key is released before the mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, the screen borders are highlighted in order to indicate where to drag the window for using two vertical grid positions rather than one. 


## Advanced options

### AeroSpace

As has been mentioned, LattinMellon can be used alongside AeroSpace (https://github.com/nikitabobko/AeroSpace). This feature can be enabled by adding the following option to 'init.lua':

```lua
local LattinMellon = hs.loadSpoon("LattinMellon")

LattinMellon:new({

  ...

  -- Should LattinMellon be used alongside AeroSpace?
  AeroSpace = true
  ratioMoveAS = 0.8

})
```
The option 'ratioMoveAS' determines how much of the window needs to be moved beyond the left or right borders of the screen for the window to be moved to the previous or next (work-) space. A value of 1 disables this function, a value of 0 would disable the automatic positioning feature of LattinMellon.

To use LattinMellon alongside AeroSpace only makes sense if the layout in AeroSpace is set to 'floating' layout. AeroSpace is thus used primarily for its excellent implemantation of spaces, or, as they are called in AeroSpace, workspaces.

To set AeroSpace to 'floating' layout, make sure aerospace.toml contains the following section:

```lua
[[on-window-detected]]
check-further-callbacks = true
run = 'layout floating'
```

To use this feature, simple drag 80 percent (if 'ratioMoveAS' is set to 0.8) or more of the window beyond the left/right screen border to move the window to the previous/next (work-) space. 

There is an additional feature: if you release the modifier button before releasing the left mouse button, LattinMellon switches to the workspace the window has moved to; otherwise LattinMellon stays on the current one.


### Change Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option 'margin'. The standard value is 30 percent. Changing it to 0 results in deactivating this options, changing it to 100 results in deactivating resizing. Any value in between 0 and 100 has both options enabled in the respective areas.

```lua
LattinMellon:new({

  -- ...

  -- Adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 20,
})
```



### Disabling moving/resizing for certain applications

You can disable move/resize for any application by adding it to the `disabledApps` option:

```lua
LattinMellon:new({

  -- ...

  -- Applications that cannot be resized:
  disabledApps = {"Alacritty"},
})
```

