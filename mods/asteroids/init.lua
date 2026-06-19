
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


--- Creates a rate of rotation.
--
--  @return
--    Vector defining random rotation rate & direction for each axis.
local next_rot_rate = function()
	-- rotation direction for each axis (0 = no rotation, 1 = clockwise, -1 = counter-clockwise)
	local rot_dir_x = rand:next(-1, 1)
	local rot_dir_y = rand:next(-1, 1)
	local rot_dir_z = rand:next(-1, 1)

	return {
		x = rand_thousandth(0.001, 0.01) * rot_dir_x,
		y = rand_thousandth(0.001, 0.01) * rot_dir_y,
		z = rand_thousandth(0.001, 0.01) * rot_dir_z
	}
end


--- Rotates an asteroid according to its rotation rate vector.
--
--  @param ref
--    Asteroid `ObjectRef` to be rotated.
local rotate_step = function(ref)
	-- object's current rotation
	local rot = ref.object:get_rotation()
	for k, v in pairs(ref.rot_rate) do
		-- update axis rotation from rotation rate vector
		rot[k] = rot[k] + v
	end
	-- apply new rotation to asteroid
	ref.object:set_rotation(rot)
end


-- node radius of gameplay boundaries
local gameplay_radius = 50

-- maxium age of asteroids in minutes
local age_limit_minutes = 5


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


		--- Calculates asteroid decimal age with milliseconds precision.
		--
		--  @return
		--    Asteroids age since added to game.
		get_age = function(self)
			if self.origin == nil or self.origin.ms == nil then
				return 0
			end
			return (get_time_ms() - self.origin.ms) / 1000
		end,


		on_step = function(self, dtime, moveresult)
			if self.origin == nil then
				self.origin = {
					ms = get_time_ms(),
					pos = self.object:get_pos()
				}

				-- speed at which asteroid is travelling
				local speed = rand:next(1, 5) / 10
				-- direction toward which asteroid is travelling
				local yaw = rand:next(0, 359) * (math.pi / 180)
				local pitch = rand:next(0, 359) * (math.pi / 180)
				-- apply speed & direction to asteroid
				self.object:set_velocity({
					x = speed * math.cos(pitch) * math.sin(yaw),
					y = speed * math.sin(pitch),
					z = speed * math.cos(pitch) * math.cos(yaw)
				})

				-- initial rotation angle
				self.object:set_rotation({
					x = rand:next(0, 359) * (math.pi / 180),
					y = rand:next(0, 359) * (math.pi / 180),
					z = rand:next(0, 359) * (math.pi / 180)
				})

				-- random rate at which asteroid will rotate
				self.rot_rate = next_rot_rate()
			end

			-- distance asteroid has traveled from its origin
			local distance_from_origin = math.floor(get_distance(self.object:get_pos(), self.origin.pos))
			-- remove from game if moved past boundaries of gameplay
			if distance_from_origin > gameplay_radius then
				self.object:remove()
				return
			end

			-- remove from game if age limit reached
			if math.floor(self:get_age() / 60) >= age_limit_minutes then
				self.object:remove()
				return
			end

			-- update asteroid's angle of rotation
			rotate_step(self)
		end
	})
end

for _, a_type in pairs({"rock", "ice", "molten"}) do
	for _, a_size in pairs({"small", "medium", "large"}) do
		register_asteroid(a_type, a_size)
	end
end
