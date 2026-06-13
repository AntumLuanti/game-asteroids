

-- empty "space" node
core.register_node(":space", {
	description = "empty space",
	drawtype = "airlike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	climbable = true,
	buildable_to = true,
	floodable = true
})

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
