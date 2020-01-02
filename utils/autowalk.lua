local isWalking = false

local function drawPath (path, step)
  local from = path[2].position

  for i = 2, #path, step do
    path[i].lineID = rendering.draw_line
      { color          = { r = 1, g = 1, b = 1 }
      , width          = 4
      , gap_length     = 0.9
      , dash_length    = 0.7
      , from           = from
      , to             = path[i].position
      , players        = { pl.index }
      , surface        = pl.surface
      , draw_on_ground = false
      , time_to_live   = 60 * 60
      }
    from = path[i].position
  end
end

local function walkTowards (goal, callback)
  if isWalking then return nil end
  isWalking = true

  local eid

  local function cancel ()
    removeEvent (eid)
    isWalking = false
  end

  local dirs = {}
  dirs[1] = defines.direction.northwest
  dirs[2] = defines.direction.north
  dirs[3] = defines.direction.northeast
  dirs[4] = defines.direction.east
  dirs[5] = defines.direction.southeast
  dirs[6] = defines.direction.south
  dirs[7] = defines.direction.southwest
  dirs[8] = defines.direction.west

  local function sample (pos)
    local a   = math.atan2 (goal.y - pos.y, goal.x - pos.x)
    local ix  = math.ceil  (4 * (a + math.pi) / math.pi)
    local dir = dirs[ix]
    return dir
  end

  local oldDist = 0
  local dir = sample (pl.position)

  eid = onEvent (defines.events.on_tick, function (ev)
    local pos  = pl.position
    local dist = math.abs(goal.x - pos.x) + math.abs(goal.y - pos.y)

    if dist < 0.2 or math.abs (dist - oldDist) < 0.02 then
      pl.teleport (goal)
      cancel ()
      if callback then callback () end
      return
    end

    if dist > oldDist then
      dir = sample (pos)
    end

    oldDist = dist

    pl.walking_state =
      { walking   = true
      , direction = dir }
  end)

  return cancel
end

local function walkPath (path, callback)
  local ix = 3
  local cancelWalk

  local function next ()
    if path[ix].lineID then
      rendering.set_draw_on_ground (path[ix].lineID, true)
    end
    cancelWalk = walkTowards (path[ix].position, function ()
      if path[ix].lineID and rendering.is_valid(path[ix].lineID) then
        rendering.destroy(path[ix].lineID)
      end

      ix = ix + 1

      if ix > #path then
        if callback then callback (true) end
      else
        next ()
      end
    end)
  end

  next ()

  return function ()
    if cancelWalk then cancelWalk () end

    for ix = 1, #path do
      if path[ix].lineID and rendering.is_valid (path[ix].lineID) then
        rendering.destroy(path[ix].lineID)
      end
    end
  end
end

local function cleanPath (path)
  local res  = {}
  local prev = path[1].position
  local _dx, _dy
  local cnt = 0

  local function sample (pos)
    local a   = math.atan2 (goal.y - pos.y, goal.x - pos.x)
    local ix  = math.ceil  (4 * (a + math.pi) / math.pi)
    local dir = dirs[ix]
    return dir
  end

  for i = 2, #path do
    local pos = path[i].position
    local dx = pos.x - prev.x
    local dy = pos.y - prev.y

    if not (dx == _dx and dy == _dy) then
      cnt = cnt + 1
      res[cnt] = { position = {x = prev.x, y = prev.y} }
    end

    prev = pos
    _dx = dx
    _dy = dy
  end

  cnt = cnt + 1
  res[cnt] = { position = {x = path[#path].position.x, y = path[#path].position.y} }

  return res
end


function walkTo (goal, callback)
  local dist = math.abs(goal.x - pl.position.x) + math.abs(goal.y - pl.position.y)

  if dist < 8 then
    if callback then callback (true) end
    return
  end

  local eid, pid, wid

  local res = 1
  local col = { "object-layer", "water-tile" }

  local function pathfind ()
    pid = pl.surface.request_path
      { force          = game.forces["enemy"]
      , bounding_box   = pl.character.prototype.collision_box
      , start          = pl.position
      , radius         = math.max(pl.resource_reach_distance * 0.8, 1)
      , goal           = goal
      , can_open_gates = false
      , collision_mask = col
      , path_resolution_modifier = res
      , pathfind_flags =
        { low_priority = false
        -- , prefer_straight_paths = true
        , prefer_straight_paths = false
        }
      }

    eid = onEvent (defines.events.on_script_path_request_finished, function (ev)
      if ev.id ~= pid then return end
      removeEvent (eid)

      if ev.path == nil then
        if res == 1 then
          res = 3
          col = { "object-layer" }
          pathfind ()
          return
        end

        pl.print ("pathfinding failed")
        if callback then callback (false) end
        return
      end

      local pth = cleanPath (ev.path)

      drawPath (pth, 1)

      wid = walkPath (pth, callback)
    end)
  end

  pathfind ()

  local function cancel ()
    removeEvent (eid)
    if wid then wid () end
  end

  function cancelOnWalk ()
    getKey (function (key)
      if key == string.byte ('e') or
        key == string.byte ('s') or
        key == string.byte ('d') or
        key == string.byte ('f') then

        setMode ('normal')
        cancel ()
      else
        cancelOnWalk ()
      end

      return false
    end)
  end

  cancelOnWalk ()


  return cancel
end
