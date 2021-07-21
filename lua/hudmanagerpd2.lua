
Hooks:PostHook(HUDManager,"_set_weapon","mchud_hudmanager_setweapon",function(self,data)
	local unit = data.unit
	if alive(unit) then 
		local base = unit:base()
		local name_id = base:get_name_id()
		local index = data.inventory_index
--		log("Set unit " .. tostring(name_id))
		MinecraftHUD:LoadWeaponIcon(name_id,index)
	end
end)

Hooks:PostHook(HUDManager,"add_weapon","mchud_hudmanager_addweapon",function(self,data)
--	do return end
	local unit = data.unit
	if alive(unit) then 
		local base = unit:base()
		local name_id = base:get_name_id()
		local index = data.inventory_index
--		log("Added unit " .. tostring(name_id))
		MinecraftHUD:SetHotbarIcon(index,name_id,"weapon",nil,nil,false)
	end
end)