

-- empty "space" node
core.register_node(":vacuum", {
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
