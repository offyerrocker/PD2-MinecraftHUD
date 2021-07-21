do return end
Hooks:PostHook(PlayerInventory,"add_unit","mchud_playerinventory_addunit",function(self,new_unit,is_equip,equip_is_instant)
	local base = new_unit:base()
	
	local use_data = base:get_use_data(self._use_data_alias)
	if use_data.selection_index and self._available_selections[use_data.selection_index] then
		local name_id = base and base:get_name_id()
		if name_id then 
			if base._setup.user_unit == self._unit then 
				if MinecraftHUD:LoadWeaponIcon(name_id,use_data.selection_index) then 
					MinecraftHUD:SetHotbarIcon(use_data.selection_index,name_id,"weapon",nil,nil,false)
				else
					MinecraftHUD:SetHotbarIcon(use_data.selection_index,"bow_standby","texture",nil,nil,false)
--					MinecraftHUD:SetHotbarIcon(1,"bow_standby","texture",0,0,false)
				end
--				log(use_data.selection_index)
				Hooks:Add("MinecraftHUDTeammatePostInit","MinecraftHUDAddWeaponIcons",function(i,panel)
	--				MinecraftHUD:SetHotbarIcon(2,"aa12","weapon",12,40,false)
					MinecraftHUD:SetHotbarIcon(use_data.selection_index,name_id,"weapon",nil,nil,false)
				end)
			end
		end
	end
end)
