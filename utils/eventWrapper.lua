local state   = {}
local remove  = {}
local counter = 0

local function uniqueID ()
  local id = counter
  counter = counter + 1
  return id
end

function removeEvent (id)
  remove[id] = true
end

function onEvent (event, callback)

  -- Add handler
  if state[event] == nil then
    script.on_event (event, function (args)
      local prev, cur

      prev = state[event]
      if prev == nil then return end
      cur = prev.next

      if remove[prev.id] then
        state[event]    = cur
        remove[prev.id] = nil

        if cur == nil then
          script.on_event (event, nil)
        end
      else
        prev.f (args)
      end

      while cur do
        if remove[cur.id] then
          prev.next      = cur.next
          remove[cur.id] = nil
        else
          cur.f (args)
        end

        prev = cur
        cur  = cur.next
      end
    end)
  end

  state[event] =
    { f    = callback
    , id   = uniqueID ()
    , next = state[event] }

  return state[event].id
end

function onEvent1 (event, callback)
  local id

  id = onEvent (event, function (args)
    callback (args)
    removeEvent (id)
  end)

  return id
end
