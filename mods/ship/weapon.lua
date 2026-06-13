
core.register_entity("asteroids_ship:projectile", {
	physical = true,
	collide_with_objects = true,
	pointable = false,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5, z=0.5},
	textures = {"asteroids_ship_projectile.png"},
	static_save = false
})
