
-- Load support for intllib.
local path = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator and minetest.get_translator("mobs_npc") or
		dofile(path .. "/intllib.lua")
mobs.intllib = S

-- NPCs
dofile(path .. "/npc.lua") -- TenPlus1
dofile(path .. "/trader.lua")
dofile(path .. "/igor.lua")

-- Lucky Blocks
dofile(path .. "/lucky_block.lua")

print (S("[MOD] Mobs Redo NPCs loaded"))
