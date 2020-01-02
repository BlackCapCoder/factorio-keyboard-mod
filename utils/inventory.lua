local stride = 10

function InventoryUI (player)
  local text_offset     = 0.05
  local text_size       = 0.9
  local scale           = 2.5
  local slot_brightness = 0.6

  local sname = "inventory-" .. player.name;
  local surf  = game.get_surface(sname)

  if surf == nil then
    surf = game.create_surface(snafe, game.default_map_gen_settings)
  end

  local ui  = player.gui.center['custom-inventory']
  local tab

  if ui == nil then
    ui = player.gui.center.add
      { type = "frame"
      , name = "custom-inventory"
      , direction = "vertical"
      , caption = {"", "inventory"}
      }

    ui.visible = false

    local tab = ui.add
      { type = "table"
      , column_count = stride
      }

    tab.style.top_padding = 10
    tab.style.bottom_padding = 10
    tab.style.width = (32 * scale / 2 + 4) * stride
  else
    tab = ui.children[1]
    tab.clear()
  end

  ------

  local function Slot (ix)
    local cam = tab.add
      { type = 'camera'
      , surface_index = surf.index
      , position = { x = ix, y = 0 }
      , zoom = scale
      }

    cam.style.width  = 32 * scale / 2
    cam.style.height = 32 * scale / 2
    cam.location = {x = 0, y = 0}

    local bg = rendering.draw_sprite
      { sprite  = "utility/equipment_slot"
      , target  = { x = ix, y = 0 }
      , surface = surf.index
      , tint    = { r = slot_brightness, g = slot_brightness, b = slot_brightness }
      }

    local item = rendering.draw_sprite
      { sprite  = "item/" .. "iron-ore"
      , target  = { x = ix, y = 0 }
      , x_scale = 0.8
      , y_scale = 0.8
      , surface = surf.index
      , visible = false
      }

    local text = rendering.draw_text
      { text      = {"", 0}
      , surface   = surf.index
      , target    = { x = ix + 0.5 - text_offset, y = (1 - text_size) / 2 - text_offset }
      , color     = { r = 1, g = 1, b = 1 }
      , alignment = 'right'
      , scale     = 0.8
      , visible   = false
      }

    -----

    local prot = {}


    prot.setSelected = function (sel)
      if sel then
        rendering.set_color (bg, { 1, 0.7, 0 })
      else
        rendering.set_color (bg, { slot_brightness, slot_brightness, slot_brightness })
      end
    end

    prot.setItemCount = function (cnt)
      if cnt and cnt > 0 then
        rendering.set_text    (text, {"", cnt})
        rendering.set_visible (text, true)
      else
        rendering.set_visible (text, false)
      end
    end

    prot.setItemType = function (name)
      if name then
        rendering.set_sprite  (item, "item/" .. name)
        rendering.set_visible (item, true)
      else
        rendering.set_visible (item, false)
      end
    end

    prot.getVisible = function ( ) return cam.visible end
    prot.setVisible = function (x) cam.visible = x end

    return prot
  end

  ------

  local slots        = {}
  local numSlots     = 0
  local numSlotsReal = 0
  local selected     = 0


  local prot = {}

  prot.getVisible = function ( ) return ui.visible end
  prot.setVisible = function (x) ui.visible = x end
  prot.toggleVisible = function ()
    ui.visible = not ui.visible
  end

  prot.getNumSlots = function ( ) return numSlots end
  prot.setNumSlots = function (x)
    for i = math.max(numSlotsReal, 1), x do
      slots[i] = Slot (i)
    end

    if x > numSlots then
      for i = math.max(numSlots, 1), math.min (x, numSlotsReal) do
        slots[i].setVisible(true)
      end
    else
      for i = x, numSlots do
        slots[i].setVisible   (false)
        slots[i].setSelected  (false)
        slots[i].setItemCount (0)
        slots[i].setItemType  (nil)
      end
    end

    numSlots     = math.max (numSlots,     x)
    numSlotsReal = math.max (numSlotsReal, x)

    if selected > numSlots then selected = 0 end
  end

  prot.setSlotItem = function (i, item, count)
    slots[i].setItemType  (item )
    slots[i].setItemCount (count)
  end

  prot.setSelectedSlot = function (x)
    if slots[selected] then
      slots[selected].setSelected (false)
    end
    if slots[x] then
      slots[x].setSelected (true)
    end
    selected = x
  end

  prot.getSelectedSlot = function () return selected end


  return prot
end


-----------


function Inventory (player)
  local ui  = InventoryUI (player)
  local inv = player.get_main_inventory ()

  ui.setNumSlots (#inv)

  for i = 1, #inv do
    local item = inv[i]

    if item.valid_for_read then
      ui.setSlotItem (i, item.name, item.count)
    end
  end

  ui.setSelectedSlot(1)

  ---

  local prot = {}

  prot.toggle = ui.toggleVisible
  prot.isOpen = function () return ui.getVisible () end

  prot.moveSelRight = function ()
    local i = ui.getSelectedSlot () - 1
    local x = i % stride
    local y = math.floor (i / stride)
    local cnt = ui.getNumSlots ()

    x = (x + 1) % stride

    if y * stride + x >= cnt then
      x = x % (cnt % stride)
    end

    ui.setSelectedSlot (y * stride + x + 1)
  end

  prot.moveSelLeft = function ()
    local i = ui.getSelectedSlot () - 1
    local x = i % stride
    local y = math.floor (i / stride)
    local cnt = ui.getNumSlots ()

    x = (x - 1) % stride

    if y * stride + x >= cnt then
      x = x % (cnt % stride)
    end

    ui.setSelectedSlot (y * stride + x + 1)
  end

  prot.moveSelUp = function ()
    local cnt  = ui.getNumSlots ()
    local rows = math.ceil (cnt / stride)
    local i    = ui.getSelectedSlot () - 1

    i = (i - stride) % (rows * stride)
    if (i >= cnt) then i = (i - stride) % cnt end

    ui.setSelectedSlot (i + 1)
  end

  prot.moveSelDown = function ()
    local cnt  = ui.getNumSlots ()
    local rows = math.ceil (cnt / stride)
    local i    = ui.getSelectedSlot () - 1

    i = (i + stride) % (rows * stride)
    if (i >= cnt) then i = i % stride end

    ui.setSelectedSlot (i + 1)
  end

  return prot
end
