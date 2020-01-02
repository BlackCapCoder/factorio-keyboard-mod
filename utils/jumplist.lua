require ('utils.windowzipper')


local jumpList      = WindowZipper (20)
local locationMarks = {}
local smallJump     = 5


local function dist (a, b)
  local x = a.x - b.x
  local y = a.y - b.y
  return math.sqrt ( x*x + y*y )
end
local function ptEq (a, b)
  return a.x == b.x and a.y == b.y
end
local function ptEq_ (a, b)
  return dist (a, b) <= smallJump
end

local function clean ()
  jumpList.jumpEnd ()
  while not jumpList.atBeginning () do
    local x = jumpList.getCursor()
    jumpList.prev ()
    if ptEq_ (x, jumpList.getCursor()) then
      jumpList.delete()
    end
  end
end

local jpush = function (x)
  if jumpList.empty () then
    jumpList.push (x)
    return
  end

  if ptEq_ (x, jumpList.getCursor()) then
    jumpList.setCursor (x)
    return
  end

  jumpList.push (x)
end

-- Teleport player to X and populate the jumplist
function jump (x)
  local p   = pl.position
  local old = jumpList.getCursor()

  if old == nil or not ptEq_ (p, old) then
    -- keep old, push new
    jpush(p)
  else
    -- move
    jumpList.setCursor (x)
    jumpList.promote   ( )
  end

  jpush(x)
  jumpList.jumpEnd ()
  pl.teleport (x)
end


-- Create a mark
nmapf ('m', function ()
  getKeyTimeout (2000, function (key)
    locationMarks[key] = { x = pl.position.x, y = pl.position.y }
    pl.print('mark set')
    return true
  end)
end)

-- Jump to a mark
-- nmapf ("'", function ()
script.on_event("key-'", function (ev)
  getKeyTimeout (2000, function (key)
    if not locationMarks[key] then return end
    jump (locationMarks[key])
    return true
  end)
end)

-- Top of jumplist, '' in vim
nmapf ("gi", function ()
  if jumpList.empty () then return true end

  local p   = pl.position
  local old = jumpList.getCursor()

  if old == nil or not ptEq (p, old) then
    jpush(p)
  else
    jumpList.promote()
  end

  jumpList.jumpEnd ()
  jumpList.prev    ()
  jumpList.promote ()
  jumpList.jumpEnd ()
  pl.teleport (jumpList.getCursor())

  return true
end)

-- Previous jumplist entry
local seq = nmapf ("<c-o>", function ()
  if jumpList.atBeginning () then return end
  jumpList.prev()
  pl.teleport (jumpList.getCursor())
end)

-- Next jumplist entry
nmapf ("<c-i>", function ()
  if jumpList.atEnd () then return end
  jumpList.next ()
  pl.teleport (jumpList.getCursor ())
end)

