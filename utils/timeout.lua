function timeout (ms, f)
  local tick = game.tick + math.ceil ((ms / 1000) * 60)

  local function remove ()
    script.on_nth_tick (tick, nil)
  end

  script.on_nth_tick (tick, function ()
    remove ()
    f      ()
  end)

  return remove
end
