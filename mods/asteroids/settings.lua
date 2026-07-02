
--~ local world_conf = core.get_worldpath().."/minetest.conf"
--~ asteroids.settings = Settings(world_conf)

--~ asteroids.settings:set_bool("enable_damage", true) -- handled in game.conf
--~ asteroids.settings:set_bool("enable_fog", false)
--~ asteroids.settings:set("mapgen_limit", "50")
--~ asteroids.settings:write()

--~ -- override causes crash if this isn't set
--~ asteroids.settings:set("default_privs", core.settings:get("default_privs"))

--~ local settings_orig = core.settings
--~ core.settings = asteroids.settings


-- stored default values
local settings_defaults = {}


--- Workaround for applying settings to game instance only.
--
--  Stored default values are restored on server shutdown.
asteroids.settings = {
	set = function(self, key, value)
		local v_default = core.settings:get(key) or "nil"
		settings_defaults[key] = v_default
		core.settings:set(key, value)
	end,

	set_bool = function(self, key, value)
		assert(type(value) == "boolean")
		self:set(key, tostring(value))
	end,

	restore = function(self)
		for k, v in pairs(settings_defaults) do
			if v == "nil" then
				v = nil
			end
			core.settings:set(k, v)
		end
	end
}

core.register_on_shutdown(function()
	-- FIXME: won't be restored on abnormal shutdown
	asteroids.settings:restore()
end)


asteroids.settings:set("mapgen_limit", "50")
asteroids.settings:set_bool("enable_fog", false)
