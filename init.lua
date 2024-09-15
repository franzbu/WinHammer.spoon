local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local LattinMellon = {}

LattinMellon.author = "Franz B. <csaa6335@gmail.com>"
LattinMellon.homepage = "https://github.com/franzbu/LattinMellon.spoon"
LattinMellon.license = "MIT"
LattinMellon.name = "LattinMellon"
LattinMellon.version = "0.6"
LattinMellon.spoonPath = scriptPath()

local dragTypes = {
  move = 1,
  resize = 2,
}

local function tableToMap(table)
  local map = {}
  for _, value in pairs(table) do
    map[value] = true
  end
  return map
end

local function getWindowUnderMouse()
  local _ = hs.application
  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

-- Usage:
--     resizer = LattinMellon:new({
--     margin = 30,
--     gridX = 3,
--     gridY = 3 ,
--     moveModifier(s) = {'alt'},
--     moveMouseButton = 'left',
--     resizeModifier(s) = {'alt'},
--     resizeMouseButton = 'right',
--     modifierLayerTwo = 'cmd',
--     modifierLayerThree = 'ctrl',
--     modifierLayerFour = 'hyper',
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

function LattinMellon:new(options)
  options = options or {}
  gridX = options.gridX or 3
  gridY = options.gridY or 3
  margin = options.margin or 30
  m = margin / 2
  modifierLayerTwo = options.modifierLayerTwo or {'alt', 'ctrl'}
  modifierLayerThree = options.modifierLayerThree or { 'alt', 'ctrl', 'cmd' }
  modifierLayerFour = options.modifierLayerFour or { 'alt', 'ctrl', 'cmd', 'shift' }  -- hyper key


  local resizer = {
    disabledApps = tableToMap(options.disabledApps or {}),
    dragging = false,
    dragType = nil,
    moveStartMouseEvent = buttonNameToEventType(options.moveMouseButton or 'left', 'moveMouseButton'),
    moveModifiers = options.moveModifiers or { 'alt' },
    resizeStartMouseEvent = buttonNameToEventType(options.resizeMouseButton or 'left', 'resizeMouseButton'),
    resizeModifiers = options.resizeModifiers or { 'alt' },
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

  resizer.clickHandler:start()

  return resizer
end

function LattinMellon:stop()
  self.dragging = false
  self.dragType = nil
  self.cancelHandler:stop()
  self.dragHandler:stop()
  self.clickHandler:start()
end

function LattinMellon:isResizing()
  return self.dragType == dragTypes.resize
end

function LattinMellon:isMoving()
  return self.dragType == dragTypes.move
end

local sumdx = 0
local sumdy = 0
function LattinMellon:handleDrag()
  return function(event)
    if not self.dragging then return nil end

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
      return true
    elseif self:isResizing() then
      movedNotResized = false
      local currentSize = win:size() -- win:frame
      local current = win:topLeft()
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
      else -- middle
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

function LattinMellon:handleCancel()
  return function()
    if not self.dragging then return end
    self:finalMagic()
    self:stop()
  end
end

function LattinMellon:finalMagic() -- automatic positioning and adjustments, for example, prevent window from moving/resizing beyond screen boundaries
  if not self.targetWindow then return end

  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local point = win:topLeft()
  local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height without menu bar
  local xNew = point.x
  local yNew = point.y
  local wNew = frame.w
  local hNew = frame.h

  if movedNotResized then
    if point.x < 0 then -- window moved past left screen border
      if math.abs(point.x) < wNew / 10 then -- move window as is back within boundaries of screen if overstepping screen boundary with less than 10 percent of the window
        xNew = 0
      else -- automatically resize and position window within grid
        if flags:containExactly(self.moveModifiers) then -- grid: x = 1
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then -- getRelativePosition() weirdly returns mouse coordinates where moving starts, not ends, therefore sumdx/sumdy make necessary adjustment
              xNew = 0
              yNew = heightMB + (i - 1) * max.h / gridY
              wNew = max.w / gridX
              hNew = max.h / gridY
              break
            end
          end
        elseif flags:containExactly(modifierLayerTwo) then -- grid: x = 2 (second modifier key pressed)
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
              xNew = max.w / gridX
              yNew = heightMB + (i - 1) * max.h / gridY
              wNew = max.w / gridX
              hNew = max.h / gridY
              break
            end
          end
        elseif flags:containExactly(modifierLayerThree) then -- grid: x = 1 + 2 (third modifier key pressed)
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
              if i < gridY then
                xNew = 0
                yNew = heightMB + (i - 1) * max.h / gridY
                wNew = max.w / gridX * 2
                hNew = max.h / gridY * 2
              else
                xNew = 0
                yNew = heightMB + (i - 2) * max.h / gridY
                wNew = max.w / gridX * 2
                hNew = max.h / gridY * 2
              end
              break
            end
          end
        elseif flags:containExactly(modifierLayerFour) then -- grid: x = 1 + 2 (third modifier key pressed)
          -- os.execute("/opt/homebrew/bin/yabai -m window --space prev --focus || /opt/homebrew/bin/yabai -m window --space last --focus")
          --fb:
     

        end
      end
      
    elseif point.x + frame.w > max.w then -- window moved past right screen border
      if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
        wNew = frame.w
        xNew = max.w - wNew
      else -- automatically resize window
        if flags:containExactly(self.moveModifiers) then -- grid: x = last
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
              xNew = max.w - max.w / gridX
              yNew = heightMB + (i - 1) * max.h / gridY
              wNew = max.w / gridX
              hNew = max.h / gridY
              break
            end
          end
        elseif flags:containExactly(modifierLayerTwo) then  -- grid: x = last - 1 (second modifier key pressed)
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
              xNew = max.w - 2 * max.w / gridX
              yNew = heightMB + (i - 1) * max.h / gridY
              wNew = max.w / gridX
              hNew = max.h / gridY
              break
            end
          end
        elseif flags:containExactly(modifierLayerThree) then -- grid: x = secont to last + last (third modifier key pressed)        
          for i = 1, gridY, 1 do
            if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
              if i < gridY then
                xNew = max.w - max.w / gridX * 2
                yNew = heightMB + (i - 1) * max.h / gridY
                wNew = max.w / gridX * 2
                hNew = max.h / gridY * 2
              else
                xNew = max.w - max.w / gridX * 2
                yNew = heightMB + (i - 2) * max.h / gridY
                wNew = max.w / gridX * 2
                hNew = max.h / gridY * 2
              end
              break
            end
          end
        elseif flags:containExactly(modifierLayerFour) then -- grid: x = secont to last + last (third modifier key pressed)        

        end
      end
    end

    if point.y + hNew > maxWithMB.h then -- moved window below bottom of screen 
      if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(self.moveModifiers) then -- move window as is back within boundaries
        yNew = maxWithMB.h - hNew
      else -- get window to full height in corresponding x-grid
        if flags:containExactly(self.moveModifiers) then
          for i = 1, gridX, 1 do
            if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
              xNew = (i - 1) * max.w / gridX
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h
              break
            end
          end
        elseif flags:containExactly(modifierLayerTwo) then -- modifierLayerTwo: double width (compared to above)
          for i = 1, gridX, 1 do
            if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
              if i < gridX then
                xNew = (i - 1) * max.w / gridX
              else
                xNew = (i - 2) * max.w / gridX
              end
              yNew = heightMB
              wNew = max.w / gridX * 2
              hNew = max.h
              break
            end
          end
        elseif flags:containExactly(modifierLayerFour) then -- modifierLayerThree: less than half of window down -> lower half of screen, otherwise upper half
          for i = 1, gridX, 1 do
            if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then
              xNew = (i - 1) * max.w / gridX
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h / 2
              break
            end
          end
        elseif flags:containExactly(modifierLayerThree) then -- modifierLayerThree: less than half of window down -> lower half of screen, otherwise upper half
          for i = 1, gridX, 1 do
            if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
              xNew = (i - 1) * max.w / gridX
              yNew = heightMB + max.h / 2
              wNew = max.w / gridX
              hNew = max.h / 2
              break
            end     
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
  sumdx = 0
  sumdy = 0
end

function LattinMellon:handleClick()
  return function(event)
    if self.dragging then return true end

    flags = event:getFlags()
    local eventType = event:getType()

    local isMoving = eventType == self.moveStartMouseEvent and (flags:containExactly(self.moveModifiers) or flags:containExactly(modifierLayerTwo) or flags:containExactly(modifierLayerThree) or flags:containExactly(modifierLayerFour))
    local isResizing = eventType == self.resizeStartMouseEvent and flags:containExactly(self.resizeModifiers)

    if isMoving or isResizing then
      local currentWindow = getWindowUnderMouse()
      
      if self.disabledApps[currentWindow:application():name()] then
        return nil
      end

      self.dragging = true
      self.targetWindow = currentWindow

      if isMoving then
        self.dragType = dragTypes.move
      else
        self.dragType = dragTypes.resize
      end

      win = getWindowUnderMouse():focus()
      local point = win:topLeft()
      local frame = win:frame()
      local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height
      maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h   -- height menu bar
      local xOrg = point.x
      local yOrg = point.y
      local wOrg = frame.w
      local hOrg = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wOrg + xOrg - mousePos.x -- distance between right border of window and cursor
      local dmah = wOrg / 2 - mx -- absolute delta: mid window - cursor
      mH = dmah * 100 / wOrg -- delta from mid window: -50(left border of window) to 50 (left border)

      local my = hOrg + yOrg - mousePos.y
      local dmav = hOrg / 2 - my
      mV = dmav * 100 / hOrg -- delta from mid window in %: from -50(=top border of window) to 50 (bottom border)

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

-- helper function(s)
function table.copy(t)
  local t2 = {}
  for k, v in pairs(t) do
    t2[k] = v
  end
  return t2
end

return LattinMellon
