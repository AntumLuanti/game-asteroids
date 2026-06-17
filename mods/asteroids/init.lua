
local register_asteroid = function(a_type, a_size)
	local hp = 0
	local size = 0
	if a_size == "small" then
		hp = 1
		size = 1
	elseif a_size == "medium" then
		hp = 3
		size = 2
	elseif a_size == "large" then
		hp = 5
		size = 3
	else
		core.log("error", "unknown asteroid size: "..a_size)
		return
	end

	local collision_offset = size / 2

	local name = "asteroids:"..a_type.."_"..a_size
	core.register_entity(":"..name, {
		initial_properties = {
			static_save = false,
			visual = "cube",
			visual_size = {x=size, y=size, z=size},
			textures = {"asteroids_"..a_type..".png"},
			physical = true,
			collide_with_objects = true,
			collisionbox = {
				-collision_offset, -collision_offset, -collision_offset,
				collision_offset, collision_offset, collision_offset
			},
			hp_max = hp,
			is_visible = true,
		},
	})
end

for _, a_type in pairs({"rock", "ice"}) do
	for _, a_size in pairs({"small", "medium", "large"}) do
		register_asteroid(a_type, a_size)
	end
end
