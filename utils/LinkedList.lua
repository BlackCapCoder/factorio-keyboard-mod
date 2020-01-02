function LinkedNode (value)
  local node = { value = value }

  node.append = function (value)
    local old = node.up

    node.up      = LinkedNode (value)
    node.up.down = node

    if old ~= nil then
      node.up.up = old
      old.down   = node.up
    end

    return node.up
  end

  node.prepend = function (value)
    local old = node.down

    node.down    = LinkedNode (value)
    node.down.up = node

    if old ~= nil then
      node.down.down = old
      old.up         = node.down
    end

    return node.down
  end

  node.deleteUp = function ()
    if node.up == nil then return false end

    node.up = node.up.up

    if node.up ~= nil then
      node.up.down = node
    end

    return true
  end

  node.deleteDown = function ()
    if node.down == nil then return false end

    node.down = node.down.down

    if node.down ~= nil then
      node.down.up = node
    end

    return true
  end

  return node
end
