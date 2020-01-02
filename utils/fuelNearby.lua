require ('utils.linked')


local function fuelWithStack (bs, f, log)
  local items = f.count
  local loop  = true

  while loop and items > 0 and bs.len > 0 do
    local quot = math.floor(items / bs.len)
    if quot == 0 then quot = 1 end
    loop = false

    bs.filter (function (b)
      if items == 0 then return false end

      local cnt = b.burner.inventory.insert ({name = f.name, count = quot})

      local page = log[b.unit_number].inserted
      if not page[f.name] then page[f.name] = 0 end
      page[f.name] = page[f.name] + cnt

      if cnt > 0 then
        loop  = true
        items = items - cnt
      end

      return cnt == quot
    end)
  end

  f.count = items
end

local function fuelWithStacks (targets, sources)
  local log = {}

  for b in targets.upwards() do
    log[b.unit_number] = { pos = b.position, inserted = {} }
  end

  for _, stack in pairs(sources) do
    local cat = stack.prototype.fuel_category
    local ts  = targets.clone()
    ts.filter (function (b)
      return b.burner.fuel_categories[cat]
         and b.burner.inventory.can_insert(stack)
    end)
    fuelWithStack (ts, stack, log)
  end

  -- Draw text
  for _, v in pairs (log) do
    for n,cnt in pairs (v.inserted) do
      pl.surface.create_entity {
        name     = "flying-text",
        position = { v.pos.x - 0.5, v.pos.y },
        text     = {"", cnt, " ", n},
        color    = { r = 1, g = 1, b = 1 }
      }
    end
  end
end

local function findTargets ()
  local targets = LinkedList (200)
  local sel     = pl.selected

  if sel ~= nil and sel.burner ~= nil then
    targets.push (sel)
  else
    for _, e in pairs(pl.surface.find_entities_filtered({position = pl.position, radius = 12})) do
      if e.burner ~= nil then targets.push(e) end
    end
  end

  cascade (targets)

  return targets
end

local function fuelStacks ()
  local sources = {}
  local cur     = pl.cursor_stack

  if cur.valid_for_read and cur ~= nil and cur.prototype.fuel_category ~= nil then
    sources[0] = cur
  else
    local inv = pl.get_main_inventory()
    for i = 1, #inv do
      local s = inv[i]

      if    s ~= nil
        and s.valid_for_read
        and s.prototype.fuel_category ~= nil
        then
        sources[#sources + 1] = s
      end
    end
  end

  return sources
end

function fuelNearby ()
  local targets = findTargets ()
  local sources = fuelStacks  ()
  fuelWithStacks(targets, sources)
end

function fuelNearbyEq ()
  local targets = findTargets ()
  local old_size = pl.character_inventory_slots_bonus
  pl.character_inventory_slots_bonus = 10*old_size+2000

  local pinv = pl.get_main_inventory()
  local extracted = {}

  for t in targets.upwards() do
    local inv = t.burner.inventory
    for i = 1, #inv do
      local s = inv[i]
      pinv.insert(s)
      inv.remove(s)
    end
    inv = t.get_output_inventory()
    if inv then
      for i = 1, #inv do
        local s = inv[i]
        if s and s.valid_for_read then
          if not extracted[s.name] then extracted[s.name] = 0 end
          extracted[s.name] = extracted[s.name] + s.count
          pinv.insert(s)
          inv.remove(s)
        end
      end
    end
  end

  local sources = fuelStacks ()
  fuelWithStacks(targets, sources)

  pl.character_inventory_slots_bonus = old_size

  local pos = pl.position
  for n, cnt in pairs (extracted) do
    pl.surface.create_entity {
      name     = "flying-text",
      position = { pos.x - 0.5, pos.y - 2.0 },
      text     = {"", cnt, " ", n},
      color    = { r = 1, g = 1, b = 1 }
    }
  end
end


-------------


function keys (t)
  local res = {}
  for k, _ in pairs(t) do res[#res + 1] = k end
  return res
end


function cascade (res)
  local loop = true
  local cur  = res.bottom
  local ns   = {}

  for e in res.upwards() do
    ns[e.name] = true
  end

  while cur ~= nil and res.len < res.limit do
    local v = cur.value

    for _, e in pairs(v.surface.find_entities_filtered({position = v.position, radius = 3, name = keys(ns) })) do
      local skip = false

      for i in res.upwards() do
        if i.position.x == e.position.x and i.position.y == e.position.y then
           skip = true
           break
         end
      end

      if not skip then
        res.push (e)
        ns[e.name] = true
      end
    end

    cur = cur.next
  end
end

