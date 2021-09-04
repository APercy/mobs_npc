
-- Load support for intllib.
local path = minetest.get_modpath(minetest.get_current_modname()) .. "/"

local S = minetest.get_translator and minetest.get_translator("mobs_npc") or
		dofile(path .. "intllib.lua")

mobs.intllib = S


-- Check for custom mob spawn file
local input = io.open(path .. "spawn.lua", "r")

if input then
	mobs.custom_spawn_npc = true
	input:close()
	input = nil
end


-- NPCs
dofile(path .. "npc.lua") -- TenPlus1
dofile(path .. "trader.lua")
dofile(path .. "igor.lua")
dofile(path .. "quest_npc.lua")


-- Load custom spawning
if mobs.custom_spawn_npc then
	dofile(path .. "spawn.lua")
end


-- Lucky Blocks
dofile(path .. "/lucky_block.lua")

-- checkpoint logo
minetest.register_node("mobs_npc:bad_igor_spawn", {
	description = "Monster Spawn",
	tiles = {"default_stone.png"},
	wield_image = "spawn_logo.png",
	inventory_image = "spawn_logo.png",
	sounds = default.node_sound_stone_defaults(),
	groups = {dig_immediate = 2, unbreakable = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	light_source = 4,
	drawtype = "nodebox",
	sunlight_propagates = true,
	walkable = true,
	node_box = {
		type = "wallmounted",
		wall_top    = {-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
		wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		wall_side   = {-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5},
	},
	selection_box = {type = "wallmounted"},

	after_place_node = function(pos, placer)

        local meta = minetest.get_meta(pos)
		--meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Monster Spawn")
	end
})


print (S("[MOD] Mobs Redo NPCs loaded"))
