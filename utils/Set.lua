function Set ()
  local wad = {}
  local set = {}


  set.insert = function (x)
    wad[x] = true
  end

  set.delete = function (x)
    wad[x] = nil
  end

  set.member = function (x)
    return wad[x] ~= nil
  end

  return set
end
