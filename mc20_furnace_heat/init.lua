-- mc20/mc20_furnace_heat/init.lua
-- Overheated furnaces
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

-- Increase Heat and Explode
minetest.register_abm({
    label = "mc20_furnace_heat:increase_heat",
    nodenames = {"mcl_furnaces:furnace_active"},
    interval = 0.1, -- Well, half than original, but enough
    chance = 1,
    action = function(pos)
        local meta = minetest.get_meta(pos)
        local curr_heat = meta:get_int("mc20_heat")
        -- Explode when curr_heat = 400 (it should not go any higher than 400, but just in case, >= is used)
        if curr_heat >= 400 then -- Decreased maximum to suit Minetest's slower globalstep
            -- Explosion probability logic
            if math.random() < 0.25 then
                -- 25% of chance to explode
                mcl_explosions.explode(pos, 5, {
                    fire = true,
                }, nil)
                -- If the node is somehow still there, clear Heat
                if minetest.get_node(pos).name == "mcl_furnaces:furnace_active" then
                    meta:set_int("mc20_heat", 0)
                end
            end
        else
            -- Heat increase logic
            if math.random() < 0.5 then
                -- 50% chance
                curr_heat = curr_heat + math.random(1,10)
                curr_heat = math.min(curr_heat, 400)
                meta:set_int("mc20_heat", curr_heat)
            end
        end
    end
})

-- Decrease heat
minetest.register_abm({
    label = "mc20_furnace_heat:decrease_heat",
    nodenames = {"mcl_furnaces:furnace"},
    interval = 0.1, -- Well, half than original, but enough
    chance = 1,
    action = function(pos)
        local meta = minetest.get_meta(pos)
        local curr_heat = meta:get_int("mc20_heat")
        if math.random() < 0.25 then
            -- 25% of chance
            curr_heat = curr_heat - math.random(1, 10)
            curr_heat = math.max(curr_heat, 0)
            meta:set_int("mc20_heat", curr_heat)
        end
    end
})

-- Smoke
minetest.register_abm({
    label = "mc20_furnace_heat:smoke",
    nodenames = {"mcl_furnaces:furnace", "mcl_furnaces:furnace_active"},
    interval = 0.1, -- Well, half than original, but enough
    chance = 1,
    action = function(pos)
        local meta = minetest.get_meta(pos)
        local curr_heat = meta:get_int("mc20_heat")

        -- Large particle logic
        if curr_heat > 0 and math.random() < (curr_heat/400) then
            minetest.add_particlespawner({
                amount = 40,
                time = 0.125,
                minpos = pos,
                maxpos = pos,
                minvel = vector.new(-1, -1, -1),
                maxvel = vector.new(1, 1, 1),
                minacc = vector.zero(),
                maxacc = vector.zero(),
                minexptime = 0.5,
                maxexptime = 1.0,
                minsize = 5,
                maxsize = 10,
                texture = "mcl_particles_smoke.png",
            })
        end
    end
})