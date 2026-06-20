
-- determines if rules resembling classic gameplay should be used
local classic_gameplay = core.settings:get_bool("asteroids.classic", true)

--- Retrieves classic gameplay state.
--
--  @return
--    `true` if classic gameplay rules are in effect.
asteroids.is_classic_gameplay = function()
	return classic_gameplay
end
