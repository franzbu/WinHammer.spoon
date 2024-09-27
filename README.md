# WinHammer

WinHammer is a window manager for macOS that combines keyboard and mouse operations to manage windows and spaces in an efficient way. 

There is no need to pre-define any kind of grid size, as windows can be snapped into positions of a dynamically changing grid size with a flick of your mouse. Windows can also be moved without having to position your cursor; any area within the window will do. Optionally, windows can be resized using the right mouse button. 

Also as an optional feature, WinHammer can handle spaces using AeroSpace (AeroSpace irons out some of macOS' space manager's shortages, such as slow animations or the need to at least partly disable System Integrity Protection for increased functionality). With this feature activated, WinHammer can move windows to other spaces (also called workspaces) choosing on-the-fly whether to move there along with the window or whether to stay on the current space - more below in the section 'Advanced Features'.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected.

* Automatic window resizing and positioning

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/demo2.gif" />

* Manual window resizing and positioning

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/demo1.gif" />
         

## Installation

This tool requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install WinHammer, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'WinHammer.spoon'. 

Alternatively, you can simply paste the following line into a terminal window and execute it:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/WinHammer.spoon.git ~/.hammerspoon/Spoons/WinHammer.spoon

```

## Usage

Once you've installed WinHammer, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local WinHammer = hs.loadSpoon("WinHammer")

WinHammer:new({

  -- modifier(s) to hold to move (left mouse button) or resize (right mouse button) a window:
  modifier1 = { 'alt' }, -- also a group of modifiers such as { 'alt', 'cmd' } is possible
  modifier2 = { 'ctrl' },

})
```

### Manual Moving

To move a window, hold your 'modifier1' or 'modifier2' key(s) down, then click the left mouse button and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things start to get interesting because then window management with automatic resizing and positioning comes into play - more about that in a minute.


### Manual Resizing

Manual resizing is an optional feature, as windows of certain applications, such as LosslessCut or Kdenlive can behave in a stuttering and sluggish way when being resized. It is for each user to decide whether the resizing feature should be enabled. That being said, the feature works well here on standard applications such as Safari, Google Chrome, Finder, Terminal, iTerm2 and many more.

In order to enable manual resizing, add the following option to your 'init.lua' (whether this option is set to 'false' or not added makes no difference):

```lua
WinHammer:new({

  ...

  -- Windows can be resized:
  resize = true,
})
```

To manually resize a window, hold your 'modifier1' or 'modifier2' key(s) down, then click the right mouse button in any part of the window and drag the window. If a window is resized beyond the borders of the screen, it will automatically snap back within the limits of the screen.

To have the additional possibility of precisely resizing windows horizontally-only and vertically-only, 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing. The size of this area can be adjusted; for more information see section 'Manual Resizing of Windows - Margin' in 'Advanced Features'.

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/resizing.png" width="200">

At the center of the window there is an erea (M) where you can also move the window by pressing the right mouse button. 


### Automatic Positioning and Resizing

For automatic resizing and positioning of a window, you simply have to move between 10 and 80 percent of the window beyond the left, right, or bottom (no upper limit here) borders of your screen using your left mouse button. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use  'modifier1' or 'modifier2'. However, once a window is moved beyond the screen borders (10 - 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long parts: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'modifier1' is that your screen has an underlying 3x3 grid. This means that windows snap into the left column of the 3x3 grid when dragged beyond the left screen border and into the right column when dragged beyond the right screen border. If 'modifier2' is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, indicators appear to guide the user as to where to drag the window for different window managing scenarios, allowing additional grid sizes. 


## Advanced Features

### Spaces

As has been mentioned, if you want to also handle spaces with WinHammer, AeroSpace can optionally be installed (https://nikitabobko.github.io/AeroSpace/guide). 

To use AeroSpace in WinHammer, the layout in AeroSpace has to be set to 'floating', so the following section needs to be added at the top of AeroSpace's config file 'aerospace.toml':

```toml
[[on-window-detected]]
check-further-callbacks = true
run = 'layout floating'
```

The file 'aerospace.toml' can stay like this; however, you might be interested in some additional finetuning, for example, you can enable the automatic start of AeroSpace at login (start-at-login = true) or determine where the cursor is positioned after moving to another space.

After installing AeroSpace, WinHammer can be told to move windows to spaces by adding the following option to your 'init.lua':

```lua
WinHammer:new({

  ...

  -- Handle spaces from within WinHammer:
  useSpaces = true,
})
```

In order to move a window to another (work-) space, besides using the keyboard shortcuts defined in your 'aerospace.toml', you can also use WinHammer by simply dragging 80 percent (= 0.8) or more of the window beyond the left or right border of the screen. The area of '80 percent or more' can be altered with the option 'ratioSpaces = 0.x' in 'init.lua'. A value of '1' is equivalent with disabling moving windows to spaces using WinHammer, while a value of '0' moves windows to the other (work-) space if they are even moved only slightly beyond the screen border; this at the same time practically leads to eliminating the area for automatic positioning and resizing of windows and thus disables this feature within WinHammer. The option 'ratioSpaces = 0.8' corresponds to the pre-set value of 80 percent (to keep it at that value, you do not need to do anything, only if you want a different value you can add the corresponding line).

There is an additional feature regarding moving windows to different (work-) spaces: if you release the modifier key before releasing the left mouse button, WinHammer 
stays on the current space; otherwise it switches to the (work-) space the window has moved to.

In case you would like to additionally use Hammerspoon to handle your (work-) spaces, you can add the following lines to your 'init.lua'; adjust the keys to your liking:

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

### Manual Resizing of Windows - Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option 'margin'. The standard value is 0.3, which corresponds to 30 percent. Changing it to 0 results in deactivating this options, changing it to 1 results in deactivating resizing.

```lua
WinHammer:new({

  -- ...

  -- Adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 0.2,
})
```



### Disable Moving and Resizing for Certain Applications

You can disable move/resize for any application by adding it to the 'disabledApps' option:

```lua
WinHammer:new({

  -- ...

  -- Applications that cannot be resized:
  disabledApps = {"Alacritty"},
})
```

