# LattinMellon

LattinMellon is a window manager for macOS (tested in macOS Sequoia and Sonoma). With LattinMellon, windows can be snapped into dynamically changing grid positions with a flick of your mouse. Windows can also be resized and moved without having to position your mouse pointer; any area within the window will do. 

As an optional feature, handling spaces with LattinMellon using AeroSpace can be enabled. With it LattinMellon can also move windows to other spaces (also called workspaces); more below in the section 'Advanced Features'.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Be also aware that the animations show an earlier stage of development; with the most recent version, indicators at the borders of the screen guide the positioning and resizing of windows.


* Automatic window resizing and positioning

<img src="https://github.com/franzbu/LattinMellon.spoon/blob/main/doc/demo2.gif" />

* Manual window resizing and positioning

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


```ruby
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

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use  `modifier1` or `modifier2`. However, once a window is moved beyond the screen borders (10 - 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* `modifier1`: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* `modifier2`: 
  * The difference to `modifier1` is that your screen has an underlying 3x3 grid. This means that windows snap into the left column of the 3x3 grid when dragged beyond the left screen border and into the right column when dragged beyond the right screen border. If `modifier2` is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, the screen borders are highlighted in order to indicate where to drag the window for using two grid positions rather than one. 


## Advanced Features

### Spaces

As has been mentioned, AeroSpace can be installed (https://nikitabobko.github.io/AeroSpace/guide) in order to enable LattinMellon to handle spaces. 

To use AeroSpace in LattinMellon, the layout in AeroSpace needs to be set to 'floating', so the following section needs to be added to the top of AeroSpace's config file 'aerospace.toml':

```toml
[[on-window-detected]]
check-further-callbacks = true
run = 'layout floating'
```

The file 'aerospace.toml' can be left like this for now; however, it can be sensible to do additional finetuning, e.g., where the cursor is positioned after moving to another space, at a later stage.

After installing AeroSpace, LattinMellon can be authorized to move windows to spaces by adding the following option to your 'init.lua':

```lua
local LattinMellon = hs.loadSpoon("LattinMellon")

LattinMellon:new({

  ...

  -- Handle spaces from within LattinMellon:
  useSpaces = true,
})
```

To move a window to a different space, you can use the keyboard shortcuts defined in your 'aerospace.toml', and you can also use LattinMellon by simply dragging 80 percent or more of the window beyond the left/right screen border in order to move the window to the previous/next (work-) space. This area of '80 percent or more' can be changed with the option 'ratioSpaces = 0.x' in 'init.lua'. A value of '1' is equivalent with disabling moving windows to spaces using LattinMellon, while a value of '0' moves windows to the other (work-) space if they are even moved only slightly beyond the screen border; this at the same time practically leads to eliminating the area for automatic positioning and resizing of windows and thus disables this feature within LattinMellon.

There is an additional feature regarding moving windows to different (work-) spaces: if you release the modifier button before releasing the left mouse button, LattinMellon switches to the (work-) space the window has moved to; otherwise LattinMellon stays on the current (work-) space.

In case you'd like to additionally use Hammerspoon to handle your (work-) spaces, simply add the following lines to your 'init.lua'; adjust the keys to your liking:

```lua
local hyper = { 'shift', 'ctrl', 'alt', 'cmd' } -- CapsLock, Karabiner Elements

hs.hotkey.bind(hyper, "a", function() -- switch to prev space
  aerospace({'workspace', '--wrap-around', 'prev'})

hs.hotkey.bind(hyper, "s", function() -- switch to next space
  aerospace({'workspace', '--wrap-around', 'next'})
end)

hs.hotkey.bind(hyper, "q", function() -- move active window to prev space and switch there
  aerospace({'move-node-to-workspace', '--wrap-around', 'prev'})
  hs.timer.doAfter(0.1, function()
    aerospace({'workspace', '--wrap-around', 'prev'})
  end)

end)

hs.hotkey.bind(hyper, "w", function() -- move active window to next space and switch there
  aerospace({'move-node-to-workspace', '--wrap-around', 'next'})
  hs.timer.doAfter(0.1, function()
    aerospace({'workspace', '--wrap-around', 'next'})
  end)
end)

hs.hotkey.bind(hyper, "d", function() -- move active window to prev space
  aerospace({'move-node-to-workspace', '--wrap-around', 'prev'})
end)

hs.hotkey.bind(hyper, "f", function() -- move active window to next space
  aerospace({'move-node-to-workspace', '--wrap-around', 'next'})
end)

function aerospace(args)
  hs.task.new("/opt/homebrew/bin/aerospace", function(ud, ...)
    hs.inspect(table.pack(...))
    return true
  end, args):start()
end

```

### Change Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option 'margin'. The standard value is 30 percent. Changing it to 0 results in deactivating this options, changing it to 100 results in deactivating resizing. Any value in between 0 and 100 has both options enabled in the respective areas.

```lua
LattinMellon:new({

  -- ...

  -- Adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 20,
})
```



### Disabling Moving and Resizing for Certain Applications

You can disable move/resize for any application by adding it to the `disabledApps` option:

```lua
LattinMellon:new({

  -- ...

  -- Applications that cannot be resized:
  disabledApps = {"Alacritty"},
})
```

