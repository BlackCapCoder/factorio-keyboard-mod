local warpRange = 150

local function col (x,y)
  -- local tile = surf.get_tile(pos.x, pos.y)
  local es = pl.surface.find_entities_filtered
    { position = {x, y}
    , radius   = 1.25
    , type     = { 'character', 'particle', 'leaf-particle', 'flying-text', 'corpse', 'resource', 'fish' }
    , invert   = true
    }

  return #es > 0
end

local function scan (x,y,a,d,r,f)
  for i = d, d + r do
    local x = x + math.cos(a) * i
    local y = y + math.sin(a) * i
    if f (x,y) then return i end
  end
  return d + r
end

function warpWord (range)
  if not range then range = warpRange end
  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 0

  d = scan (pos.x, pos.y, a, d, range, col)

  if d > 1 then
    d = d - 1
  else
    -- end
    d = scan (pos.x, pos.y, a, d, range, function (x,y)
      return not col(x,y)
    end)

    d = scan (pos.x, pos.y, a, d, range, col)
  end

  local x = pos.x + math.cos(a) * d
  local y = pos.y + math.sin(a) * d

  pl.teleport ({x, y})
end

function warpEnd (range)
  if not range then range = warpRange end

  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 0

  d = scan (pos.x, pos.y, a, d, range, col)
  d = scan (pos.x, pos.y, a, d, range, function (x,y)
    return not col(x,y)
  end)

  local x = pos.x + math.cos(a) * d
  local y = pos.y + math.sin(a) * d
  pl.teleport ({x, y})
end

function warpShort ()
  local pos = pl.position
  local a   = (pl.character.orientation - 0.25) * math.pi * 2
  local d   = 20
  d = scan (pos.x, pos.y, a, d, warpRange, function (x,y)
    return not col(x,y)
  end)
  local x = pos.x + math.cos(a) * d
  local y = pos.y + math.sin(a) * d
  pl.teleport ({x, y})
end
