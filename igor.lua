
local S = mobs.intllib

-- Igor by TenPlus1

mobs.igor_drops = {
	"vessels:glass_bottle", "mobs:meat_raw", {"default:sword_steel", 2},
	"farming:bread", {"bucket:bucket_water", 2}, "flowers:mushroom_red",
	"default:jungletree", {"fire:flint_and_steel", 3}, "mobs:leather",
	"default:acacia_sapling", {"fireflies:bug_net", 3}, "default:clay_lump",
	"default:ice", "default:coral_brown", "default:iron_lump",
	"default:obsidian_shard", "default:mossycobble", {"default:obsidian", 2}
}

mobs:register_mob("mobs_npc:igor", {
	type = "monster",
	passive = false,
	damage = 5,
	attack_type = "dogfight",
	owner_loyal = true,
	pathfinding = true,
	reach = 2,
	attacks_monsters = true,
    group_attack = true,
	hp_min = 30,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mobs_igor.png"}, -- skin by ruby32199
		{"mobs_igor2.png"},
		{"mobs_igor3.png"},
		{"mobs_igor4.png"},
		{"mobs_igor5.png"},
		{"mobs_igor6.png"},
		{"mobs_igor7.png"},
		{"mobs_igor8.png"}
	},
	makes_footstep_sound = true,
	sounds = {},
	walk_velocity = 1,
	run_velocity = 2,
	stepheight = 1.1,
	fear_height = 2,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 2},
		{name = "default:gold_lump", chance = 3, min = 1, max = 1}
	},
	water_damage = 1,
	lava_damage = 3,
	light_damage = 0,
	follow = {"mobs:meat_raw", "default:diamond"},
	view_range = 15,
	owner = "",
	order = "wander",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219
	},

	-- right clicking with raw meat will give Igor more health
	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.npc_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()
			local drops = self.igor_drops or mobs.igor_drops
			local drop = drops[math.random(#drops)]
			local chance = 1

			if type(drop) == "table" then
				chance = drop[2]
				drop = drop[1]
			end

			if not minetest.registered_items[drop]
			or math.random(chance) > 1 then
				drop = "default:coal_lump"
			end

			local obj = minetest.add_item(pos, {name = drop})
			local dir = clicker:get_look_dir()

			obj:set_velocity({x = -dir.x, y = 1.5, z = -dir.z})

			--minetest.chat_send_player(name, S("NPC dropped you an item for gold!"))

			return
		end

		-- by right-clicking owner can switch npc between follow, wander and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.order = "wander"

				minetest.chat_send_player(name, S("NPC will wander."))

			elseif self.order == "wander" then

				self.order = "stand"
				self.state = "stand"
				self.attack = nil

				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, S("NPC stands still."))

			elseif self.order == "stand" then

				self.order = "follow"

				minetest.chat_send_player(name, S("NPC will follow you."))
			end
		end
	end,

	-- check surrounding nodes and spawn a specific monster
	on_spawn = function(self)

		local pos = self.object:get_pos() ; pos.y = pos.y + 0.5

		return true -- run only once, false/nil runs every activation
	end
})

if not mobs.custom_spawn_igor then
mobs:spawn({
	name = "mobs_npc:igor",
	nodes = {"mobs_npc:bad_igor_spawn"},
	min_light = 0,
	max_light = 15,
	interval = 2,
	chance = 2,
	active_object_count = 3,
	min_height = 0,
	day_toggle = false,
})
end

mobs:register_egg("mobs_npc:igor", S("Igor"), "mobs_meat_raw.png", 1)

-- compatibility
mobs:alias_mob("mobs:igor", "mobs_npc:igor")
