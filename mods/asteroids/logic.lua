
-- registered logic functions
local logic_functions = {}


--- Registers a function to be called every global step.
--
--  @param func
--    Function to be called.
asteroids.register_logic = function(func)
	table.insert(logic_functions, func)
end


--- Removes function from global step logic calls.
--
--  @param func
--    Function to be removed.
asteroids.unregister_logic = function(func)
	for idx, f in ipairs(logic_functions) do
		if f == func then
			table.remove(logic_functions, idx)

			-- DEBUG:
			core.log("unregistered")

			return
		end
	end

	core.log("warning", "logic not found, not unregistering")
end


core.register_globalstep(function(dtime)
	if asteroids.is_paused() then
		-- logic functions not called when game is paused
		return
	end

	-- call all registered logic functions
	for _, func in pairs(logic_functions) do
		func(dtime)
	end
end)
