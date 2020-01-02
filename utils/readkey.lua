------------ Read single key

local textbox  = nil
local callback = nil

function readkey (_callback)
  callback = _callback

  textbox = pl.gui.top.add
    { type = "textfield"
    , name = "readkey_textfield"
    , clear_and_focus_on_right_click = false
    -- , lose_focus_on_confirm = true
    }

  -- hide it off-screen
  textbox.style.width      = 1
  textbox.style.height     = 1
  textbox.style.top_margin = -100

  textbox.focus()
end

script.on_event(defines.events.on_gui_text_changed, function (ev)
  if ev.element.index ~= textbox.index then return end
  if callback then callback (textbox.text) end

  textbox.destroy ()
end)
