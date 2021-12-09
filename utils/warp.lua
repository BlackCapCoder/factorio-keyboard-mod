-- The maximum distance we are allowed to warp
local warpRange = 150

-- The stepping distance used by the scan function
-- Intended to be the width of the player, whatever that is
-- local largeStep = 0.625
local largeStep = 0.5

-- When the needle is found using largeStep, refine using smallStep
-- `largeStep / smallStep` should yield an integer
local smallStep = largeStep / 5

-- Smallest jump we care about
-- Used in word. We consider the player to be "facing the wall" if he is
-- closer than this
local epsilon = 5

local filter =
  { 'character'
  , 'particle'
  , 'leaf-particle'
  , 'flying-text'
  , 'corpse'
  , 'resource'
  , 'fish'
  }


local function playerDiameter ()
  local bb = pl.character.bounding_box
  local w  = bb.right_bottom.x - bb.left_top.x
  local h  = bb.right_bottom.y - bb.left_top.y
  return math.max (w, h)
end

local function warp (x, y, a, d)
  local _x = x + math.cos(a) * d
  local _y = y + math.sin(a) * d
  local p = pl.surface.find_non_colliding_position
    (pl.character.prototype.name, {_x, _y}, 0, smallStep, false)

  pl.teleport (p)
end


local function col (x,y)
  local es = pl.surface.count_entities_filtered
    { position = {x, y}
    , radius   = 2 * largeStep
    , type     = filter
    , invert   = true
    , limit    = 1
    }

  return es > 0
end

local function scan (x,y,a,d,r,f)
  for i = d, d + r, largeStep do
    local _x = x + math.cos(a) * i
    local _y = y + math.sin(a) * i
    if f (_x,_y) then
      local j = 0.0
      while j <= largeStep do
        local _j = j + smallStep
        local _i = i - _j
        local _x = x + math.cos(a) * _i
        local _y = y + math.sin(a) * _i
        if f (_x,_y) then j = _j else break end
      end
      return i - j
    end
  end
  return d + r
end

local function scanOrth (x,y,a,d,r)
  local x1 = x
  local y1 = y
  local x2 = x + math.cos(a) * r
  local y2 = y + math.sin(a) * r
  if x1 > x2 then local tmp = x2; x2 = x1; x1 = tmp; end
  if y1 > y2 then local tmp = y2; y2 = y1; y1 = tmp; end

  local es =
    pl.surface.find_entities_filtered
      ({ area   = {{x1,y1}, {x2,y2}}
       , type   = filter
       , invert = true
       })

  if #es == 0 then return end

  if y1 == y2 then
    table.sort(es, function (a,b)
      return a.bounding_box.left_top.x <
             b.bounding_box.left_top.x
    end)
    local res = {}
    local pivot = es[1].bounding_box
    for i = 2, #es do
      local q = es[i].bounding_box
      if q.left_top.x - pivot.right_bottom.x <= largeStep then
        pivot.right_bottom.x = math.max (pivot.right_bottom.x, q.right_bottom.x)
      else
        res[#res + 1] = pivot
        pivot = q
      end
    end
    res[#res + 1] = pivot
    pl.print(#es .. " " .. #res)
  end

end

function warpWord ()
  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 0

  d = scan (pos.x, pos.y, a, d, warpRange, col)

  if d < epsilon then -- beginning of word?

    -- End of current
    d = scan (pos.x, pos.y, a, d, warpRange, function (x,y)
      return not col(x,y)
    end)

    -- beginning of next
    d = scan (pos.x, pos.y, a, d, warpRange, col)
  end

  warp (pos.x, pos.y, a, d - largeStep)
end

function warpEnd ()
  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 0

  d = scan (pos.x, pos.y, a, d, warpRange, col)
  d = scan (pos.x, pos.y, a, d, warpRange, function (x,y)
    return not col(x,y)
  end)

  warp (pos.x, pos.y, a, d + largeStep)
end

function warpShort ()
  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 20
  -- d = scan (pos.x, pos.y, a, d, warpRange, function (x,y)
  --   return not col(x,y)
  -- end)

  warp (pos.x, pos.y, a, d + largeStep)
end
