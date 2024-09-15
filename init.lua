require('hellfred.hellfred-bootstrap')



SpoonInstall = hs.loadSpoon("SpoonInstall")

---[[ -- autosave
-- autoatically reload configuration when folder changes, e.g., when saving init.lua
--- http://www.hammerspoon.org/go/#fancyreload
function reloadConfig(files)
  doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
--]]

--[[
hs.hotkey.bind("cmd", "r", function()
  hs.reload()
end)
--]]

local hyper = { 'shift', 'ctrl', 'alt', 'cmd' }

-- window manager: 2x2 grid
hs.window.animationDuration = 0

hs.hotkey.bind("cmd", "1", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind("cmd", "2", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind("cmd", "3", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind("cmd", "4", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 2
  f.y = max.h / 2
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind("cmd", "5", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind("cmd", "6", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.h / 2
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)


-- VPN
-- PIA Austria
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "a", function()
  os.execute("/usr/local/bin/piactl set region austria", true) -- original: hs.execute
  os.execute("/usr/local/bin/piactl connect", true)
end)

-- PIA Switzerland
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "s", function()
  os.execute("/usr/local/bin/piactl set region switzerland", true)
  os.execute("/usr/local/bin/piactl connect", true)
end)

-- PIA Germany streaming
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "g", function()
  os.execute("/usr/local/bin/piactl set region de-germany-streaming-optimized", true)
  os.execute("/usr/local/bin/piactl connect", true)
end)

-- PIA UK streaming
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "u", function()
  os.execute("/usr/local/bin/piactl set region uk-streaming-optimized", true)
  os.execute("/usr/local/bin/piactl connect", true)
end)

-- PIA disconnect
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "d", function()
  os.execute("/usr/local/bin/piactl disconnect", true)
end)


-- moving, resizing, and managing of windows
---[[ -- LattinMellon.spoon
local LattinMellon = hs.loadSpoon("LattinMellon")
LattinMellon:new({
  -- How much space (in percent) in the middle of each of the four window-margins do you want to reserve for limiting
  -- resizing windows to horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 20,

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

  -- modifier to be pressed in addition to moveModifiers
  -- to access additional layers of window positioning and resizing:
  modifierLayerTwo = { 'alt', 'ctrl' }, -- 'shift',
  modifierLayerThree = { 'alt', 'ctrl', 'cmd' }, -- 'ctrl',
  modifierLayerFour = { 'alt', 'ctrl', 'cmd', 'shift' }, -- hyper key
})


--[[ -- SkyRocket.spoon
local SkyRocket = hs.loadSpoon("SkyRocket")

SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,

  -- How much space (in percent) in the middle of each of the four borders of the windows do you want to reserve for limiting
  -- resizing windows only horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 30,

  -- Which modifiers to hold to move a window?
  moveModifiers = {'ctrl'},

  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'ctrl'},

  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'right',
})
--]]


-- dealing with spaces (yabai in the past)
hs.hotkey.bind(hyper, "a", function() -- previous space (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m space --focus prev || /opt/homebrew/bin/yabai -m space --focus last")
  hs.eventtap.keyStroke({ "ctrl" }, tostring(getNumberSpaceLeft()))
end)

hs.hotkey.bind(hyper, "s", function() -- next space (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m space --focus next || /opt/homebrew/bin/yabai -m space --focus first")
  hs.eventtap.keyStroke({ "ctrl" }, tostring(getNumberSpaceRight()))
end)

hs.hotkey.bind(hyper, "q", function() -- move active window to previous space and switch there (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m window --space prev --focus || /opt/homebrew/bin/yabai -m window --space last --focus")
  win = hs.window.focusedWindow()
  hs.spaces.moveWindowToSpace(win, getUUIDSpaceLeft(), true)
  hs.eventtap.keyStroke({ "ctrl" }, tostring(getNumberSpaceLeft()))
  hs.timer.doAfter(0.1, function()
    win:focus()
  end)
end)

hs.hotkey.bind(hyper, "w", function() -- move active window to next space and switch there (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m window --space next --focus || /opt/homebrew/bin/yabai -m window --space first --focus")
  win = hs.window.focusedWindow()
  hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), getUUIDSpaceRight(), true)
  hs.eventtap.keyStroke({ "ctrl" }, tostring(getNumberSpaceRight()))
  hs.timer.doAfter(0.1, function()
    win:focus()
  end)
end)

hs.hotkey.bind(hyper, "d", function() -- move active window to previous space (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m window --space prev || /opt/homebrew/bin/yabai -m window --space last")
  hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), getUUIDSpaceLeft(), true)
end)

hs.hotkey.bind(hyper, "f", function() -- move active window to next space (incl. cycle)
  -- os.execute("/opt/homebrew/bin/yabai -m window --space next || /opt/homebrew/bin/yabai -m window --space first")
  hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), getUUIDSpaceRight(), true)
end)


function getUUIDSpaceRight()
  local sp = hs.spaces.allSpaces()
  local activeSpace = hs.spaces.activeSpaceOnScreen()
  local s
  local gotoSpace
  for i, v in pairs(sp) do
    s = v
  end
  for k, v in pairs(s) do
    if v == activeSpace then
      if k < #s then
        gotoSpace = s[k + 1]
      else
        gotoSpace = s[1]
      end
    end
  end
  return gotoSpace
end

function getUUIDSpaceLeft()
 local sp = hs.spaces.allSpaces()
  local activeSpace = hs.spaces.activeSpaceOnScreen()
  local s
  local gotoSpace
  for i, v in pairs(sp) do
    s = v
  end
  for k, v in pairs(s) do
    if v == activeSpace then
      if k > 1 then
        gotoSpace = s[k - 1]
      else
        gotoSpace = s[#s]
      end
    end
  end
  return gotoSpace
end

function getNumberSpaceRight()
  local sp = hs.spaces.allSpaces()
  local activeSpace = hs.spaces.activeSpaceOnScreen()
  local s
  local gotoSpace
  for i, v in pairs(sp) do
    s = v
  end
  for k, v in pairs(s) do
    if v == activeSpace then
      if k < #s then
        gotoSpace = k + 1
      else
        gotoSpace = 1
      end
    end
  end
  return gotoSpace
end

function getNumberSpaceLeft()
  local sp = hs.spaces.allSpaces()
  local activeSpace = hs.spaces.activeSpaceOnScreen()
  local s
  local gotoSpace
  for i, v in pairs(sp) do
    s = v
  end
  for k, v in pairs(s) do
    if v == activeSpace then
      if k > 1 then
        gotoSpace = k - 1
      else
        gotoSpace = #s
      end
    end
  end
  return gotoSpace
end


--]] -- test and info
-- hs.notify.new({ title = "Hammerspoon", informativeText = "max.h: " .. max.h }):send()
-- hs.alert.show("max.h: " .. max.h)
-- hs.notify.new({ title = "Hammerspoon", informativeText = "Hello World" }):send()
-- trigger keystroke: hs.eventtap.keyStroke({"cmd"}, "1") -- window manager: left half -- hs.eventtap.keyStroke({ "ctrl", "fn" })
-- win:move({ dx, dy }, nil, false, 0)

--[[
    for i,v in pairs('table') do
      print(i,v)
    end

    hs.timer.doAfter(0.3, function()
    end
--]]

--[[
    moveModifiersSecondMod = table.copy(self.moveModifiers) -- self.moveModifiers not to be changed
    table.insert(moveModifiersSecondMod, secondMod)

    moveModifiersThirdMod = table.copy(moveModifiersSecondMod) -- self.moveModifiers not to be changed
    table.insert(moveModifiersThirdMod, thirdMod)


    for i,v in pairs(moveModifiersFourthMod) do
      print(i,v)
    end
    --]]

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "r", function()
  hs.eventtap.keyStroke({ "ctrl" }, '1')
end
)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", function()

end
)



hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "u", function()
  hs.osascript.applescript('tell application "System Events" to key code 46 using command down')
end
)


hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "i", function()
  local function handleKeyEvent(event)
    local keyCode = event:getKeyCode()
    if keyCode == hs.keycodes.map["d"] then
      hs.alert.show("key:")
    end
    return false
  end

  keyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, handleKeyEvent)
  keyWatcher:start()
end
)


-- show clock
--hs.loadSpoon("AClock")
SpoonInstall:andUse("AClock")
hs.hotkey.bind(hyper, "C", function()
  spoon.AClock:toggleShow()
end)


-- move window
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x - 10
  win:setFrame(f)
end)
