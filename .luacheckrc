---@diagnostic disable: lowercase-global

globals = {
        "vector",
        math = {
                fields = {
                        "round",
                        "hypot",
                        "sign",
                        "factorial",
                        "ceil",
                }
        },

        "minetest", "core",

        "mc20_etho", "mcl_sounds", "mcl_stairs", "tnt", "mcl_explosions", "mcl_worlds",
        "mcl_vars", "mesecon", "mc20_furnace_heat"
}

read_globals = {
        "DIR_DELIM",
        "dump", "dump2",
        "VoxelManip", "VoxelArea",
        "PseudoRandom", "PcgRandom",
        "ItemStack",
        "Settings",
        "unpack",
        "loadstring",

        table = {
                fields = {
                        "copy",
                        "indexof",
                        "insert_all",
                        "key_value_swap",
                        "shuffle",
                        "random",
                }
        },

        string = {
                fields = {
                        "split",
                        "trim",
                }
        },
}