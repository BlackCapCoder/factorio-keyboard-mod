This is an opinionated collection of random convenience features for the game factorio,
with the common goal of making the game more accessible by keyboard.


# keys.lua

Factorio's keybinding system sucks. Every keybinding has to be
registered ahead of time, they can only be a single key each, and
you only get one "alternative" binding.


To get around this I simply register every possible key in the game and do the bookkeeping myself.


`keys.lua` is a mess of bit-twiddling because I am obsessive about performance, but the important bit is  the `nmapf` function it exposes:
```lua
-- calls toggleFlashlight if we press 't' followed by 'f'
nmapf ("tf", toggleFlashlight)

-- CTRL+p, Shift+F, o, o
nmapf ("<c-p>Foo", function ()
  game.print ("foo")
end)
```

Keybinds unfortunately has to be hard-coded into the mod - the system for users to configure plugin state is equally horrid -, but I would frankly be amazed if anyone but me ever used this mod.


# control.lua

`control.lua` is the entry point for factorio mods. I've thrown random little things here instead of giving them their own file:


#### craftCursor - `c`, `C`

`c` - Craft one more of the currently held item. (cursor item)

`C` - Craft five more of cursor item.

Additionally, if the player was holding the ghost of an item
at the time it was crafted, the ghost is replaced by the
real item.


#### yankSelected - `y`

If the player is hovering over an entity that exists
in item form, replace the cursor item with that item.


This is exactly like the "smart pipette" from the vanilla game. I am not positive if I had a good reason to reimplement it originally.


#### Change game speed

`=` - Set the game speed to 1.

`[` - Multiply the game speed by 2.

`]` - Divide the game speed by 2.


#### Toggle stuff

`tf` - Toggle the flashlight on or off

`tm` - Toggle the minimap

`ts` - Toggle the (useless) shortcut bar

`gm` - Open or close the world map

`gw` - Toggle between regular and zoom-to-world mode (god-mode)

`gt` - Toggle the technology gui

`u` - Toggle the inventory


There is no way for mod authors to add bindings to the
vanilla inventory screen (which is mouse-only!).

I have put some effort into creating my own, though!


# fuelNearby.lua

#### fuelNearby - `F`

Evenly distribute fuel items from the players inventory into nearby fuel
consuming machines.


If the player is hovering over a machine, only distribute fuel into
adjacent machines of the same type.


If the player is holding a stack of fuel items, only distribute this stack
instead of items from the players inventory.


#### fuelNearbyEq - `<C-f>`

Like `fuelNearby` but fuel is first extracted from the machines, then
evenly redistributed together with any fuel that the player might have
had in their inventory.


Additionally, this function will withdraw any product that is laying
around in the machines into the players inventory. Arguably this is
an unrelated feature that should be isolated into its own function..


# craftingQueue.lua

Allows changing the crafting queue order. Stolen from the "queue to back" mod
so that I can have fancy keybinds.


#### toggleCraftingQueueMode - `tq`

Toggle between vanilla queue to back and the new queue to front order.


Unlike the original "queue to back" mod, if a new item is added to the queue
while something else is being crafted I wait for one crafting operation
to complete before re-queuing- otherwise we would lose progress on the former
front of the queue!


Imagine ordering red science (super slow), and then figuring out that, in fact,
you also need laboratories; preferably before the science packs.
You throw the laboratories on the front of the queue, but, oh no- we just lost 4
seconds of crafting time that we had *invested* into the science pack. Heartbreaking!


You rush to the mod author and give him a friendly middle finger, and I think they might
have fixed this upstream now.


# windowzipper.lua

Provides the `WindowZipper` data-structure, which is like a regular array but:


It has a maximum length, a `Window`. If the window zipper is full and a new
item is pushed on to the end, one element is also deleted from the beginning.


One element is said to be in focus (that's the `Zipper` part). The focus can be
freely moved to any element.


# cursorHistory.lua

A `WindowZipper` (length 10) containing recently used items. An item
is either pushed onto or promoted to the end whenever the player
(1) crafts an item, or (2) builds something.


#### cursorHistoryPrev - `o`

If the players cursor is empty, move the focus to the end.
Otherwise, move the focus left. Finally, put the focused item in the players cursor


#### cursorHistoryNext - `i`

If the players cursor is empty, move the focus to the beginning.
Otherwise, move the focus right. Finally, put the focused item in the players cursor


#### cursorHistoryPromote - `O`

Promote (move) the focused element to the end. Focus stays with the promoted element.


#### cursorHistoryDelete - `I`

Delete the focused element from the window zipper. Focus gravitates towards the end.


# related.lua

Allows cycling through related items (same subgroup).

`belt -> splitter -> underground ..`


#### relatedItemNext - `n`

Change cursor item to the next "related" item


#### relatedItemPrev - `p`

Dual to `relatedItemNext`.


#### relatedItemTierUp - `gn`

Changes the cursor item to the next higher tier.

`yellow belt -> red belt -> blue belt`


Like `n` and `p`, `gn` and `gp` wraps around. That is, `gn` while holding
an item of the highest tier will give you the item of the lowest tier.


### relatedItemTierDown - `gp`

Dual to `relatedItemTierUp`.


# jumplist.lua

Vim-like jumplist and marks that can be teleported to.


Arguably this is cheaty, but non-arguably it is also very useful. For a less cheaty option, `autowalk.lua` has a function that will walk your character to a location instead.


#### Create a mark - `m<ANYTHING>`

Register the players current position to whatever key was pressed in place of `<ANYTHING>`


#### Jump (teleport) to a mark - `'<ANYTHING>`

Teleport the player to the location associated with the given key. It pushes the players old/new location onto the jumplist.


#### The jump list

The jumplist is a `WindowZipper` with the additional requirement that adjacent elements must be distinct, and our definition of distinct is "at least 5 tiles apart". This keeps it from clogging up due to overuse.


`<c-o>` - Move the focus left, then jump to the location with focus.

`<c-i>` - Move the focus right, then jump to the location with focus.

`gi` - Like `''` in vim:

If the player is at the focused location, promote it to the second position from the right (end). Otherwise, push. Finally, move the focus to the rightmost location and jump.

Basically, this will take you to the location that you most recently jumped to, and the position from which you came will be directly below you (`<c-o>`) in the jumplist.


# warp.lua

Emulates `w` and `e` from Vim.


#### WarpWord - `W`


Move the player forward in the direction they are facing until just before the very first solid object in the trajectory. If this was already the case to begin with (IE: they were standing there facing a wall), move them past and to before the second object instead.

```
@ = Player
# = Solid

Each line represent one `W` press

@  ###    # #   ##
  @###    # #   ##
   ###   @# #   ##
   ###    #@#   ##
   ###    # #  @##
```


#### WarpEnd - `E`

Move the player forward in the direction they are facing until just past the very first solid object in the trajectory.

```
@ = Player
# = Solid

Each line represent one `E` press

@  ###    # #   ##
   ###@   # #   ##
   ###    #@#   ##
   ###    # #@  ##
   ###    # #   ##@
```


#### WarpShort - `w`

Move the player exactly 20 tiles forward in the direction
they are facing. If this would move them inside a solid object, continue moving them forward until this is no longer the case.


In Vim terms this would be approximately `20le`- It is a conveniently short jump that doesn't trap you inside a rock
