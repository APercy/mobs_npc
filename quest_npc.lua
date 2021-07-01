
local S = mobs.intllib

-- Quest Npc by TenPlus1 and APercy

--[[
EXAMPLE:

{["greetings"]='Welcome! Can I see your glass?',["default:glass"]={["text"]='Great! Good forged glass',["open"]={["x"]='0',["y"]=0,["z"]=0,["time"]=10},},}


the "open" instruction:
["mod:item"]={["text"]="text",["open"]={["x"]='0',["y"]=0,["z"]=0,["time"]=10}}

the "take" instruction
["mod:item"]={["text"]="text",["take"]=1}

the "give" instruction
["mod:item"]={["text"]="text",["give"]="mod:item2"}


]]--

local _contexts = {}
local function get_context(name)
    local context = _contexts[name] or {}
    _contexts[name] = context
    return context
end

minetest.register_on_leaveplayer(function(player)
    _contexts[player:get_player_name()] = nil
end)

mobs_npc_textures = {
	{"mobs_npc.png"},
	{"mobs_npc2.png"}, -- female by nuttmeg20
	{"mobs_npc3.png"}, -- male by swagman181818
	{"mobs_npc4.png"}, -- female by Sapphire16
	{"mobs_igor.png"}, -- skin by ruby32199
	{"mobs_igor4.png"},
	{"mobs_igor6.png"},
	{"mobs_igor7.png"},
	{"mobs_igor8.png"},
    {"mobs_npc_ghost.png"},  -- skin by daniel pereira
    {"mobs_npc_ghost2.png"}, -- skin by daniel pereira
    {"mobs_npc_chloe.png"},  -- nelly
    {"mobs_npc_julia.png"},  -- nelly
    {"mobs_npc_cloe.png"},      -- Sporax
    {"mobs_npc_charlotte.png"}, -- Sporax
    {"mobs_npc_elf.png"},       --loupicate
    {"mobs_npc_police.png"},    --maruyuki
    {"mobs_npc_lotte.png"},     -- skindex
    {"mobs_npc_gregory.png"},   --gregoryherrera
    {"mobs_npc_gregory2.png"},  --gregoryherrera
    {"mobs_npc_queen.png"},     -- Extex
    {"mobs_npc_king.png"},      -- Extex
    {"mobs_npc_wizard.png"},    -- Extex
    {"mobs_npc_cool_dude.png"}, -- TMSB aka Dragoni or Dragon-ManioNM
    {"mobs_npc_mumbo.png"},     -- Miniontoby
    {"mobs_npc_queen2.png"},
    {"mobs_npc_banshee.png"},   -- nelly
    {"mobs_npc_banshee2.png"},  -- TenPlus1
    {"mobs_npc_farmer.png"},    -- sdzen
    {"mobs_npc_farmer2.png"},   -- sdzen
    {"mobs_npc_killer.png"}     -- Phill
}


local function open_door(pos, time)
    local absolute_pos = pos
    --absolute_pos.y = absolute_pos.y + 0.5
    local meta = minetest.get_meta(absolute_pos);

    local node_name = minetest.get_node(absolute_pos).name
    
    if string.find(node_name, "doors:") then
        minetest.after(2, function() 
            doors.door_toggle(absolute_pos, nil, nil)
            minetest.after(time, function() 
                doors.door_toggle(absolute_pos, nil, nil)
            end ) 
        end ) 
    end
end

local function take_item(item_name, player)
    local itmstck=player:get_wielded_item()
    if itmstck then
        local curr_item_name = itmstck:get_name()
        if curr_item_name == item_name then
            --minetest.chat_send_player(player:get_player_name(), curr_item_name)
            itmstck:set_count(itmstck:get_count()-1)
            player:set_wielded_item(itmstck)
        end
    end
end

--TODO
local function getItemSpecs(itemName)
    local items = ItemStack(itemName)
    local meta = items:get_meta()
    local description = ""
    if items.get_short_description then
        description = items:get_short_description()
    else
        description = items:get_description()
    end
    local definitions = items:get_definition()
    local retIcon = definitions.inventory_image
    if retIcon == nil or retIcon == "" then
        if definitions.tiles ~= nil then
            retIcon = definitions.tiles[1]
        end
    end
    local retText = "You earned the " .. description
    return retText, retIcon
end

local function give_item(item_name, player)
    local item = player:get_inventory():add_item("main", item_name .. " " .. 1)
    if item then
        minetest.add_item(player:getpos(), item)
    end
    local context = get_context(player:get_player_name())
    context.text, context.icon = getItemSpecs(item_name)
end

local function execute_script(self, player, item)
    local name = player:get_player_name()
    local text = "Hi!"
    if self.quests then
        local item_name = item:get_name()
        local content = self.quests[item_name] or ""
        if content == nil or content == "" then
            --only the text
            text = self.quests["greetings"] or "Hi!" --default Hi
        else
            text = content["text"] or "..." --if no text, try to simulate a silence action
            local open = content["open"] or nil
            if open then
                if open.x ~= nil and open.y ~= nil and open.z ~= nil then
                    local absolute_pos = {x=open.x, y=open.y, z=open.z}
                    open_door(absolute_pos, open.time or 10) --open doors
                end
            end

            local take = content["take"] or nil
            if take == 1 then
                --take the item
                take_item(item_name, player)
            end

            local give = content["give"] or nil
            if give then
                --take the item
                give_item(give, player)
            end
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

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mobs_npc:dialog_balloon" then
        local context = get_context(player:get_player_name())
		if fields.quit and context.text ~= nil then
            local text = context.text
            local icon = context.icon
	        local balloon = table.concat({
		        "formspec_version[3]",
		        "size[8,5]",
		        "background[-0.7,-0.5;9.5,6.5;mobs_balloon_2.png]",
                "textarea[1,0.75;6.5,2;;;",text,"]",
				"image[3,3;2,2;",icon,"]",
	        }, "")
            context.text = nil
            context.icon = nil

            minetest.after(1, function() 
                minetest.show_formspec(player:get_player_name(), "mobs_npc:received", balloon)
            end )
		end
    end
end)

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
	textures = mobs_npc_textures,
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

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- by right-clicking owner can switch npc between follow, wander and stand
		if self.owner and self.owner == name then
		    -- feed to heal npc
		    if mobs:feed_tame(self, clicker, 8, true, true) then return end

            if item:get_name() == "default:book_written" then
                local data = item:get_meta():to_table().fields
                --minetest.chat_send_player(name, dump(data.text))
                self.npc_role = data.title or "Helper"
                self.nametag = self.npc_role
		        self.object:set_properties({
			        nametag = self.nametag,
			        nametag_color = "#FFFFFF"
		        })
                self.quests = minetest.deserialize("return "..data.text) or {}
                minetest.chat_send_player(name, S(self.quests["greetings"] or "Hi!"))
            else
                if item:get_name() == "dye:red" then
                    local texture = mobs_npc_textures[math.random(#mobs_npc_textures)]
                    self.base_texture = texture
                    self.textures = texture
                    --minetest.chat_send_player(name, dump(texture))
                    self.object:set_properties(self)
                    return
                end
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
                    execute_script(self, clicker, item)
                end
            end
        else
            execute_script(self, clicker, item)
		end
	end,

	on_spawn = function(self)

		self.nametag = S("Helper")

        if self.npc_role then self.nametag = self.npc_role end
		self.object:set_properties({
			nametag = self.nametag,
			nametag_color = "#FFFFFF"
		})

		return true -- return true so on_spawn is run once only
	end
})

mobs:register_egg("mobs_npc:quest_npc", S("Quest Npc"), "default_brick.png", 1)

-- compatibility
mobs:alias_mob("mobs:npc", "mobs_npc:npc")
