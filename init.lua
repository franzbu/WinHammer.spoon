local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local WinHammer = {}

WinHammer.author = "Franz B. <csaa6335@gmail.com>"
WinHammer.homepage = "https://github.com/franzbu/WinHammer.spoon"
WinHammer.license = "MIT"
WinHammer.name = "WinHammer"
WinHammer.version = "0.9.2"
WinHammer.spoonPath = scriptPath()

local dragTypes = {
  move = 1,
  resize = 2,
}

local function tableToMap(table)
  local map = {}
  for _, v in pairs(table) do
    map[v] = true
  end
  return map
end

local function getWindowUnderMouse()
  --local _ = hs.application
  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

-- Usage:
--   resizer = WinHammer:new({
--     modifier1 = { 'alt' },
--     modifier2 = { 'ctrl' },
--   })

local function buttonNameToEventType(name, optionName)
  if name == 'left' then
    return hs.eventtap.event.types.leftMouseDown
  end
  if name == 'right' then
    return hs.eventtap.event.types.rightMouseDown
  end
  error(optionName .. ': only "left" and "right" mouse button supported, got ' .. name)
end

function WinHammer:new(options)
  options = options or {}
  modifier1 = options.modifier1 or { 'alt' }
  modifier2 = options.modifier2 or { 'ctrl' }
  modifier3 = options.modifier3 or { 'alt', 'ctrl', 'cmd', 'shift' }
  margin = options.margin or 0.3
  m = margin * 100 / 2

  useSpaces = options.useSpaces or false
  ratioSpaces = options.ratioSpaces or 0.8
  useResize = options.resize or false
  prevSpace = options.prevSpace or 'a'
  nextSpace = options.nextSpace or 's'
  moveWindowPrevSpace = options.moveWindowPrevSpace or 'd'
  moveWindowNextSpace = options.moveWindowNextSpace or 'f'
  moveWindowPrevSpaceSwitch = options.moveWindowPrevSpaceSwitch or 'q'
  moveWindowNextSpaceSwitch = options.moveWindowNextSpaceSwitch or 'w'
  cycleModifier = options.cycleModifier or { "alt" } 


  local resizer = {
    disabledApps = tableToMap(options.disabledApps or {}),
    dragging = false,
    dragType = nil,
    moveStartMouseEvent = buttonNameToEventType('left', 'moveMouseButton'),
    resizeStartMouseEvent = buttonNameToEventType('right', 'resizeMouseButton'),
    targetWindow = nil,
  }

  setmetatable(resizer, self)
  self.__index = self

  resizer.clickHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.rightMouseDown,
    },
    resizer:handleClick()
  )

  resizer.cancelHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseUp,
      hs.eventtap.event.types.rightMouseUp,
    },
    resizer:handleCancel()
  )

  resizer.dragHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDragged,
      hs.eventtap.event.types.rightMouseDragged,
    },
    resizer:handleDrag()
  )

  --___________ aerospace ___________
  ids = {} -- array with window IDs on current WS -> aerospace()
  windows_all = {} -- table with all windows on all WS in order of focused last
  copy_windows_all = {} -- fb: local?
  nextToFocus = 2 

  -- watchdogs
  filter = hs.window.filter --subscribe: when a new window (dis)appears, run refreshWindowsWS
  filter.default:subscribe(filter.windowNotOnScreen, function() refreshWindowsWS() end)
  filter.default:subscribe(filter.windowOnScreen, function() refreshWindowsWS() end)
  filter.default:subscribe(filter.windowFocused, function() refreshFocus() end)

  -- 'subscribe', watchdog for one of modifier keys pressed
  local cycleModCounter = 0 
  local events = hs.eventtap.event.types
  local prevModifier = { "xyz" }
  keyboardTracker = hs.eventtap.new({ events.flagsChanged }, function(e)
    flags = eventToArray(e:getFlags())
    -- since on modifier release the flag is 'nil', prevModifier is used
    if modifiersEqual(flags, cycleModifier) or modifiersEqual(prevModifier, cycleModifier) then
      cycleModCounter = cycleModCounter + 1
      if cycleModCounter % 2 == 0 then -- only when released (and not when pressed)
        cycleModCounter = 0
        nextToFocus = 2
        refreshFocus()
        -- refreshWindowsWS() -- function is already called in refreshFocus()
      end
    end
    prevModifier = flags
  end)
  keyboardTracker:start()

  --cycle through all windows, regardless of which WS they are on
  --[[
  hs.hotkey.bind(cycleModifier, "tab", function()
    copy_windows_all = copyTable( windows_all)
    windows_all[nextToFocus]:focus()
    if nextToFocus == #windows_all then
      nextToFocus = 1
    else
      nextToFocus = nextToFocus + 1
    end
  end)
  --]]
  ---[[ -- alternative using hs.window.switcher
    -- https://applehelpwriter.com/2018/01/14/how-to-add-a-window-switcher/
    switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
    switcher.ui.highlightColor = {0.4,0.4,0.5,0.8}
    switcher.ui.thumbnailSize = 112
    switcher.ui.selectedThumbnailSize = 284
    switcher.ui.backgroundColor = {0.3, 0.3, 0.3, 0.5}
    switcher.ui.textSize = 14
    switcher.ui.showSelectedTitle = false
    hs.hotkey.bind("alt","tab",function()
      copy_windows_all = copyTable( windows_all)
      switcher:next()
    end)
    hs.hotkey.bind("alt-shift","tab",function()
      switcher:previous()
    end)
    --]]

  -- cycle through windows of current WS, last focus first
  hs.hotkey.bind(cycleModifier, "escape", function()
    while not isIncluded(windows_all[nextToFocus]:id()) do
      if nextToFocus == #windows_all then
        nextToFocus = 1
      else
        nextToFocus = nextToFocus + 1
      end
    end  
    copy_windows_all = copyTable( windows_all) -- remedy for problem that hs.window.sortByFocused' (in this case wrongly) takes into account focus given to windwos by cycling
    windows_all[nextToFocus]:focus()
    if nextToFocus == #windows_all then
      nextToFocus = 1
    else
      nextToFocus = nextToFocus + 1
    end
  end)

  --_________ handling spaces: aerospace _________
  hs.hotkey.bind(modifier3, prevSpace, function() -- previous space (incl. cycle)
    aerospace({'workspace', '--wrap-around', 'prev'}) -- aerospace
    hs.timer.doAfter(0.2, function() 
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  hs.hotkey.bind(modifier3, nextSpace, function() -- next space (incl. cycle)
    aerospace({'workspace', '--wrap-around', 'next'}) -- aerospace
    hs.timer.doAfter(0.2, function()
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  hs.hotkey.bind(modifier3, moveWindowPrevSpaceSwitch, function() -- move active window to previous space and switch there (incl. cycle)
    aerospace({'move-node-to-workspace', '--wrap-around', 'prev'})
    hs.timer.doAfter(0.02, function()
      aerospace({'workspace', '--wrap-around', 'prev'})
    end)
    hs.timer.doAfter(0.2, function()
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  hs.hotkey.bind(modifier3, moveWindowNextSpaceSwitch, function() -- move active window to next space and switch there (incl. cycle)
    aerospace({'move-node-to-workspace', '--wrap-around', 'next'})
    hs.timer.doAfter(0.02, function()
      aerospace({'workspace', '--wrap-around', 'next'})
    end)
    hs.timer.doAfter(0.2, function()
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  hs.hotkey.bind(modifier3, moveWindowPrevSpace, function() -- move active window to previous space (incl. cycle)
    aerospace({'move-node-to-workspace', '--wrap-around', 'prev'}) -- aerospace
    hs.timer.doAfter(0.2, function()
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  hs.hotkey.bind(modifier3, moveWindowNextSpace, function() -- move active window to next space (incl. cycle)
    aerospace({'move-node-to-workspace', '--wrap-around', 'next'}) -- aerospace
    hs.timer.doAfter(0.2, function()
      --refreshWindowsWS() -- function is already called in refreshFocus()
      refreshFocus()
    end)
  end)

  -- get arrays populated at start
  --refreshWindowsWS() -- function is already called in refreshFocus()
  refreshFocus()

  resizer.clickHandler:start()

  return resizer
end

function WinHammer:stop()
  self.dragging = false
  self.dragType = nil

  for i = 1, #cv do -- delete canvases
    cv[i]:delete()
  end

  self.cancelHandler:stop()
  self.dragHandler:stop()
  self.clickHandler:start()
end

function WinHammer:isResizing()
  return self.dragType == dragTypes.resize
end

function WinHammer:isMoving()
  return self.dragType == dragTypes.move
end

sumdx = 0
sumdy = 0
function WinHammer:handleDrag()
  return function(event)
    if not self.dragging then return nil end
    local currentSize = win:size() -- win:frame
    local current = win:topLeft()
      
    local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)

    if self:isMoving() then

      local point = win:topLeft()
      local frame = win:size() -- win:frame
      --win:move(hs.geometry.new(point.x + dx, point.y + dy, frame.w, frame.h), nil, false, 0)
      win:move({ dx, dy }, nil, false, 0)
      sumdy = sumdy + dy
      sumdx = sumdx + dx
      movedNotResized = true

      -- aerospace --
      moveLeftAS = false -- these two variables are also needed in case AeroSpace is deactivated
      moveRightAS = false
      if useSpaces then
        if current.x + currentSize.w * ratioSpaces < 0 then -- left
          for i = 1, #cv do
            cv[ i ]:hide() 
          end
          moveLeftAS = true
        elseif current.x + currentSize.w > max.w + currentSize.w * ratioSpaces then -- right
          for i = 1, #cv do
            cv[ i ]:hide()
          end
          moveRightAS = true
        else
          for i = 1, #cv do
            cv[ i ]:show()
          end
          moveLeftAS = false
          moveRightAS = false
        end
      else
        ratioSpaces = 1 -- if 'useSpaces' is disabled, enable automatic snapping and resizing beyond 'ratioSpaces', i.e., for dragging windows as far as possible (= 1)
      end

      return true
    elseif self:isResizing() and useResize then
      movedNotResized = false
      if mH <= -m and mV <= m and mV > -m then -- 9 o'clock
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h), nil, false, 0)
      elseif mH <= -m and mV <= -m then -- 10:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false,
              0)
          end
        else
          win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > -m and mH <= m and mV <= -m then -- 12 o'clock
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV <= -m then -- 1:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV > -m and mV <= m then -- 3 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h), nil, false, 0)
      elseif mH > m and mV > m then -- 4:30
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h + dy), nil, false, 0)
      elseif mV > m and mH <= m and mH > -m then -- 6 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w, currentSize.h + dy), nil, false, 0)
      elseif mH <= -m and mV > m then -- 7:30
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h + dy), nil, false, 0)
      else -- middle -> moving (not resizing) window
        local point = win:topLeft()
        local frame = win:frame()
        win:move({ dx, dy }, nil, false, 0)
        movedNotResized = true
      end
      return true
    else
      return nil
    end
  end
end

function WinHammer:handleCancel()
  return function()
    if not self.dragging then return end
    self:doMagic()
    self:stop()
  end
end

function WinHammer:doMagic() -- automatic positioning and adjustments, for example, prevent window from moving/resizing beyond screen boundaries
  if not self.targetWindow then return end

  modifierDM = eventToArray(hs.eventtap.checkKeyboardModifiers()) -- modifiers (still) pressed after releasing mouse button

  local frame = win:frame()
  local point = win:topLeft()
  -- 'max' should not be reintialized here because if there is another adjacent display with different resolution, windows are adjusted according to that resolution (as cursor gets moved there)
  -- local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height without menu bar
  local xNew = point.x
  local yNew = point.y
  local wNew = frame.w
  local hNew = frame.h

  if not moveLeftAS and not moveRightAS then -- if moved to other workspace, no resizing/repositioning wanted/necessary
    if movedNotResized then
      -- window moved past left screen border
      if modifiersEqual(flags, modifier1) then
        gridX = 2
        gridY = 2
      elseif modifiersEqual(flags, modifier2) then --or modifiersEqual(flags, modifier1_2) then
        gridX = 3
        gridY = 3
      end

      if modifiersEqual(flags, modifier1) then
        if point.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(point.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0
          -- window moved past left screen border
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment
                xNew = 0
                yNew = heightMB
                wNew = max.w / 2
                hNew = max.h
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                xNew = 0
                yNew = heightMB
                wNew = max.w / 2
                hNew = max.h / 2
              else -- bottom third
                xNew = 0
                yNew = heightMB + max.h / 2
                wNew = max.w / 2
                hNew = max.h / 2
              end
            end
          end
        -- moved window past right screen border
        elseif point.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then
                xNew = max.w / 2
                yNew = heightMB
                wNew = max.w / 2
                hNew = max.h
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                xNew = max.w / 2
                yNew = heightMB
                wNew = max.w / 2
                hNew = max.h / 2
              else -- bottom third
                xNew = max.w / 2
                yNew = heightMB + max.h / 2
                wNew = max.w / 2
                hNew = max.h / 2
              end
            end
          end
        -- moved window below bottom of screen
        elseif point.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridX, 1 do
              if hs.mouse.getRelativePosition().x + sumdx > max.w / 3 and hs.mouse.getRelativePosition().x + sumdx < max.w * 2 / 3 then -- middle
                xNew = 0
                yNew = heightMB
                wNew = max.w
                hNew = max.h
                break
              elseif hs.mouse.getRelativePosition().x + sumdx <= max.w / 3 then -- left
                xNew = 0
                yNew = heightMB
                wNew = max.w / gridX
                hNew = max.h
                break
              else -- right
                xNew = max.w - max.w / gridX -- for gridX = 2 the same as max.w / 2
                yNew = heightMB
                wNew = max.w / gridX
                hNew = max.h
                break
              end
            end
          end
        end
      elseif modifiersEqual(flags, modifier2) and modifiersEqual(flags, modifierDM) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
        if point.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(point.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0
          -- window moved past left screen border
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- 3 standard areas
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              for i = 1, gridY, 1 do
                -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment             
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  xNew = 0
                  yNew = heightMB + (i - 1) * max.h / gridY
                  wNew = max.w / gridX
                  hNew = max.h / gridY
                  break
                end
              end
            -- first (upper) double area
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              xNew = 0
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            else -- second (lower) double area
              xNew = 0
              yNew = heightMB + max.h / 5 * 2
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            end
          end
        -- moved window past right screen border
        elseif point.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then  -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment                     
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              -- 3 standard areas
              for i = 1, gridY, 1 do
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  xNew = max.w - max.w / gridX
                  yNew = heightMB + (i - 1) * max.h / gridY
                  wNew = max.w / gridX
                  hNew = max.h / gridY
                  break
                end
              end
            -- first (upper) double area
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              xNew = max.w - max.w / gridX
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            else -- second (lower) double area
              xNew = max.w - max.w / gridX
              yNew = heightMB + max.h / 5 * 2
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            end
          end
        -- moved window below bottom of screen
        elseif point.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
              -- 3 standard areas
              for i = 1, gridX, 1 do
                if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                  xNew = (i - 1) * max.w / gridX 
                  yNew = heightMB + (i - 1) * gridX
                  wNew = max.w / gridX
                  hNew = max.h
                  break
                end
              end
            -- first (left) double width
            elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
              xNew = 0
              yNew = heightMB
              wNew = max.w / gridX * 2
              hNew = max.h
            else -- second (right) double width
              xNew = max.w - max.w / gridX * 2
              yNew = heightMB
              wNew = max.w / gridX * 2
              hNew = max.h
            end
          end
        end
      -- if dragged beyond left/right screen border, window snaps to middle column
      --elseif modifiersEqual(flags, modifier1_2) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
      elseif modifiersEqual(flags, modifier2) and #modifierDM == 0 then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
        if point.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(point.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0
          -- window moved past left screen border
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- 3 standard areas
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              for i = 1, gridY, 1 do
                -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment             
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  xNew = max.w / gridX
                  yNew = heightMB + (i - 1) * max.h / gridY
                  wNew = max.w / gridX
                  hNew = max.h / gridY
                  break
                end
              end
            -- first (upper) double area
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              xNew = max.w / gridX
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            else -- second (lower) double area
              xNew = max.w / gridX
              yNew = heightMB + max.h / 5 * 2
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            end
          end
        -- moved window past right screen border
        elseif point.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then  -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment                     
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              -- 3 standard areas
              for i = 1, gridY, 1 do
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  xNew = max.w / gridX
                  yNew = heightMB + (i - 1) * max.h / gridY
                  wNew = max.w / gridX
                  hNew = max.h / gridY
                  break
                end
              end
            -- first (upper) double area
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              xNew = max.w / gridX
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            else -- second (lower) double area
              xNew = max.w / gridX
              yNew = heightMB + max.h / 5 * 2
              wNew = max.w / gridX
              hNew = max.h / gridY * 2
            end
          end
        -- moved window below bottom of screen
        elseif point.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
              -- 3 standard areas
              for i = 1, gridX, 1 do
                if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                  xNew = (i - 1) * max.w / gridX 
                  yNew = heightMB + (i - 1) * gridX
                  wNew = max.w / gridX
                  hNew = max.h
                  break
                end
              end
            -- first (left) double width
            elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
              xNew = 0
              yNew = heightMB
              wNew = max.w / gridX * 2
              hNew = max.h
            else -- second (right) double width
              xNew = max.w - max.w / gridX * 2
              yNew = heightMB
              wNew = max.w / gridX * 2
              hNew = max.h
            end
          end
        end
      end
    else -- if window has been resized (and not moved)
      if point.x < 0 then -- window resized past left screen border
        wNew = frame.w + point.x
        xNew = 0
      elseif point.x + frame.w > max.w then -- window resized past right screen border
        wNew = max.w - point.x
        xNew = max.w - wNew
      end
      if point.y < heightMB then -- if window has been resized past beginning of menu bar, height of window is corrected accordingly
        hNew = frame.h + point.y - heightMB
        yNew = heightMB
      end
    end
    self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  
  -- aerospace
  elseif useSpaces and movedNotResized then
    if moveLeftAS then
      aerospace({'move-node-to-workspace', '--wrap-around', 'prev'})
      if modifiersEqual(modifierDM, flags) then -- if modifier is still pressed, switch to where window has been moved
        hs.timer.doAfter(0.02, function()
          aerospace({'workspace', '--wrap-around', 'prev'})
        end)
      end
    elseif moveRightAS then
      aerospace({'move-node-to-workspace', '--wrap-around', 'next'})
      if modifiersEqual(modifierDM, flags) then
        hs.timer.doAfter(0.02, function()
          aerospace({'workspace', '--wrap-around', 'next'})
        end)
      end
    end
    -- position window in middle of new workspace
    xNew = max.w / 2 - wNew / 2
    yNew = max.h / 2 - hNew / 2
    self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  end
  sumdx = 0
  sumdy = 0
end

function WinHammer:handleClick()
  return function(event)
    if self.dragging then return true end
    flags = eventToArray(event:getFlags())
    eventType = event:getType()

    -- enable active modifiers (modifier1, modifier2, modifier3, modifier4)
    isMoving = false
    isResizing = false
    if eventType == self.moveStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isMoving = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isMoving = true
      elseif modifier3 ~= nil and modifiersEqual(flags, modifier3) then
        isMoving = true
      elseif modifier4 ~= nil and modifiersEqual(flags, modifier4) then
        isMoving = true
     --elseif modifier1_2 ~= nil and modifiersEqual(flags, modifier1_2) then
      --  isMoving = true
      end
    elseif eventType == self.resizeStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isResizing = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isResizing = true
      elseif modifier3 ~= nil and modifiersEqual(flags, modifier3) then
        isResizing = true
      elseif modifier4 ~= nil and modifiersEqual(flags, modifier4) then
        isResizing = true
      --elseif modifier1_2 ~= nil and modifiersEqual(flags, modifier1_2) then
      --  isResizing = true
      end
    end

    if isMoving or isResizing then
      local currentWindow = getWindowUnderMouse()
      if #self.disabledApps >= 1 then
        if self.disabledApps[currentWindow:application():name()] then
          return nil
        end
      end

      self.dragging = true
      self.targetWindow = currentWindow
      
      if isMoving then
        self.dragType = dragTypes.move
      else
        self.dragType = dragTypes.resize
      end
    
      ---[[
      -- prevent error when clicking on screen (and not window) with pressed modifier(s)
      if type(getWindowUnderMouse()) == "nil" then
        self.cancelHandler:start()
        self.dragHandler:stop()
        self.clickHandler:stop()
        -- Prevent selection
        return true
      end
      --]]

      win = getWindowUnderMouse():focus() --todo (?done? ->experimental): error if clicked on screen (and not window)
      local point = win:topLeft()
      local frame = win:frame()
      max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height
      maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h   -- height menu bar
      local xNew = point.x
      local yNew = point.y
      local wNew = frame.w
      local hNew = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wNew + xNew - mousePos.x -- distance between right border of window and cursor
      local dmah = wNew / 2 - mx -- absolute delta: mid window - cursor
      mH = dmah * 100 / wNew -- delta from mid window: -50(left border of window) to 50 (left border)

      local my = hNew + yNew - mousePos.y
      local dmav = hNew / 2 - my
      mV = dmav * 100 / hNew -- delta from mid window in %: from -50(=top border of window) to 50 (bottom border)

      -- show canvases for visually supporting automatic window positioning and resizing
      local thickness = 20 -- thickness of bar
      cv = {} -- canvases need to be reset
      if eventType == self.moveStartMouseEvent and modifiersEqual(flags, modifier1) then
        createCanvas(1, 0, max.h / 3, thickness, max.h / 3)
        createCanvas(2, max.w / 3, heightMB + max.h - thickness, max.w / 3, thickness)
        createCanvas(3, max.w - thickness, max.h / 3, thickness, max.h / 3)
      elseif eventType == self.moveStartMouseEvent and (modifiersEqual(flags, modifier2)) then -- or modifiersEqual(flags, modifier1_2)) then
        createCanvas(1, 0, max.h / 5, thickness, max.h / 5)
        createCanvas(2, 0, max.h / 5 * 3, thickness, max.h / 5)
        createCanvas(3, max.w / 5, heightMB + max.h - thickness, max.w / 5, thickness)
        createCanvas(4, max.w / 5 * 3, heightMB + max.h - thickness, max.w / 5, thickness)
        createCanvas(5, max.w - thickness, max.h / 5, thickness, max.h / 5)
        createCanvas(6, max.w - thickness, max.h / 5 * 3, thickness, max.h / 5)
      end

      self.cancelHandler:start()
      self.dragHandler:start()
      self.clickHandler:stop()

      -- Prevent selection
      return true
    else
      return nil
    end
  end
end

-- function needed in case 'useSpaces' is activated
function aerospace(args)
  hs.task.new("/opt/homebrew/bin/aerospace", function(ud, ...)
    as_out = (hs.inspect(table.pack(...)))  
    --return true
  end, args):start()
  return as_out
end
-- function for creating canvases at screen border
function createCanvas(n, x, y, w, h)
  cv[n] = hs.canvas.new(hs.geometry.rect(x, y, w, h))
  cv[n]:insertElement(
    {
      action = 'fill',
      type = 'rectangle',
      fillColor = { red = 1, green = 0, blue = 0, alpha = 0.5 },
      roundedRectRadii = { xRadius = 5.0, yRadius = 5.0 },
    },
    1
  )
  cv[n]:show()
end

 -- event looks like this: {'alt' 'true'}; function turns table into an 'array' so
 -- it can be compared to the other arrays (modifier1, modifier2,...)
function eventToArray(a) -- fb: maybe extend to work with more than one modifier at at time
  k = 1
  b = {}
  for i,_ in pairs(a) do
    if i == "cmd" or i == "alt" or i == "ctrl" or i == "shift" then -- or i == "fn" then
      b[k] = i
      k = k + 1
    end
  end
  return b
end

function modifiersEqual(a, b)
  if #a ~= #b then 
    return false
  end 
  table.sort(a)
  table.sort(b)
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

--___________ functions aerospace - cycle through windows ___________
-- get array with all window ids of active workspace -> aerospace()
function refreshWindowsWS()
  n = 1 -- index for app switcher
  s = aerospace({"list-windows", "--workspace", "focused", "--format", "%{window-id}"})
  -- example output: { "27805\n23632\n19152\n23628\n21665\n27746\n27424\n", ""  n = 2 }
  hs.timer.doAfter(0.3, function() -- fb 0.12: time to wait - experimental
    s = aerospace({"list-windows", "--workspace", "focused", "--format", "%{window-id}"})
    ids = {}
    table.insert(ids, string.match(s, "{ \"(%d+)")) -- get digits between '{ "' and '\'
    for substring in s:gmatch("%bn\\") do -- get string between 'n' and '\'
      table.insert(ids, string.sub(substring, 2, #substring - 1)) -- get rid of leading 'n' and final '\'
    end
    for i,v in pairs(ids) do
      --print(i,v)
    end
  end)
end

function refreshFocus() -- called automatically when window-focus changes
  hs.timer.doAfter(0.2, -- fb: 0.01
    function()          -- apparently necessary for keyboardTracker to have the time to release the modifier key
      local modNow = eventToArray(hs.eventtap.checkKeyboardModifiers())
      if not modifiersEqual(modNow, cycleModifier) then -- necessary for "cycle through windows of current WS, last focus first", otherwise 'focused' and 'windows_all' are always reset
        nextToFocus = 2
        filter_all = hs.window.filter.new()
        local x = filter_all:getWindows(hs.window.sortByFocused)
        windows_all = {}
        -- 'hs.window.sortByFocused' (in this case wrongly) takes into account focus given to windows by cycling -> remedy:
        if #copy_windows_all < #x then
          windows_all = copyTable(x)
        else
          windows_all[1] = x[1]
          -- fill up in order from windows_all, leave out copy_windows_all[1]
          for i = 1, #copy_windows_all do
            if windows_all[1]:id() ~= copy_windows_all[i]:id() then
              table.insert(windows_all, copy_windows_all[i])
            end
          end
        end
        copy_windows_all = copyTable(windows_all) -- fixes discrepency if windows are given focus by clicking
      end
      refreshWindowsWS()
    end)
end

function isIncluded(id) -- check whether window id is included in table
  local a = false
  for i,v in pairs(ids) do
    if tostring(id) == tostring(ids[i]) then
      a = true
    end
  end
  return a
end

function copyTable(a)
  b = {}
  for i,v in pairs(a) do
    b[i] = v
  end
  return b
end


return WinHammer
