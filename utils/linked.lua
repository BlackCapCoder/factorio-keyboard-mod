function LinkedList (lim)
  local ll =
    { len   = 0
    , limit = lim }

  local cnt = 0

  ll.onNodeDeleted = function (node) end
  ll.onNodeAdded   = function (node) end

  ll.push = function (x)
    if ll.len == 0 then
      ll.top    = { value = x, id = cnt }
      ll.bottom = ll.top
      ll.len    = ll.len + 1
    else
      if ll.len == ll.limit then
        ll.onNodeDeleted (ll.bottom)
        ll.bottom      = ll.bottom.next
        ll.bottom.prev = nil
        ll.top.next    = { value = x, prev = ll.top, id = cnt }
        ll.top         = ll.top.next
      else
        ll.top.next = { value = x, prev = ll.top, id = cnt }
        ll.top      = ll.top.next
        ll.len      = ll.len + 1
      end
    end

    cnt = cnt + 1
    ll.onNodeAdded (ll.top)
  end

  ll.upwards = function ()
    local cur = ll.bottom

    return function ()
      if cur ~= nil then
        local ret = cur.value
        cur = cur.next
        return ret
      end
    end
  end

  ll.filter = function (f)
    local cur = ll.bottom
    while cur ~= nil and ll.len > 0 do
      if not f (cur.value) then
        ll.deleteNode (cur)
      end
      cur = cur.next
    end
  end

  ll.clone = function ()
    local ret = LinkedList (ll.limit)
    for v in ll.upwards() do ret.push (v) end
    return ret
  end

  ll.deleteNode = function (node)
    ll.onNodeDeleted (node)

    if ll.len <= 1 then
      ll.up   = nil
      ll.down = nil
      ll.len  = 0
      return nil
    end

    local up   = node.next
    local down = node.prev
    local ret  = up

    if up ~= nil then
      up.prev = down
    else
      down.next = nil
      ll.top    = down
      ret       = down
    end

    if down ~= nil then
      down.next = up
    else
      ll.bottom = up
    end

    ll.len = ll.len - 1
    return ret
  end

  ll.pretty = function ()
    local acc = ""
    local pre = ""

    for n in ll.upwards() do
      acc = acc .. pre .. n
      pre = ", "
    end

    return acc
  end

  return ll
end
