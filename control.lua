require ('utils.eventWrapper')
require ('utils.timeout')
require ('utils.player')
require ('utils.keys')

require ('utils.flashlight')
-- require ('utils.autowalk')
-- require ('utils.inventory')

require ('utils.fuelNearby')
require ('utils.craftingQueue')
require ('utils.jumplist')
require ('utils.warp')
require ('utils.cursorHistory')
require ('utils.related')



------------- Yank selected

function yankSelected ()
  local sel = pl.selected
  if sel == nil then return end

  local name = sel.name
  if name == 'entity-ghost' then
    name = sel.ghost_name
  end

  local item = game.item_prototypes[name]
  if not item then return end
  _setCursor (item)

  updateCursorStack ()
end

script.on_event("yank-selected", yankSelected)


------------- Cursor history

script.on_event("cursor-item-prev", cursorHistoryPrev)
script.on_event("cursor-item-next", cursorHistoryNext)

nmapf ('O', cursorHistoryPromote)
nmapf ('I', cursorHistoryDelete)

nmapf ('n', relatedItemNext)
nmapf ('p', relatedItemPrev)
nmapf ('gn', relatedItemTierUp)
nmapf ('gp', relatedItemTierDown)

------------- Insert fuel

-- script.on_event("insert-fuel", fuelNearby)
nmapf('F', fuelNearby)
nmapf('<c-f>', fuelNearbyEq)


------------- Craft cursor

function craftCursor (count)
  local cur = getCursor ()
  if cur == nil then return end

  local r  = pl.force.recipes[cur]
  if r == nil then return end

  pl.begin_crafting({count = count, recipe = r, silent = false})
end

-- If cursor was a ghost, swap to the crafted item

onEvent (defines.events.on_player_crafted_item, function (ev)
  local gh = pl.cursor_ghost
  if gh == nil or ev == nil or ev.item_stack == nil or gh.name ~= ev.item_stack.name then return end
  pl.cursor_stack.swap_stack (ev.item_stack)
end)


script.on_event("craft-cursor", function (ev)
  craftCursor (1)
end)

script.on_event("craft-cursor-five", function (ev)
  craftCursor (5)
end)


------------- Game Speed

function tellSpeed ()
  game.print("Speed: " .. game.speed)
end

script.on_event("speed-reset", function (ev)
  game.speed = 1.0
  tellSpeed ()
end)

script.on_event("speed-up", function (ev)
  game.speed = game.speed * 2
  tellSpeed ()
end)

script.on_event("speed-down", function (ev)
  game.speed = game.speed / 2
  tellSpeed ()
end)


------------------


nmapf ('tq', toggleCraftingQueueMode)
nmapf ('tf', toggleFlashlight)
nmapf ('tm', function ()
  pl.game_view_settings.show_minimap = not pl.game_view_settings.show_minimap
end)
nmapf ('ts', function ()
  pl.game_view_settings.show_shortcut_bar = not pl.game_view_settings.show_shortcut_bar
end)

nmapf ('w', warpShort)
nmapf ('W', warpWord)
nmapf ('E', warpEnd)

------------------

nmapf ('gm', function ()
  if pl.render_mode == defines.render_mode.game then
    pl.open_map  (pl.position, 0.2)
  else
    pl.close_map ()
  end
end)
nmapf ('gw', function ()
  if pl.render_mode == defines.render_mode.game then
    pl.zoom_to_world(pl.position)
  else
    pl.close_map ()
  end
end)

nmapf ('gt', function ()
  pl.open_technology_gui()
end)

nmapf ('u', function ()
  pl.opened = pl
end)



------------

-- onEvent (defines.events.on_built_entity, function (ev)
--   pl.selected = ev.created_entity
-- end)

-- local inv
--
-- nmapf ('gi', function ()
--   if not inv then
--     inv = Inventory (pl)
--   end
--   inv.toggle ()
-- end)

-- nmapf ('h', function ()
--   if not inv or not inv.isOpen then return end
--   inv.moveSelLeft ()
-- end)
--
-- nmapf ('l', function ()
--   if not inv or not inv.isOpen then return end
--   inv.moveSelRight ()
-- end)
--
-- nmapf ('j', function ()
--   if not inv or not inv.isOpen then return end
--   inv.moveSelDown ()
-- end)
--
-- nmapf ('k', function ()
--   if not inv or not inv.isOpen then return end
--   inv.moveSelUp ()
-- end)

