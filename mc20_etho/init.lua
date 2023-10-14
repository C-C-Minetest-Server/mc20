-- mc20/mc20_etho/init.lua
-- Add Etho Slabs
--[[
    Copyright (C) 2023  1F616EMO

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local S = minetest.get_translator("mc20_etho")

mc20_etho = {}

---@param pos Vector
---@param entname string
---@return ObjectRef?
local function spawn_tnt(pos, entname)
	minetest.sound_play("tnt_ignite", { pos = pos, gain = 1.0, max_hear_distance = 15 }, true)
	local ent = minetest.add_entity(pos, entname)
	if ent then
		ent:set_armor_groups({ immortal = 1 })
	end
	return ent
end


function mc20_etho.spawn_anvil(pos, radius)
    local entities = minetest.get_objects_inside_radius(pos, radius)
    local _, pos_dim = mcl_worlds.pos_to_dimension(pos)
    for _, obj in ipairs(entities) do
        if math.random(1,4) == 1 then -- 25%
            local armor = obj:get_armor_groups()
            if armor.fleshy and armor.fleshy > 0 then
                local obj_pos = obj:get_pos()
                local anvil_pos = vector.add(obj_pos, {x= 0, y = 2, z = 0})

                local _, obj_pos_dim   = mcl_worlds.pos_to_dimension(obj_pos)
                local _, anvil_pos_dim = mcl_worlds.pos_to_dimension(anvil_pos)

                local anvil_pos_node = mcl_vars.get_node(anvil_pos)
                local anvil_pos_node_def = minetest.registered_nodes[anvil_pos_node.name]
                if anvil_pos_node_def and anvil_pos_node_def.buildable_to then
                    if pos_dim == obj_pos_dim and obj_pos_dim == anvil_pos_dim then
                        -- Spawns an anvil
                        minetest.set_node(anvil_pos, {name = "mcl_anvils:anvil", param2 = math.random(0,3)})
                        minetest.spawn_falling_node(anvil_pos)
                    end
                end
            end
        end
    end
end

function mc20_etho.ignite(pos)
    local node = minetest.get_node(pos)
    local entity_name
    if node.name == "mcl_stairs:slab_tnt_etho" then
        entity_name = "mc20_etho:etho_lower"
    elseif node.name == "mcl_stairs:slab_tnt_etho_top" then
        entity_name = "mc20_etho:etho_upper"
    elseif node.name == "mcl_stairs:slab_tnt_etho_double" then
        entity_name = "mc20_etho:etho_double"
    end
    if entity_name then
        minetest.remove_node(pos)
        local e = spawn_tnt(pos, entity_name)
        minetest.check_for_falling(pos)
        return e
    end
end

local tiles = {
    "default_tnt_top.png",
    "default_tnt_bottom.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
}

mcl_stairs.register_slab(
    "tnt_etho", -- subname
    "mcl_tnt:tnt", -- recipeitem
    { dig_immediate = 3, tnt = 1, enderman_takable = 1, flammable = -1 }, -- groups
    tiles, -- images
    S("Etho Slab"), -- description
    minetest.get_modpath("mcl_sounds") and mcl_sounds.node_sound_wood_defaults(), -- sounds
    nil, -- blast_resistance
    nil, -- hardness
    nil  -- double_description
)

local etho_lower_entity = {
	-- Static definition
	physical = true, -- Collides with things
	collisionbox = {-0.5, -0.25, -0.5, 0.5, 0, 0.5},
    visual_size = {x = 1, y = 0.5, z = 1},
	visual = "cube",
	textures = {
		"default_tnt_top.png",
		"default_tnt_bottom.png",
		"mc20_etho_lower.png",
		"mc20_etho_lower.png",
		"mc20_etho_lower.png",
		"mc20_etho_lower.png",
	},
	-- Initial value for our timer
	timer = 0,
	blinktimer = 0,
	tnt_knockback = true,
	blinkstatus = true,
    on_activate = function(self)
        local phi = math.random(0, 65535) / 65535 * 2 * math.pi
        local hdir_x = math.cos(phi) * 0.02
        local hdir_z = math.sin(phi) * 0.02
        self.object:set_velocity(vector.new(hdir_x, 2, hdir_z))
        self.object:set_acceleration(vector.new(0, -10, 0))
        self.object:set_texture_mod("^mcl_tnt_blink.png")
    end,
    on_step = function(self, dtime, _)
        local pos = self.object:get_pos()
        tnt.smoke_step(pos)
        self.timer = self.timer + dtime
        self.blinktimer = self.blinktimer + dtime
        if self.blinktimer > tnt.BLINKTIMER then
            self.blinktimer = self.blinktimer - tnt.BLINKTIMER
            if self.blinkstatus then
                self.object:set_texture_mod("")
            else
                self.object:set_texture_mod("^mcl_tnt_blink.png")
            end
            self.blinkstatus = not self.blinkstatus
        end
        if self.timer > tnt.BOOMTIMER then
            local epos = self.object:get_pos()
            mcl_explosions.explode(epos, 4, {}, self.object)
            mc20_etho.spawn_anvil(epos, 20)
            self.object:remove()
        end
    end
}
minetest.register_entity("mc20_etho:etho_lower", etho_lower_entity)

local etho_upper_entity = table.copy(etho_lower_entity)
etho_upper_entity.textures = {
    "default_tnt_top.png",
    "default_tnt_bottom.png",
    "mc20_etho_upper.png",
    "mc20_etho_upper.png",
    "mc20_etho_upper.png",
    "mc20_etho_upper.png",
}
minetest.register_entity("mc20_etho:etho_upper", etho_upper_entity)

local etho_double_entity = table.copy(etho_lower_entity)
etho_double_entity.collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
etho_double_entity.visual_size = nil
etho_double_entity.textures = {
    "default_tnt_top.png",
    "default_tnt_bottom.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
    "default_tnt_side.png",
}
minetest.register_entity("mc20_etho:etho_double", etho_double_entity)

local prefix = "mcl_stairs:slab_tnt_etho"
for _, name in ipairs({"","_top","_double"}) do
    minetest.override_item(prefix .. name, {
        on_blast = function(pos, _)
            local e = mc20_etho.ignite(pos)
            if e then
                e:get_luaentity().timer = tnt.BOOMTIMER - (0.5 + math.random())
            end
        end,
        _on_ignite = function(_, pointed_thing)
            mc20_etho.ignite(pointed_thing.under)
            return true
        end,
        _on_burn = function(pos)
            mc20_etho.ignite(pos)
            return true
        end,
        _on_dispense = function(stack, _, droppos, dropnode, _)
            -- Place and ignite TNT
            if minetest.registered_nodes[dropnode.name].buildable_to then
                minetest.set_node(droppos, { name = stack:get_name() })
                mc20_etho.ignite(droppos)
            end
        end,
        mesecons = minetest.get_modpath("mesecons") and {
            effector = {
                action_on = mc20_etho.ignite,
                rules = mesecon.rules.alldirs,
            },
        }
    })
end
