
dofile(core.get_modpath(core.get_current_modname()).."/weapon.lua")


core.register_on_prejoinplayer(function(name, ip)
	if name ~= "singleplayer" then
		return "single player only allowed"
	end
end)

local player = nil
local player_input = nil

core.register_on_joinplayer(function(player_ref, last_login)
	player = player_ref
	player_input = player:get_player_control()
	player:set_physics_override({
		speed = 0,
		jump = 0
	})
	player:set_pos({x=0, y=0, z=0})
	player:set_look_horizontal(0)
	player:set_look_vertical(0)

	-- make player fly
	player:set_physics_override({gravity=0})
	-- disable sun, moon, & clouds
	player:set_sun({visible=false, sunrise_visible=false})
	player:set_moon({visible=false})
	player:set_stars({visible=false})
	player:set_sky({
		type = "skybox",
		textures = {
			"asteroids_stars.png", "asteroids_stars.png",
			"asteroids_stars.png", "asteroids_stars.png",
			"asteroids_stars.png", "asteroids_stars.png"
		},
		clouds = false
	})
	-- TODO: disable fog

	-- disable inventory
	player:set_inventory_formspec("")

	-- disable hotbar
	player:hud_set_flags({hotbar=false})

	local props = player:get_properties()
	-- set player model & mesh
	props.visual = "mesh"
	props.mesh = "asteroids_ship.obj"
	props.textures = {"asteroids_ship.png"}
	props.visual_size = {x=1, y=1, z=1}
	props.eye_height = 0
	player:set_properties(props)
end)

-- disable fog by default
core.settings:set_bool("enable_fog", false)


local ship_controls = {
	speed = 10,
	sound_handle = nil,
	boosting = false,

	handle_input_change = function(self, input)
		if input.movement_y ~= player_input.movement_y then
			self.boosting = input.movement_y == 1
			self:handle_sound()
		end

		player_input = input
	end,

	handle_sound = function(self)
		if self.boosting and not self.sound_handle then
			self.sound_handle = core.sound_play({name="asteroids_ship_engine"}, {loop=true})
		elseif not self.boosting and self.sound_handle then
			core.sound_stop(self.sound_handle)
			self.sound_handle = nil
		end
	end,

	update_velocity = function(self)
		-- TODO: ship should "coast" after boost
		if self.boosting then
			-- FIXME: there is some jittering during boost when changing look direction due to client updating before receiving response
			local pos = player:get_pos()
			local look = player:get_look_dir()
			player:set_pos({x=pos.x+look.x*self.speed, y=pos.y+look.y*self.speed, z=pos.z+look.z*self.speed})
		end
	end,
}

local logic = function()
	if not player then
		return
	end

	ship_controls:update_velocity()

	local input = player:get_player_control()
	local input_changed = false

	for k, v in pairs(input) do
		if input[k] ~= player_input[k] then
			input_changed = true
			ship_controls:handle_input_change(input)
			break
		end
	end
end


core.register_globalstep(function(dtime)
	logic()
end)
