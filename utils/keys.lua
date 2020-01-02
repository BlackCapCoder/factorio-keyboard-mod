------------------
-- Space efficient way to store a key


local function compress (key, ctrl, alt)
  local b = string.byte (key)

  if ctrl then b = bit32.bor(b, 0x080) end
  if alt  then b = bit32.bor(b, 0x100) end

  return b -- 9 bits
end


local function isDigit (code)
  return bit32.band (code, 0x40) == 0
end
local function isLetter (code)
  return not isDigit (code)
end

local function isUpper (code)
  return bit32.band (code, 0x20) == 0
end
local function isLower (code)
  return not isUpper (code)
end

local function getLetter (code)
  return string.char (bit32.band (code, 0x7f))
end
local function getDigit (code)
  return string.char (bit32.band (code, 0x0f))
end


local function hasCtrl (code)
  return bit32.band (code, 0x80) ~= 0
end
local function hasAlt (code)
  return bit32.band (code, 0x100) ~= 0
end


local function setCtrl (code)
  return bit32.bor (code, 0x80)
end
local function setAlt (code)
  return bit32.bor (code, 0x100)
end


local function isValid (code)
  return bit32.band (code, 0x7f) ~= 0
end


local function toString (code)
  local str = ""

  if hasCtrl (code) then str = str .. 'C-' end
  if hasAlt  (code) then str = str .. 'A-' end
  str = str .. getLetter (code)

  return str
end


------------------

local function parseKeys (str)
  local keys  = {}
  local count = 0

  local i = 1

  while i <= #str do
    local key = 0
    local chr = string.byte (str, i)
    i         = i + 1

    -- Key with modifiers
    if chr == 60 then
      local _i  = i

      while true do
        if i + 3 > #str then
          key = 0
          break
        end

        local a = string.byte (str, i + 0)
        local b = string.byte (str, i + 1)
        local c = string.byte (str, i + 2)

        if a == 67 or a == 99 then key = setCtrl (key) else
        if a == 65 or a == 97 then key = setAlt  (key) else
          key = 0
          break
        end end

        if b ~= 45 then
          key = 0
          break
        end

        if c == 62 then
          key = 0
          break
        end

        key = bit32.bor (key, c)

        i = i + 4
        break
      end

      if not isValid (key) then
        key = 0
        i   = _i
      end
    end

    -- Regular key
    if key == 0 then key = chr end

    count       = count + 1
    keys[count] = key
  end

  return keys
end


------------------

local function KeyMap ()
  local prot = {}
  local map  = {}


  prot.map = function (mode, seq, f)
    local ks = parseKeys (seq)

    if #ks <= 0 then return end

    local node = prot.getMap (mode)

    for _, k in pairs(ks) do
      if node.binds == nil then
        node.binds = {}
      end

      if node.binds[k] == nil then
        node.binds[k] = { exec = {} }
      end

      node = node.binds[k]
    end

    node.exec[(#node.exec) + 1] = f
  end

  prot.getMap = function (mode)
    if map[mode] == nil then
      map[mode] = { exec = {}, binds = {} }
    end

    return map[mode]
  end

  return prot
end


----------------
local function KeyState (keyMap)
  local currentMode, currentMap
  local prot    = {}
  local pending = nil


  prot.snagNext = function (callback)
    pending = callback
  end

  prot.unsnag = function ()
    pending = nil
  end

  prot.setMode = function (mode)
    currentMode = mode
    currentMap  = keyMap.getMap (mode)
  end

  prot.putKey = function (key)
    if pending then
      local f = pending
      pending = nil
      if f (key) then return end
    end

    currentMap = currentMap.binds[key]

    if currentMap == nil then
      prot.setMode (currentMode)
      return false
    end

    for _, f in pairs (currentMap.exec) do f () end

    if currentMap.binds == nil then
      prot.setMode (currentMode)
    end

    return true
  end


  return prot
end

-- local function KeyState (keyMap)
--   local currentMode, currentMap
--   local prot    = {}
--   local pending = nil
--
--   prot.snagNext = function (callback)
--     pending = callback
--   end
--
--   prot.unsnag = function () pending = nil end
--
--   prot.setMode = function (mode)
--     currentMode = mode
--     currentMap  = keyMap.getMap (mode)
--   end
--
--   prot.getMode = function () return currentMode end
--
--   prot.putKey = function (key)
--     if pending then
--       local f = pending
--       pending = nil
--       if f (key) then return end
--     end
--
--     local currentMap = currentMap.binds[key]
--
--     if currentMap == nil then
--       prot.setMode (currentMode)
--       return false
--     end
--
--     for _, f in pairs (currentMap.exec) do f () end
--
--     if currentMap.binds == nil then
--       prot.setMode (currentMode)
--     end
--
--     return true
--   end
--
--
--   return prot
-- end

----------------
-- globals

keyMap   = KeyMap ()
keyState = KeyState (keyMap)

function getMode () keyState.getMode () end
function setMode (mode) keyState.setMode (mode) end

setMode ('normal')


function setModeEx (prim, sec)
  local ps = KeyState (keyMap)
  local ss = keyState

  ps.setMode (prim)
  ss.setMode (sec)

  local putKey = ps.putKey
  ps.putKey = function (key)
    if putKey    (key) then return true end
    if ss.putKey (key) then return true end
    return false
  end

  local sm = setMode
  setMode = function (mode)
    keyState = ss
    setMode  = sm
    sm (mode)
  end

  keyState = ps
end


-- Return true to block
function getKey (callback)
  keyState.snagNext (callback)
end

function getKeyTimeout (ms, callback)
  local cancel = timeout (ms, function ()
    keyState.unsnag ()
  end)

  getKey (function (args)
    cancel ()
    return callback (args)
  end)
end


-- TODO: getKey
function evalKeys (mode, seq)
  local ks = parseKeys (seq)
  if #ks <= 0 then return end

  local st = KeyState (keyMap)
  st.setMode (mode)

  for _, k in pairs (ks) do
    st.putKey (k)
  end
end

function execKeys (seq)
  local ks = parseKeys (seq)
  for _, k in pairs (ks) do
    keyState.putKey (k)
  end
end

function norm (seq) evalKeys ('normal', seq) end


function mapf (mode, seq, f)
  keyMap.map (mode, seq, f)
end

function nmapf (seq, f)
  mapf ('normal', seq, f)
end


function map (mode, alias, seq)
  mapf (mode, alias, function () execKeys (seq) end)
end

function nmap (alias, seq)
  map ('normal', alias, seq)
end


----------------
-- Subscribe to key events


local function onKeyPress (code)
  keyState.putKey (code)
end

local function registerKey (key, ctrl, alt)
  local        str = key
  if alt  then str = 'A-' .. str end
  if ctrl then str = 'C-' .. str end

  local code = compress (key, ctrl, alt)

  script.on_event("key-" .. str, function (ev)
    onKeyPress (code)
  end)
end


local keys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

for key in keys:gmatch"." do
  registerKey (key, false, false)
  registerKey (key, false, true)
  registerKey (key, true,  false)
  -- registerKey (key, true,  true)
end

