local PREV = 0
local NEXT = 1
local TIERUP = 2
local TIERDOWN = 3

local function category (item)
  if not item then return "" end
  local o = item.order
  local b = string.find(o,'[',1,true)
  local e = string.find(o,']',1,true)
  local d = string.find(o,'-',1,true)
  if b == nil then b = 1 end
  if e == nil then e = #o end
  if d == nil then d = #o end
  return string.sub(o,b,math.min(e,d))
end

local function relatedItem (dir)
  local cur = _getCursor ()
  if not cur then return end

  local filter
    = { filter   = "subgroup"
      , subgroup = cur.subgroup.name
      }

  local res = game.get_filtered_item_prototypes({filter})

  local gs   = {}
  local x    = nil
  local tier = nil
  local index = nil
  local count = 0

  for k, v in pairs(res) do
    if not v.has_flag('hidden') then
      local cat = category (v)

      if x == nil or cat ~= x then
        x = cat
        gs[cat] = {v}
        count = count + 1
      else
        gs[cat][#gs[cat] + 1] = v
      end

      if not tier and cur.name == v.name then
        index = count
        tier  = #gs[cat]
      end
    end
  end

  ---

  if dir == PREV then
    if index == 1 then index = count else index = index - 1 end
  else
    if dir == NEXT then
      if index == count then index = 1 else index = index + 1 end
    end
  end

  local i = 1
  local pick = nil

  for _,v in pairs(gs) do
    if i == index then
      local t = tier

      if dir == TIERUP then
        t = t + 1
        if t > #v then t = 1 end
      end
      if dir == TIERDOWN then
        t = t - 1
        if t < 1 then t = #v end
      end

      pick = v[math.max(1, math.min(t, #v))]
      break
    end
    i = i + 1
  end

  _setCursor (pick)
end

function relatedItemPrev ()
  relatedItem(PREV)
end
function relatedItemNext ()
  relatedItem(NEXT)
end
function relatedItemTierDown ()
  relatedItem(TIERDOWN)
end
function relatedItemTierUp ()
  relatedItem(TIERUP)
end
