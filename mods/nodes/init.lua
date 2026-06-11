
dofile(core.get_modpath(core.get_current_modname()).."/mapgen.lua")


core.register_node(":nodes:rock", {
	description = "Asteroid Rock",
	tiles = {"nodes_rock.png"},
	diggable = false
})

core.register_node(":nodes:ice", {
	description = "Asteroid Ice",
	tiles = {"nodes_ice.png"},
	diggable = false
})
