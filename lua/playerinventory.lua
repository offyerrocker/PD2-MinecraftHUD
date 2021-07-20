Hooks:PostHook(PlayerInventory,"add_unit","mchud_playerinventory_addunit",function(self,new_unit,is_equip,equip_is_instant)
	local base = new_unit:base()
	
	local use_data = base:get_use_data(self._use_data_alias)
	if use_data.selection_index and self._available_selections[use_data.selection_index] then
		local name_id = base and base:get_name_id()
		if name_id then 
			MinecraftHUD:LoadWeaponIcon(name_id,self._latest_addition)
		end
	end
end)