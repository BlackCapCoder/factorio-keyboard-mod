SELECTION_MODE_NEAREST = 0


local selection =
  { mode = SELECTION_MODE_NEAREST
  }

local function selectClosest ()
  local resources =
    pl.surface.find_entities_filtered
      { position = pl.position
      , radius   = pl.resource_reach_distance
      , type     = { 'character', 'particle', 'leaf-particle', 'flying-text', 'corpse' }
      , invert   = true
      }

  local target =
    pl.surface.get_closest (pl.position, resources)

  pl.selected = target
end

onEvent (defines.events.on_player_changed_position, function ()
  if not pl.game_view_settings.update_entity_selection then return end
  selectClosest()
end)

onEvent (defines.events.on_player_mined_entity, function (ev)
  if not pl.game_view_settings.update_entity_selection then return end
  if pl.selected ~= nil and pl.selected.unit_number == ev.entity.unit_number then
    selectClosest ()
  end
end)

onEvent (defines.events.on_selected_entity_changed, function (ev)
  if not pl.game_view_settings.update_entity_selection then return end
  if pl.selected == nil then selectClosest () end
end)

onEvent (defines.events.on_built_entity, function (ev)
  if not pl.game_view_settings.update_entity_selection then return end
  pl.selected = ev.created_entity
end)


----------

local pathfinding =
  { id        = nil
  , index     = nil
  , waypoints = nil
  }


function doPathfind ()
  if pathfinding.id == nil then return false end

  local pos = pl.position
  local goal, dist

  while pathfinding.index <= #pathfinding.waypoints do
    goal = pathfinding.waypoints[pathfinding.index].position
    dist = math.abs(goal.x - pos.x) + math.abs(goal.y - pos.y)

    if dist > 0.1 then break end

    if #pathfinding.waypoints > 10 then
      rendering.destroy(pathfinding.waypoints[pathfinding.index].lineID)
    end

    pathfinding.index = pathfinding.index + 1

    if pathfinding.index > #pathfinding.waypoints then
      pathfinding.id = nil
      if pathfinding.callback then pathfinding.callback () end
      return
    end
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

  local a  = math.atan2 (goal.y - pos.y, goal.x - pos.x)
  local ix = math.ceil  (4 * (a + math.pi) / math.pi)

  pl.walking_state =
    { walking   = true
    , direction = dirs[ix] }

  return true
end


------

local miningState
  = { target   = nil
    , callback = nil
    }

function doMining ()
  if miningState.target == nil then return false end

  if not miningState.target.valid then
    miningState.target = nil
    if miningState.callback then miningState.callback() end
    return true
  end

  pl.selected     = miningState.target
  pl.mining_state = { mining = true, position = miningState.target.position }

  if not pl.can_reach_entity(miningState.target) then
    walkTo (miningState.target.position, function ()
    end)
    return
  end

  return true
end


onEvent (defines.events.on_tick, function (ev)
  if doPathfind () then return end
  if doMining () then return end
end)


function walkTo (goal, callback)
  if pathfinding.id ~= nil then
    pathfinding.id = nil
    for _, w in pairs(pathfinding.waypoints) do
      resources.destroy(w.lineID)
    end
  end

  pathfinding.index     = 1
  pathfinding.waypoints = { { position = goal } }

  local dist = math.abs(goal.x - pl.position.x) + math.abs(goal.y - pl.position.y)
  if dist <= 1.5 then return end

  local x1 = pl.character.bounding_box.left_top.x - pl.position.x
  local y1 = pl.character.bounding_box.left_top.y - pl.position.y
  local x2 = pl.character.bounding_box.right_bottom.x - pl.position.x
  local y2 = pl.character.bounding_box.right_bottom.y - pl.position.y

  pathfinding.id = pl.surface.request_path
    { bounding_box = { left_top = { x1, y1 }, right_bottom = { x2, y2 } }
    , force          = pl.force
    , start          = pl.position
    , radius         = pl.resource_reach_distance * 0.8
    , goal           = goal
    , can_open_gates = false
    , collision_mask = { "water-tile", "object-layer" }
    , pathfind_flags =
      { low_priority = false
      }
    }

  pathfinding.callback = callback
end

script.on_event(defines.events.on_script_path_request_finished, function (ev)
  if ev.id ~= pathfinding.id then return end
  if ev.path == nil then
    game.print('nope')
    pathfinding.id = nil
    return
  end

  pathfinding.waypoints = ev.path

  if #ev.path <= 10 then return end

  local pred = pl.position

  for _, w in pairs (ev.path) do
    w.lineID = rendering.draw_line
      { color          = { r = 1, g = 1, b = 1 }
      , width          = 4
      , gap_length     = 5
      , dash_length    = 0.3
      , from           = pred
      , to             = w.position
      , players        = { pid }
      , surface        = pl.surface
      , draw_on_ground = false }

    pred = w.position
  end

end)


local function cancel ()
  pathfinding.id     = nil
  miningState.target = nil
  pl.game_view_settings.update_entity_selection = true
  setMode ('normal')
end

function getWood (radius)
  local resources =
    pl.surface.find_entities_filtered
      { position = pl.position
      , radius   = radius
      , type     = "tree"
      -- , name     = "copper-ore"
      }

  local target =
    pl.surface.get_closest (pl.position, resources)

  if target == nil then
    cancel ()
    return
  end

  setModeEx ('autowalk', 'normal')
  pl.game_view_settings.update_entity_selection = false

  miningState.target   = target
  miningState.callback = function () getWood (10) end
end

---------



mapf ('autowalk', 'e', cancel)
map  ('autowalk', 's' 'e')
map  ('autowalk', 'd' 'e')
map  ('autowalk', 'f' 'e')

nmapf ('g', function ()
  getWood (100)
end)

