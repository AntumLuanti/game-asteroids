
-- no air in space
core.unregister_item("air")

-- override mapgen to only use space nodes
core.set_mapgen_setting("mg_name", "singlenode", true)
core.set_mapgen_setting("mg_flags", "nomountains, nocurves, noridges, nobiomes", true)
core.register_on_generated(function(vmanip, minp, maxp, blockseed)
	local vm = core.get_mapgen_object("voxelmanip")
	local vm_data = vm:get_data()
	local c_id = core.get_content_id("space")
	for idx in ipairs(vm_data) do
		vm_data[idx] = c_id
	end
	vm:set_data(vm_data)
	vm:set_lighting({day=0, night=15})
	vm:write_to_map()
end)


core.register_globalstep(function(dtime)
	-- make night persist
	core.set_timeofday(0)
end)
