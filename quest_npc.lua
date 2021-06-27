
local S = mobs.intllib

-- Quest Npc by TenPlus1 and APercy

local function talk(self, name, item)
    local text = "Hi!"
    if self.quests then
        text = self.quests[item:get_name()] or ""
        if text == nil or text == "" then
            text = self.quests["greetings"] or "Hi!"
        end
    end
    --minetest.chat_send_player(name, core.colorize('#5555ff', text))
    local balloon = ""
    if string.len(text) > 320 then
	    balloon = table.concat({
		    "formspec_version[3]",
		    "size[16,10]",
		    "background[-0.7,-0.5;17.5,11.5;mobs_balloon.png]",
            "textarea[1,1;14,8;;;",text,"]",
	    }, "")
    else
	    balloon = table.concat({
		    "formspec_version[3]",
		    "size[8,5]",
		    "background[-0.7,-0.5;9.5,6.5;mobs_balloon_2.png]",
            "textarea[1,0.75;6.5,4;;;",text,"]",
	    }, "")
    end
    minetest.show_formspec(name, "mobs_npc:dialog_balloon", balloon)
end

mobs:register_mob("mobs_npc:quest_npc", {
	type = "npc",
	passive = false,
	damage = 90000,
	attack_type = "dogfight",
	attacks_monsters = false,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 90000,
	hp_max = 90000,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	drawtype = "front",
	textures = {
		{"mobs_npc.png"},
		{"mobs_npc2.png"}, -- female by nuttmeg20
		{"mobs_npc3.png"}, -- male by swagman181818
		{"mobs_npc4.png"}, -- female by Sapphire16
		{"mobs_igor.png"}, -- skin by ruby32199
		{"mobs_igor4.png"},
		{"mobs_igor6.png"},
		{"mobs_igor7.png"},
		{"mobs_igor8.png"}
	},
	makes_footstep_sound = true,
	sounds = {},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:wood", chance = 1, min = 1, max = 3},
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:axe_stone", chance = 5, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	view_range = 15,
	owner = "",
	order = "stand",
	fear_height = 3,
    quest_text = "",
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

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- by right-clicking owner can switch npc between follow, wander and stand
		if self.owner and self.owner == name then
            if item:get_name() == "default:book_written" then
                local data = item:get_meta():to_table().fields
                --minetest.chat_send_player(name, dump(data.text))
                self.quests = minetest.deserialize("return "..data.text) or {}
                minetest.chat_send_player(name, S(self.quests["greetings"] or "Hi!"))
            else
                if item:get_name() == "dye:white" then
                    self.object:remove()
                    return
                end
                if item:get_name() == "dye:black" then
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
                else
                    talk(self, name, item)
                end
            end
        else
            talk(self, name, item)
		end
	end
})

mobs:register_egg("mobs_npc:quest_npc", S("Quest Npc"), "default_brick.png", 1)

-- compatibility
mobs:alias_mob("mobs:npc", "mobs_npc:npc")
