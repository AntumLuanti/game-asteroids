
-- determines if rules resembling classic gameplay should be used
local classic_gameplay = core.settings:get_bool("asteroids.classic", true)

--- Retrieves classic gameplay state.
--
--  @return
--    `true` if classic gameplay rules are in effect.
asteroids.is_classic_gameplay = function()
	return classic_gameplay
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
	local point_value = 1
	if a_size == "small" then
		hp = classic_gameplay and 1 or 3
		size = 0.5
		point_value = classic_gameplay and 100 or 20
	elseif a_size == "medium" then
		hp = classic_gameplay and 1 or 5
		size = 1
		point_value = 50
	elseif a_size == "large" then
		hp = classic_gameplay and 1 or 10
		size = 2
		point_value = classic_gameplay and 20 or 100
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
			show_on_minimap = true
		},


		--- Retrieves point value of this asteroid.
		--
		--  @return
		--    Points to be awarded to player when destroyed.
		get_point_value = function(self)
			return point_value
		end,


		--- Retrieves name registered to this asteroid.
		--
		--  @return
		--    Asteroid name.
		get_name = function(self)
			return name
		end,


		--- Retrieves asteroid type info from name.
		get_type = function(self)
			local a_name = string.match(self:get_name(), ":%s*(.*)")
			local tmp = {}
			for x in string.gmatch(a_name, "[^_]+") do
				table.insert(tmp, x)
			end
			return {material=tmp[1], size=tmp[2]}
		end,


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
			-- FIXME: not being called in classic mode

			if self.origin == nil then
				-- FIXME: should be done at time of creation?

				if not classic_gameplay and #active_asteroids >= active_limit then
					-- FIXME: this should be done before object is created
					-- DEBUG:
					core.log("warning", "too many asteroids, removing ...")
					self.object:remove()
					return
				end

				-- add to list of active asteroids
				table.insert(active_asteroids, self)

				self.origin = {
					ms = get_time_ms(),
					pos = self.object:get_pos()
				}

				-- speed at which asteroid is travelling
				local speed = rand:next(5, 20) / 10

				local target_point = gameplay_center
				local player = core.get_player_by_name("singleplayer")
				if player ~= nil then
					target_point = player:get_pos()
				end

				-- use player position to calculate direction of travel
				local dir = direction_between(self.origin.pos, target_point)
				-- randomly offset slightly
				dir.yaw = dir.yaw + rand_thousandth(-0.2, 0.2)
				dir.pitch = dir.pitch + rand_thousandth(-0.2, 0.2)
				-- apply speed & direction to asteroid
				self.object:set_velocity({
					x = speed * math.cos(dir.pitch) * math.sin(dir.yaw),
					y = speed * math.sin(dir.pitch),
					z = speed * math.cos(dir.pitch) * math.cos(dir.yaw)
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

			if game_paused then
				return
			end

			-- distance asteroid has traveled from gameplay area center
			local distance_from_center = math.floor(get_distance(self.object:get_pos(), gameplay_center))
			-- remove from game if moved past boundaries of gameplay
			-- TODO: ignore if in classic mode
			if distance_from_center > gameplay_radius then
				self.object:remove()
				self:on_removed()
				return
			end

			-- remove from game if age limit reached
			-- TODO: ignore if in classic mode
			if math.floor(self:get_age() / 60) >= age_limit_minutes then
				self.object:remove()
				self:on_removed()
				return
			end

			-- update asteroid's angle of rotation
			rotate_step(self)
		end,


		on_death = function(self, killer)
			self:on_removed()

			if type(on_destroyed) == "function" then
				on_destroyed(killer, self:get_point_value())
			end

			if classic_gameplay then
				local a_type = self:get_type()
				if a_type.size == "large" then
					local pos = self.object:get_pos()
					-- replace with two medium asteroids
					for idx = 1, 2, 1 do
						local o_pos = {y=pos.y, z=pos.z}
						-- offset so appear next to each other
						if idx == 1 then
							o_pos.x = pos.x + 0.75
						else
							o_pos.x = pos.x - 0.75
						end
						local obj = core.add_entity(o_pos, "asteroids:"..a_type.material.."_medium")
						if not obj then
							core.log("error", "failed to add asteroids to game")
						end
					end
				elseif a_type.size == "medium" then
					-- replace with single small asteroid
					local obj = core.add_entity(self.object:get_pos(), "asteroids:"..a_type.material
							.."_small")
					if not obj then
						core.log("error", "failed to add asteroids to game")
					end
				end
			end
		end,


		--- Called when an asteroid is removed from game.
		on_removed = function(self)
			for idx, obj in ipairs(active_asteroids) do
				if obj == self then
					table.remove(active_asteroids, idx)
					break
				end
			end

			-- DEBUG:
			core.log("remaining asteroids: "..#active_asteroids)
		end
	})
end


return register_asteroid
