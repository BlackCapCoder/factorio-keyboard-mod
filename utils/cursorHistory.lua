require ('utils.windowzipper')


local function compare (a, b)
  if a == b then return true end
  if not a and b then return false end
  if a and not b then return false end
  if a.type ~= b.type then return false end
  if a.name ~= b.name then return false end
  return true
end

local cursorLog      = WindowZipper (10, compare)
cursorLog.isBrowsing = false
local expectGhost    = nil

---

local function setQuickBarSlot (n, stack)
  local off = (pl.get_active_quick_bar_page(1) - 1) * 10
  pl.set_quick_bar_slot(off + n, stack)
end

local function render ()
  local arr = cursorLog.toArray ()
  for i = 1, 10 do
    local stack = arr[#arr + 1 - i]
    setQuickBarSlot (i, stack)
  end
end

local function unrender ()
  local off = (pl.get_active_quick_bar_page(1) - 1) * 10
  for i = 10, 1, -1 do
    local item = pl.get_quick_bar_slot(off + i)
    if item then cursorLog.push(item) end
  end
end

---

function updateCursorStack ()
  local cursor = _getCursor ()
  local focal  = cursorLog.getCursor ()

  -- Cursor cleared
  if not cursor then
    if focal and expectGhost and focal.name == expectGhost.name then
      _setCursor (focal)
    else
      cursorLog.isBrowsing = false
    end
    expectGhost = nil
    return
  end

  expectGhost = nil

  -- Browsing
  if compare (cursor, focal) then
    return
  end

  --------
  -- This is a new item

  -- Already in history?
  if cursorLog.find (cursor) then
    cursorLog.isBrowsing = true
    cursorLog.promote() -- ?
    render()
    return
  end

  cursorLog.isBrowsing = false
  -- cursorLog.push    (cursor)
  -- cursorLog.jumpEnd ()
  -- cursorLog.isBrowsing = true
  -- render()
end

----------

local function verify ()
  local cur    = cursorLog.getCursor ()
  local actual = _getCursor ()
  return compare (cur, actual)
end

function cursorHistoryPrev ()
  if cursorLog.empty () then return end

  if not cursorLog.isBrowsing or not verify () then
    cursorLog.isBrowsing = true
    cursorLog.jumpEnd ()
  else
    if cursorLog.atBeginning () then return end
    cursorLog.prev ()
  end

  _setCursor (cursorLog.getCursor ())
  render()
end

function cursorHistoryNext ()
  if cursorLog.empty () then return end

  if not cursorLog.isBrowsing or not verify () then
    cursorLog.isBrowsing = true
    cursorLog.jumpBeginning ()
  else
    if cursorLog.atEnd () then return end
    cursorLog.next ()
  end

  _setCursor (cursorLog.getCursor ())
  render()
end

function cursorHistoryPromote ()
  local x = _getCursor ()
  if not x then end
  cursorLog.pushOrPromote (x)
  render()
end

function cursorHistoryDelete ()
  if cursorLog.empty () then return end
  if not cursorLog.isBrowsing and not cursorLog.find(_getCursor()) then
    return
  end

  cursorLog.delete ()
  _setCursor (cursorLog.getCursor ())
  if cursorLog.empty() then cursorLog.isBrowsing=false end

  render()
end

----------

onEvent (defines.events.on_player_cursor_stack_changed, updateCursorStack)

onEvent (defines.events.on_built_entity, function (ev)
  if not ev.stack.valid_for_read then return end

  -- If the player run out of items we want to replace the
  -- cursor stack with a ghost, rather than clearing it.
  if ev.stack.count == 1 then
    expectGhost = ev.stack.prototype
  end

  cursorLog.pushOrPromote (ev.stack.prototype)
  render()
end)

-- If we are holding the ghost of an item that we then pick up
-- replace the ghost with the real deal
onEvent (defines.events.on_player_main_inventory_changed, function (ev)
  if not cursorLog.isBrowsing then return end
  if not pl.cursor_ghost then return end

  local stack
    = pl.get_main_inventory()
    . find_item_stack (pl.cursor_ghost.name)

  if not stack then return end

  pl.cursor_ghost = nil
  pl.cursor_stack.swap_stack (stack)
end)

onEvent (defines.events.on_pre_player_crafted_item, function (ev)
  local r = ev.recipe
  if not r.valid then return end
  if not r.products then return end

  for i = 1, #r.products do
    local p    = r.products[i]
    local item = game.item_prototypes[p.name]
    cursorLog.pushOrPromote (item)
  end

  render()
end)

script.on_nth_tick(2, function ()
  unrender()
  script.on_nth_tick(2, nil)
end)
