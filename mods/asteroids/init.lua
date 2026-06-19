
local rand = PcgRandom(core.get_us_time())


--- Retrieves random decimal value within range with thousandths precision.
--
--  @param vmin
--    The range minimum value that can be returned.
--  @param vmax
--    The range maximum value that can be returned.
local rand_thousandth = function(vmin, vmax)
	return rand:next(vmin*1000, vmax*1000) / 1000
end


--- Retrieves system time.
--
--  @return
--    System time in milliseconds.
local get_time_ms = function()
	return math.floor(core.get_us_time() / 1000)
end


--- Calculates distance between two positional vectors.
--
--  @param A
--    Vector of first point.
--  @param B
--    Vector of second point.
local get_distance = function(A, B)
	local dx = A.x - B.x
	dx = dx * dx
	local dy = A.y - B.y
	dy = dy * dy
	local dz = A.z - B.z
	dz = dz * dz

	return math.abs(math.sqrt(dx + dy + dz))
end


--- Registers an asteroid.
--
--  @param a_type
--    Asteroid type (should be one of "rock", "ice", or "molten" to match textures).
--  @param a_size
--    Asteroid size (must be one of "small", "medium", or "large").
local register_asteroid = function(a_type, a_size)
	local hp = 0
	local size = 0
	if a_size == "small" then
		hp = 3
		size = 0.5
	elseif a_size == "medium" then
		hp = 5
		size = 1
	elseif a_size == "large" then
		hp = 10
		size = 2
	else
		core.log("error", "unknown asteroid size: "..a_size)
		return
	end

	local collision_offset = size / 2
	local t = "asteroids_"..a_type..".png"

	local name = "asteroids:"..a_type.."_"..a_size
	core.register_entity(":"..name, {
		initial_properties = {
			static_save = false,
			visual = "cube",
			visual_size = {x=size, y=size, z=size},
			textures = {
				t, t,
				t, t,
				t, t,
			},
			physical = true,
			collide_with_objects = true,
			collisionbox = {
				-collision_offset, -collision_offset, -collision_offset,
				collision_offset, collision_offset, collision_offset
			},
			hp_max = hp,
			is_visible = true,
		},

		on_step = function(self, dtime, moveresult)
			if not self._speed then
				self._speed = rand:next(1, 5) / 10
				local yaw = rand:next(0, 359) * (math.pi / 180)
				local pitch = rand:next(0, 359) * (math.pi / 180)
				self.object:set_velocity({
					x = self._speed * math.cos(pitch) * math.sin(yaw),
					y = self._speed * math.sin(pitch),
					z = self._speed * math.cos(pitch) * math.cos(yaw)
				})
			end
		end
	})
end

for _, a_type in pairs({"rock", "ice", "molten"}) do
	for _, a_size in pairs({"small", "medium", "large"}) do
		register_asteroid(a_type, a_size)
	end
end
