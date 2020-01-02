require "prototypes.entity.entities"

data:extend
({
  {
    type = "custom-input",
    name = "speed-reset",
    key_sequence = "=",
    order = 'a-a',
  },
  {
    type = "custom-input",
    name = "speed-up",
    key_sequence = "]",
    order = 'a-b',
  },
  {
    type = "custom-input",
    name = "speed-down",
    key_sequence = "[",
    order = 'a-c',
  },

  {
    type = "custom-input",
    name = "cursor-item-prev",
    key_sequence = "O",
    order = 'b-a',
  },
  {
    type = "custom-input",
    name = "cursor-item-next",
    key_sequence = "I",
    order = 'b-b',
  },

  {
    type = "custom-input",
    name = "yank-selected",
    key_sequence = "Y",
    order = 'c-a',
  },
  {
    type = "custom-input",
    name = "craft-cursor",
    key_sequence = "C",
    order = 'c-b',
  },
  {
    type = "custom-input",
    name = "craft-cursor-five",
    key_sequence = "SHIFT + C",
    order = 'c-c',
  },

  {
    type = "custom-input",
    name = "insert-fuel",
    key_sequence = "F",
    order = 'd-a',
  },

})


------------------
-- Add hooks for all the keys!


local digits = "0123456789"
local lower  = "abcdefghijklmnopqrstuvwxyz"
local upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local keys =
  { { '0'  , '0' }
  , { '1'  , '1' }
  , { '2'  , '2' }
  , { '3'  , '3' }
  , { '4'  , '4' }
  , { '5'  , '5' }
  , { '6'  , '6' }
  , { '7'  , '7' }
  , { '8'  , '8' }
  , { '9'  , '9' }

  , { 'a'  , 'A' }
  , { 'b'  , 'B' }
  , { 'c'  , 'C' }
  , { 'd'  , 'D' }
  , { 'e'  , 'E' }
  , { 'f'  , 'F' }
  , { 'g'  , 'G' }
  , { 'h'  , 'H' }
  , { 'i'  , 'I' }
  , { 'j'  , 'J' }
  , { 'k'  , 'K' }
  , { 'l'  , 'L' }
  , { 'm'  , 'M' }
  , { 'n'  , 'N' }
  , { 'o'  , 'O' }
  , { 'p'  , 'P' }
  , { 'q'  , 'Q' }
  , { 'r'  , 'R' }
  , { 's'  , 'S' }
  , { 't'  , 'T' }
  , { 'u'  , 'U' }
  , { 'v'  , 'V' }
  , { 'w'  , 'W' }
  , { 'x'  , 'X' }
  , { 'y'  , 'Y' }
  , { 'z'  , 'Z' }

  , { 'A'  , 'SHIFT + A' }
  , { 'B'  , 'SHIFT + B' }
  , { 'C'  , 'SHIFT + C' }
  , { 'D'  , 'SHIFT + D' }
  , { 'E'  , 'SHIFT + E' }
  , { 'F'  , 'SHIFT + F' }
  , { 'G'  , 'SHIFT + G' }
  , { 'H'  , 'SHIFT + H' }
  , { 'I'  , 'SHIFT + I' }
  , { 'J'  , 'SHIFT + J' }
  , { 'K'  , 'SHIFT + K' }
  , { 'L'  , 'SHIFT + L' }
  , { 'M'  , 'SHIFT + M' }
  , { 'N'  , 'SHIFT + N' }
  , { 'O'  , 'SHIFT + O' }
  , { 'P'  , 'SHIFT + P' }
  , { 'Q'  , 'SHIFT + Q' }
  , { 'R'  , 'SHIFT + R' }
  , { 'S'  , 'SHIFT + S' }
  , { 'T'  , 'SHIFT + T' }
  , { 'U'  , 'SHIFT + U' }
  , { 'V'  , 'SHIFT + V' }
  , { 'W'  , 'SHIFT + W' }
  , { 'X'  , 'SHIFT + X' }
  , { 'Y'  , 'SHIFT + Y' }
  , { 'Z'  , 'SHIFT + Z' }

  , { ' '  , 'SPACE' }
  , { '-'  , 'MINUS' }
  , { '='  , 'EQUALS' }
  , { '<'  , 'LEFTBRACKET' }
  , { '>'  , 'RIGHTBRACKET' }
  , { '\\' , 'BACKSLASH' }
  , { '|'  , 'NONUSHASH' }
  , { '/'  , 'SLASH' }
  , { ';'  , 'SEMICOLON' }
  , { "'"  , 'APOSTROPHE' }
  , { ","  , 'COMMA' }
  , { "\0" , 'ESCAPE' }
  , { "\t" , 'TAB' }
  }

local binds  = {}
local j      = 1


function add (short, long, sort)
  binds[j] =
    { type = "custom-input"
    , name = "key-" .. short
    , key_sequence = long
    , order = 'z-' .. sort .. '-' .. short
    }

  j = j + 1
end

function addWithMods (short, long, sort)
  add (short, long, sort)
  add ('C-' .. short, 'CONTROL + ' .. long, sort)
  add ('A-' .. short, 'ALT + ' .. long, sort)
  -- add ('C-A-' .. short, 'CONTROL + ALT + ' .. long, sort)
end

for i, v in pairs (keys) do
  addWithMods (v[1], v[2], i)
end

-- for i = 1, #digits do
--   local d = digits:sub(i, i)
--   addWithMods (d, d, 'a')
-- end
--
-- for i = 1, #lower do
--   local l = lower:sub(i, i)
--   local u = upper:sub(i, i)
--
--   -- lower
--   addWithMods (l, u, 'b')
--
--   -- upper
--   addWithMods (u, "SHIFT + " .. u, 'c')
-- end

data:extend (binds)
