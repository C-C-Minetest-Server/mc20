-- mc20/mc20_coal_block/init.lua
-- Coal Block modifications
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

local S = minetest.get_translator("mc20_coal_block")

-- Retexture to darkened redstone block
-- Change description to remove "as fuel" wordings
minetest.override_item("mcl_core:coalblock", {
    tiles = {"mc20_coal_block_block.png"},
    _doc_items_longdesc = S("Blocks of coal are useful as a compact storage of coal. " ..
        "However, the crafted back coal can no longer be stacked with other coal."),
})

-- Coal Blocks can no longer be fuel
minetest.clear_craft({
	type = "fuel",
	recipe = "mcl_core:coalblock",
	burntime = 800,
})

-- Do not return normal coal on craft
minetest.clear_craft({
	output = "mcl_core:coal_lump 9",
	recipe = {
		{"mcl_core:coalblock"},
	}
})

-- Return coal that are non-stackable with other coal
-- While keeping the ability to craft
do
    local special_coal = ItemStack("mcl_core:coal_lump")
    special_coal:get_meta():set_int("mc20_special",1)
    special_coal:set_count(9)
    minetest.register_craft({
        output = special_coal:to_string(),
        recipe = {
            {"mcl_core:coalblock"},
        }
    })
end