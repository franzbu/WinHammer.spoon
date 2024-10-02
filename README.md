# WinHammer

The goal of managing windows on your desktop is to adjust the size and position of any window according to your workflow in the easiest and fastest way possible, be it on the current screen or on 'virtual desktops', so called spaces. In other words: the user should have to invest the least possible energy to get their work environment set up exactly the way they want it. 

WinHammer is aiming to achieve that in your macOS environment, and it uses the power and flexibility of Hammerspoon to get there.

WinHammer uses a dynamic approach for managing windows on screen, i.e., windows can be snapped into positions of dynamically changing grid sizes with a keyboard shortcut or a flick of your mouse. Doing so, windows can be moved without having to position your cursor; any area within the window will do.

For handling spaces, WinHammer - due to limitations of macOS' built-in space manager - uses AeroSpace, the original purpose of which is automatic window management as a tiling manager. WinHammer, however, following its own philospophy regarding window management, uses AeroSpace solely for its implementation of spaces. 

In case you are not familiar with spaces, you can think of them as similar to having a multi-display arrangement in the sense of that every space has its own work environment with its own set of windows. Where an arrangement of displays and spaces differ, though, is that you cannot look at more than one space at a time. However, an advantage of spaces is that you don't have to move your head around, as, metaphorically speaking, you make your displays swap with a keyboard shortcut or a flick of your mouse.

As spaces are an additional but not essential feature of sophisticated desktop operating systems such as macOS, so are spaces an additional but not essential feature of WinHammer. WinHammer can perfectly be used for managing your windows on a single space. Should you be a seasoned user of spaces or want to give this feature a try, have a look at 'Advanced Features' below on how to enable it.

The animated GIFs below don't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. The animation only shows the automatic resizing and positioning on one screen; this applies to all your spaces in case you have more than one. Also the moving windows to different spaces or switching spaces is not part of the animation.

* Automatic window resizing and positioning

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/demo2.gif" />

## Installation of WinHammer

WinHammer requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install WinHammer, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'WinHammer.spoon'. 

Alternatively, you can simply execute the following line from a terminal window:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/WinHammer.spoon.git ~/.hammerspoon/Spoons/WinHammer.spoon

```

## Usage

Once you've installed WinHammer, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local WinHammer = hs.loadSpoon("WinHammer")

WinHammer:new({

  -- modifier(s) for managing your windows, also a group of modifiers such as { 'alt', 'cmd' } is possible:
  modifier1 = { 'alt' },
  modifier2 = { 'ctrl' },

})
```

### Manual Moving and Positioning

To move a window, hold your 'modifier1' or 'modifier2' key(s) down, then click the left mouse button and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond the 10-percent-margin, things are getting interesting because then window management with automatic resizing and positioning comes into play.


### Automatic Resizing and Positioning 

For automatic resizing and positioning of a window, you simply have to move between 10 and 80 percent of the window beyond the left, right, or bottom (no upper limit here) borders of your screen using your left mouse button. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use  'modifier1' or 'modifier2'. However, once a window is moved beyond the screen borders (10 - 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'modifier1' is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If 'modifier2' is released before the left mouse button, the window will snap into the middle.
 
* The moment dragging of a window starts, indicators appear to guide the user as to where to drag the window for different window managing scenarios.

All this is been implemented with the goal of being as intuitive as possible; therefore, you shoud be able to build up your muscle memory quickly.


## Advanced Features

### Spaces

If you also want to handle spaces with WinHammer, AeroSpace has to be installed (https://nikitabobko.github.io/AeroSpace/guide). 

To use AeroSpace in WinHammer, the layout in AeroSpace has to be set to 'floating', so the following section needs to be added at the top of AeroSpace's config file 'aerospace.toml':

```toml
[[on-window-detected]]
check-further-callbacks = true
run = 'layout floating'
```

No further adjustments to the file 'aerospace.toml' are necessary; still, some additional finetuning might come in handy, for example, you can enable the automatic start of AeroSpace at login (start-at-login = true) or determine where the cursor is positioned after moving to another space.

After installing AeroSpace, the space feature can be enabled in WinHammer by adding the following option to your 'init.lua':

```lua
WinHammer:new({

  ...

  -- spaces:
  useSpaces = true,
})
```

In order to move a window to another (work-) space, besides using the keyboard shortcuts defined in your 'aerospace.toml', you can do so with WinHammer by simply dragging 80 percent (= 0.8) or more of the window beyond the left or right border of the screen. The size of the area (the standard option is 80 percent or more) can be altered with the option 'ratioSpaces = 0.x' in 'init.lua'. A value of '1' is equivalent to disabling moving windows to spaces using WinHammer, while a value of '0' moves windows to the other (work-) space if they are even moved only slightly beyond the screen border; this at the same time practically leads to eliminating the area for automatic positioning and resizing of windows and thus disables this feature within WinHammer.

There is an additional feature regarding moving windows to different (work-) spaces: if you release the modifier key before releasing the left mouse button, WinHammer 
stays on the current space; otherwise it switches to the (work-) space along with the moved window.

### Use Keyboard Shortcuts to handle Spaces

In case you would like to additionally use keyboard shortcuts to handle your (work-) spaces, you can add the following lines to Hammerspoon's 'init.lua':

```lua
WinHammer:new({

  ...

  -- spaces:
  useSpaces = true,
  ratioSpaces = 0.8, -- optional
  modifier3 = { 'alt', 'ctrl', 'cmd', 'shift' }, -- hyper key (Karabiner Elements)
  prevSpace = 'a',
  nextSpace = 's',
  moveWindowPrevSpace = 'd',
  moveWindowNextSpace = 'f',
  moveWindowPrevSpaceSwitch = 'q',
  moveWindowNextSpaceSwitch = 'w',
})
```
Here, 'modifier3' and 'prevSpace', for instance, are used to switch to the previous (work-) space; 'modifier3' and 'moveWindowNextSpaceSwitch' to move the active window to the next (work-) space and switch there.

### Cycling through Windows

WinHammer also allows cycling through all windows of the current (work-) space on the one hand and all windows on all (work-) spaces on the other: 'modifier3' and 'escape' switches between all windows of the current (work-) space, and 'modifier3' and 'tab' switches between the windows on all (work-) spaces. 

The order of switching between the windows is set according to 'hs.window.sortByFocused', i.e., windows are sorted in order of focus received, most recent first. The standard modifier key for cycling through windows is 'modifier1'; in case you would like to change that, you can add the option 'cycleModifier' to your 'init.lua'.

```lua
WinHammer:new({

  ...

  -- cycle through windows of current workspace and all windows
  cycleModifier = { "alt" }
})
```

### Disable Moving and Resizing for Certain Applications

You can disable move/resize for any application by adding it to the 'disabledApps' option:

```lua
WinHammer:new({

  -- ...

  -- applications that cannot be resized:
  disabledApps = {"Alacritty"},
})
```

## Additional Features

### Manual Resizing

Similar to manual moving, manual resizing of windows can be achieved by positioning the cursor in virtually any area of the window. Be aware, though, that windows of certain applications, such as LosslessCut or Kdenlive, can behave in a stuttering and sluggish way when being resized. That being said, resizing works well with the usual suspects such as Safari, Google Chrome, Finder, and so on.

In order to enable manual resizing, add the following option to your 'init.lua':

```lua
WinHammer:new({

  ...

  -- enable resizing:
  resize = true,
})
```

To manually resize a window, hold your 'modifier1' or 'modifier2' key(s) down, then click the right mouse button in any part of the window and drag the window. If a window is resized beyond the borders of the screen, it will automatically snap back within the limits of the screen.

To have the additional possibility of precisely resizing windows horizontally-only and vertically-only, 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing. The size of this area can be adjusted; for more information see below.

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/resizing.png" width="200">

At the center of the window there is an erea (M) where you can also move the window by pressing the right mouse button. 


* Manual window resizing and positioning

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/demo1.gif" />



### Manual Resizing of Windows - Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option 'margin'. The standard value is 0.3, which corresponds to 30 percent. Changing it to 0 results in deactivating this options, changing it to 1 results in deactivating resizing.

```lua
WinHammer:new({

  -- ...

  -- adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 0.2,
})
```


         
