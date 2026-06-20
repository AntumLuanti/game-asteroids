
dofile(core.get_modpath(core.get_current_modname()).."/weapon.lua")


-- force damage
core.settings:set_bool("enable_damage", true)
-- disable fog by default
core.settings:set_bool("enable_fog", false)


core.register_on_prejoinplayer(function(name, ip)
	if name ~= "singleplayer" then
		return "single player only allowed"
	end
end)


-- score HUD ID
local hud_id = nil

--- Updates or adds score HUD.
--
--  @param player
--    Player whose HUD is being updated.
local update_score_hud = function(player)
	local meta = player:get_meta()
	local text = "score: "..meta:get_int("score").."\nhigh score: "..meta:get_int("high score")

	if hud_id == nil then
		hud_id = player:hud_add({
			type = "text",
			position = {x=0.9, y=0.05},
			alignment = {x=1, y=1},
			number = "0xFFFFFF",
			text = text
		})
	else
		player:hud_change(hud_id, "text", text)
	end
end


local player = nil
local player_input = nil

--- Initializes player with default values.
local on_start = function()
	player:set_pos({x=0, y=0, z=0})
	player:set_look_horizontal(0)
	player:set_look_vertical(0)

	local meta = player:get_meta()
	if meta:get_int("high score") == nil then
		meta:set_int("high score", 0)
	end
	-- TODO: display this in HUD?
	local prev_score = meta:get_int("score") or 0
	-- reset score for new game
	meta:set_int("score", 0)

	update_score_hud(player)

	if asteroids.is_classic_gameplay() then
		asteroids.init_classic_spawn(player)
	end
end


core.register_on_joinplayer(function(player_ref, last_login)
	player = player_ref
	player_input = player:get_player_control()
	player:set_physics_override({
		speed = 0,
		jump = 0
	})

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
	props.hp_max = 1
	player:set_properties(props)

	on_start()
end)


core.register_on_dieplayer(function(player_ref, reason)
	core.sound_play({name="asteroids_ship_explosion"})
end)


core.register_on_respawnplayer(function(player_ref)
	asteroids.clear()
	asteroids.set_paused(false)
	on_start()
end)


core.register_on_player_receive_fields(function(player_ref, formname, fields)
	if formname == "death" then
		core.close_formspec(player_ref:get_player_name(), formname)
		if fields.respawn then
			player_ref:respawn()
		elseif fields.quit then
			-- reset hp to prevent death formspec displaying at next startup
			player_ref:set_hp(player_ref:get_properties().hp_max)
			core.request_shutdown()
		end
	end
end)

-- TODO: clean up
local death_formspec = "\
size[9,3]\
label[3.85,0;Game Over]\
button[1,0.5;3,2;respawn;Try Again]\
button[5,0.5;3,2;quit;Quit]\
"

core.show_death_screen = function(player_ref, reason)
	core.show_formspec(player_ref:get_player_name(), "death", death_formspec)
end

core.register_on_dieplayer(function(player_ref, reason)
	asteroids.set_paused(true)
end)

-- callback when an asteroid is destroyed
asteroids.set_on_destroyed(function(player, points)
	if player == nil then
		player = core.get_player_by_name("singleplayer")
	end

	if player == nil then
		core.log("warning", "cannot award points to nil player")
		return
	end

	local meta = player:get_meta()
	points = meta:get_int("score") + points
	meta:set_int("score", points)
	if points > meta:get_int("high score") then
		meta:set_int("high score", points)
	end
	update_score_hud(player)
end)


local ship_controls = {
	speed = 0.01,
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
	if asteroids.is_paused() then
		return
	end

	logic()
end)
