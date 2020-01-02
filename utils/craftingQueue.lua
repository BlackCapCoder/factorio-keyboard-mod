local Modes =
  { back           = 0
  , front          = 1
  , frontAfterNext = 2
  }

local mode         = Modes.back
local pendingItem  = nil
local busyQueueing = false

function toggleCraftingQueueMode ()
  if mode == Modes.back then
    mode = Modes.frontAfterNext
    pl.print ("Queueing to front")
  else
    mode = Modes.back
    pl.print ("Queueing to back")
  end
end


---------------

local function clearQueue ()
  local queue = {}

  while pl.crafting_queue do
    local ind = pl.crafting_queue[#pl.crafting_queue].index
    local rec = pl.crafting_queue[#pl.crafting_queue].recipe
    local cou = pl.crafting_queue[#pl.crafting_queue].count

    table.insert (queue, {recipe=rec, count=cou})
    pl.cancel_crafting ({index=ind, count=cou})
  end

  return queue
end

local function queueFront (item)

  -- temporarily increase inventory size to prevent dumping
  local old_size = pl.character_inventory_slots_bonus
  pl.character_inventory_slots_bonus = 10*old_size+2000

  local save_queue  = clearQueue ()
  local front_craft = item

  -- add new item
  pl.begin_crafting {count=front_craft.count, recipe=front_craft.recipe, silent=true}

  -- add rest of queue
  for i = #save_queue,1,-1  do
    local v = save_queue[i]
    pl.begin_crafting {count = v.count, recipe = v.recipe}
  end

  -- revert inventory size
  pl.character_inventory_slots_bonus = old_size
end

local function queueFrontAfterNext (item)
  onEvent1 (defines.events.on_player_crafted_item, function ()
    busyQueueing = true
    queueFront (item)
    busyQueueing = false
  end)
end

onEvent (defines.events.on_pre_player_crafted_item, function ()
  -- Default behavior
  if mode == Modes.back then return end

  -- Already queueing?
  if busyQueueing then return end

  busyQueueing = true

  local item = pl.crafting_queue[pl.crafting_queue_size]
  local copy =
    { recipe = item.recipe
    , count  = item.count }

  pl.cancel_crafting
    { index = item.index
    , count = item.count }

  repeat
    -- Is this the only item being crafted?
    if pl.crafting_queue_size == 0 then
      pl.begin_crafting {count=copy.count, recipe=copy.recipe, silent=true}
      break
    end

    if mode == Modes.front then
      queueFront (copy)
      break
    end

    if mode == Modes.frontAfterNext then
      queueFrontAfterNext (copy)
      break
    end

  until true

  busyQueueing = false
end)

