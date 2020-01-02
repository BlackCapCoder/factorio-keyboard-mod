function toggleFlashlight ()
  if global.flashlight_state == nil then
    global.flashlight_state = true
  end

  global.flashlight_state = not global.flashlight_state

  if global.flashlight_state then
    pl.disable_flashlight ()
  else
    pl.enable_flashlight ()
  end

  pl.surface.create_entity({name = "flashlight-button-press", position = pl.position})
end
