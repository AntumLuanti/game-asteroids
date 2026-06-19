

-- empty "space" node
local vacuum = {
	description = "empty space",
	drawtype = "airlike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true
}

-- empty "space" node with particle visual
local vacuum_particle = {
	description = "empty space particle",
	drawtype = "allfaces",
	visual_scale = 0.005,
	tiles = {
		"asteroids_vacuum_particle.png", "asteroids_vacuum_particle.png", "asteroids_vacuum_particle.png",
		"asteroids_vacuum_particle.png", "asteroids_vacuum_particle.png", "asteroids_vacuum_particle.png"
	},
	use_texture_alpha = "blend",
}
for k, v in pairs(vacuum) do
	if vacuum_particle[k] == nil then
		vacuum_particle[k] = v
	end
end


core.register_node(":vacuum", vacuum)
core.register_node(":vacuum_particle", vacuum_particle)
