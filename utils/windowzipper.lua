function WindowZipper (window, cmp)
  local prot  = {}

  local arr   = {}
  local index = 0
  local size  = 0

  if not cmp then
    cmp = function (x, y) return x == y end
  end


  prot.empty = function ()
    return size == 0
  end

  prot.full = function ()
    return size == window
  end


  prot.atBeginning = function ()
    return index <= 1
  end

  prot.atEnd = function ()
    return index >= size
  end


  prot.push = function (elem)
    if prot.full () then
      for i = 2,window do
        arr[i-1] = arr[i]
      end
      arr[window] = elem
    else
      if index < 1 then index = 1 end
      size      = size + 1
      arr[size] = elem
    end
  end

  prot.next = function ()
    if prot.atEnd () then return false end
    index = index + 1
    return true
  end

  prot.prev = function ()
    if prot.atBeginning () then return false end
    index = index - 1
    return true
  end


  prot.jumpBeginning = function ()
    index = math.min (size, 1)
  end

  prot.jumpEnd = function ()
    index = size
  end


  prot.getCursor = function ()
    if prot.empty () then return nil end
    return arr[index]
  end

  prot.setCursor = function (x)
    if prot.empty () then prot.push(x) end
    arr[index] = x
  end


  prot.member = function (elem)
    if prot.empty () then return false end
    for i = 1,size do
      if cmp(arr[i], elem) then return true end
    end
    return false
  end

  prot.find = function (elem)
    if prot.empty () then return false end
    for i = 1,size do
      if cmp(arr[i], elem) then
        index = i
        return true
      end
    end
    return false
  end


  prot.promote = function ()
    if prot.empty () then return end
    if prot.atEnd () then return end

    local x = prot.getCursor ()

    for i = (index + 1),size do
      arr[i-1] = arr [i]
    end

    arr[size] = x
    index = size
  end

  prot.delete = function ()
    if prot.empty () then return end

    arr[index] = nil
    for i = (index + 1), (size + 1) do
      arr[i-1] = arr[i]
    end

    size  = size - 1
    index = math.max(1, index - 1)
  end

  prot.pushOrPromote = function (elem)
    prot.jumpBeginning ()

    while not cmp (prot.getCursor (), elem) and prot.next () do
    end

    if cmp (prot.getCursor (), elem) then
      prot.promote ()
    else
      prot.push (elem)
    end
  end

  prot.pretty = function ()
    if prot.empty () then return "" end

    local str = ""
    local pre = ""

    for i=1,size do
      local x = arr[i]
      if x == nil then x = 'nil' end
      str = str .. pre .. x
      if i == index then str = str .. '*' end
      pre = " -> "
    end

    return str
  end

  prot.toArray = function ()
    return arr
  end

  prot.getIndex = function () return index end


  return prot
end
