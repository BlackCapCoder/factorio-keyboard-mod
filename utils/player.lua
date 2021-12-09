-- Find player
pl = nil


script.on_nth_tick (1, function (ev)
  pl = game.players[1]

  pl.game_view_settings.show_shortcut_bar = false
  pl.game_view_settings.show_side_menu    = false

  --------- disable mouse
  -- pl.game_view_settings.update_entity_selection = false

  script.on_nth_tick (1, nil)
end)


local function toggleReserach ()
  pl.game_view_settings.show_research_info = pl.force.current_research ~= nil
end


onEvent (defines.events.on_research_started,  toggleReserach)
onEvent (defines.events.on_research_finished, toggleReserach)



---------- Cursor

function getCursor ()
  local cursor = pl.cursor_stack

  if not cursor.valid_for_read or cursor == nil then
    cursor = pl.cursor_ghost
  else
    if cursor.is_blueprint      or
      cursor.is_blueprint_book or
      cursor.is_selection_tool or
      cursor.is_deconstruction_item or
      cursor.is_upgrade_item then
      return nil
    end
  end

  if cursor == nil then
    return nil
  end

  return cursor.name
end

function _getCursor ()
  local cursor = pl.cursor_stack

  if not cursor.valid_for_read or cursor == nil then
    cursor = pl.cursor_ghost
  else
    if cursor.is_blueprint      or
      cursor.is_blueprint_book or
      cursor.is_selection_tool or
      cursor.is_deconstruction_item or
      cursor.is_upgrade_item then
      return nil
    end
  end

  if cursor == nil then
    return nil
  end

  return game.item_prototypes[cursor.name]
end

function setCursor (item)
  if item == nil then
    -- pl.clean_cursor ()
    return
  end

  local stack = pl.get_main_inventory().find_item_stack(item)

  if stack ~= nil then
    pl.cursor_stack.swap_stack (stack)
  else
    pl.cursor_ghost = item
  end
end

function _setCursor (stack)
  if not stack then
    -- pl.clean_cursor ()
    return
  end

  local _stack
    = pl.get_main_inventory()
    . find_item_stack (stack.name)

  if not _stack then
    -- pl.clean_cursor ()
    pl.cursor_ghost = stack
  else
    pl.cursor_ghost = nil
    pl.cursor_stack.swap_stack (_stack)
  end
end
