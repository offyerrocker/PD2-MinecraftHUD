local debug_rect_visible = false

Hooks:Register("MinecraftHUDOnTeammateInit")

--creation
Hooks:PostHook(HUDTeammate,"init","mchud_teammate_init",function(self,_i, teammates_panel, is_player, width)
	if not is_player then return end
	
--get some useful minecrafthud "tweakdata" values
	local mctd = MinecraftHUD._hud_data
	local texture_data = MinecraftHUD._textures
	local font_data = MinecraftHUD._fonts
	local scale = 1
	if is_player then
		scale = scale * MinecraftHUD:GetPlayerScale()
	else
		scale = scale * MinecraftHUD:GetTeammateScale()
	end
	local HEALTH_TICKS = mctd.health_ticks
	local HUNGER_TICKS = mctd.hunger_ticks
	local ARMOR_TICKS = mctd.armor_ticks
	local HOTBAR_SLOTS = mctd.hotbar_slots
	local get_icon = MinecraftHUD.get_atlas_icon
	local DEFAULT_SIZE = 36
	local level_font_size = 48
	local hotbar_counter_font_size = 32
	local hotbar_offhand_x_offset = 128
	local nametag_font_size = 48
--main mchud panel for any given criminal
	local teammate_panel = managers.hud._saferect:panel():panel({
		name = "mchud_" .. tostring(_i)
	})
	teammate_panel:rect({name="debug",color=Color.red,alpha=0.1,visible=debug_rect_visible})
	MinecraftHUD._cache.teammate_panels[_i] = new_panel_data
	local new_panel_data = {
		panel = teammate_panel,
		tick_data = {
			health = {},
			armor = {},
			hunger = {}
		}
	}

--set some useful alignment variables
	local hotbar_bottom_margin = 0 --space between hotbar bottom and screen bottom edge
	local xp_bottom_margin = 10 --space between xp bar bottom and hotbar
	local vitals_bottom_margin = -32 --space between vitals bottom and xp bar
	--local center_y = teammate_panel:h() / 2
	
--	local center_x = teammate_panel:w() / 2
	
--subpanel creation
	local hotbar_panel = teammate_panel:panel({
		name = "hotbar_panel",
		visible = is_player,
		h = 100
	})
	hotbar_panel:set_bottom(teammate_panel:h())
	
	hotbar_panel:rect({
		name = "debug",
		color = Color.blue,
		alpha = 0.1,
		visible = debug_rect_visible
	})
	
	local hotbar_bg = hotbar_panel:bitmap({
		name = "hotbar_bg",
		texture = texture_data.hotbar.path,
		layer = 2
	})
	hotbar_bg:set_x((hotbar_panel:w() - hotbar_bg:w()) / 2)
	hotbar_bg:set_y(hotbar_panel:h() - (hotbar_bg:h() + hotbar_bottom_margin))
	--hotbar should be populated later
	
	local item_w = 72 * scale
	local item_h = 72 * scale
	local item_h_margin = 8
	local item_offset_x = hotbar_bg:x() + item_h_margin
	local item_offset_y = hotbar_bg:y() + 8
	for i=1,HOTBAR_SLOTS,1 do
		local item = hotbar_panel:panel({
			name = "item_" .. tostring(i),
			x = item_offset_x + ((i - 1) * ((item_w + item_h_margin) * scale)),
			y = item_offset_y,
			w = item_w,
			h = item_h,
			layer = 3,
			visible = false
		})
		local counter_top = item:text({
			name = "counter_top",
			font = font_data.minecraft,
			font_size = hotbar_counter_font_size,
			text = "",
			color = Color.white,
			align = "right",
			vertical = "top",
			layer = 5
		})
		local counter_bottom = item:text({
			name = "counter_bottom",
			font = font_data.minecraft,
			font_size = hotbar_counter_font_size,
			text = "",
			color = Color.white,
			align = "right",
--			vertical = "bottom", --this is broken for some custom fonts randomly. dunno.
			y = item_h - (hotbar_counter_font_size / 1.5),
			layer = 6
		})
			
		local durability_meter = item:rect({
			name = "durability_meter",
			color = MinecraftHUD._color_data.durability_high,
			w = item_w * 0.9,
			h = 4,
			y = item:h() - 8,
			layer = 8,
			visible = false
		})
		durability_meter:set_x((item:w() - durability_meter:w()) / 2)
		local durability_meter_bg = item:rect({
			name = "durability_meter_bg",
			color = MinecraftHUD._color_data.durability_bg,
			w = item_w * 0.9,
			h = 6,
			x = durability_meter:x(),
			y = item:h() - 8,
			layer = 7,
			visible = false
		})
		local bitmap = item:bitmap({
			name = "bitmap",
			texture = "",
			w = item_w,
			h = item_h,
			layer = 4,
			alpha = 0.8,
			visible = false
		})
		bitmap:set_center(item:w()/2,item:h()/2)
		
		local debug_rect = item:rect({
			name = "debug",
			color = Color(math.random(),math.random(),math.random()),
			alpha = 0.1,
			visible = debug_rect_visible
		})
	end
	
	local hotbar_offhand_panel = hotbar_panel:panel({
		name = "hotbar_offhand_panel",
		w = item_w,
		h = item_h,
		x = hotbar_bg:x() - hotbar_offhand_x_offset,
		y = hotbar_bg:y(),
		layer = 2,
		visible = false
	})
	local hotbar_offhand_bg = hotbar_offhand_panel:bitmap({
		name = "hotbar_offhand_bg",
		texture = "",
		layer = 3
	})
	local hotbar_offhand_counter_top = hotbar_offhand_panel:text({
		name = "counter_top",
		font = font_data.minecraft,
		font_size = hotbar_counter_font_size,
		text = "",
		color = Color.white,
		align = "right",
		vertical = "top",
		layer = 5
	})
	local hotbar_offhand_counter_bottom = hotbar_offhand_panel:text({
		name = "counter_bottom",
		font = font_data.minecraft,
		font_size = hotbar_counter_font_size,
		text = "",
		color = Color.white,
		align = "right",
		vertical = "bottom",
		y = item_h - (hotbar_counter_font_size / 1.5),
		layer = 6
	})
	local hotbar_offhand_bitmap = hotbar_offhand_panel:bitmap({
		name = "bitmap",
		texture = "",
		visible = false,
		layer = 4
	})
	local hotbar_offhand_durability_meter = hotbar_offhand_panel:rect({
		name = "durability_meter",
		color = MinecraftHUD._color_data.durability_high,
		w = 32,
		h = 4,
		y = hotbar_offhand_panel:h() - 8,
		layer = 8,
		visible = false
	})
	hotbar_offhand_durability_meter:set_x((hotbar_offhand_panel:w() - hotbar_offhand_durability_meter:w()) / 2)
	local hotbar_offhand_durability_meter_bg = hotbar_offhand_panel:rect({
		name = "durability_meter_bg",
		color = MinecraftHUD._color_data.durability_bg,
		w = 32,
		h = 6,
		x = hotbar_offhand_durability_meter:x(),
		y = hotbar_offhand_panel:h() - 8,
		layer = 7,
		visible = false
	})
	
	
	local xp_panel = teammate_panel:panel({
		name = "xp_panel",
		h = 72
	})
	xp_panel:rect({
		name = "debug",
		color = Color.green,
		alpha = 0.1,
		visible = debug_rect_visible
	})
	xp_panel:set_bottom(hotbar_panel:y() - xp_bottom_margin)
	
	local xp_empty = xp_panel:bitmap({
		name = "xp_empty",
		texture = texture_data.xp_empty.path,
		layer = 2
	})
	--todo resize based on scale
--	xp_empty:set_size(xp_empty:w() / 2,xp_empty:h() / 2)
	
	xp_empty:set_x((xp_panel:w() - xp_empty:w()) / 2)
	xp_empty:set_y(xp_panel:h() - (xp_empty:h() + xp_bottom_margin))
	
--[[
	
	xp_empty:set_x((xp_panel:w() - xp_empty:w()) / 2)
	xp_empty:set_y(hotbar:y() - (xp_empty:h() + 8))
--]]
	local xp_full = xp_panel:bitmap({
		name = "xp_full",
		texture = texture_data.xp_full.path,
		x = xp_empty:x(),
		y = xp_empty:y(),
		layer = 4
	})
--	xp_full:set_size(xp_full:w() / 2,xp_full:h() / 2)
	
	local xp_potential = xp_panel:bitmap({
		name = "xp_potential",
		texture = texture_data.xp_full.path,
		x = xp_empty:x(),
		y = xp_empty:y(),
		layer = 3,
		color = MinecraftHUD._color_data.xp_bar_potential,
		visible = false
	})

	local level = xp_panel:text({
		name = "level",
		text = "",
		color = MinecraftHUD._color_data.xp_counter,
		font = font_data.minecraft,
		font_size = level_font_size,
		layer = 5,
		align = "center",
--		vertical = "bottom",
		y = xp_empty:y() - (level_font_size / 2)
	})
	
	
	local nametag = teammate_panel:text({
		name = "nametag",
		text = managers.network.account:username(),
		color = Color.white,
		font = font_data.minecraft,
		font_size = nametag_font_size,
		layer = 6,
		align = "center",
		y = xp_panel:y() - nametag_font_size
	})


	--health/armor/stamina etc
	local vitals_panel = teammate_panel:panel({
		name = "vitals_panel",
--		w = 700,
		h = 400
	})
	vitals_panel:set_bottom(xp_panel:y() - vitals_bottom_margin)
	local health_y = vitals_panel:h()
	local center_x = vitals_panel:w() / 2
	for i = 1,ARMOR_TICKS do 
		vitals_panel:bitmap({
			name = "armor_tick_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("armor_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE * 2.1),
			layer = 3
		})
		new_panel_data.tick_data.armor[i] = {
			fill = "full",
			variant = "normal"
		}
	end
	for i = 1,HEALTH_TICKS do
		vitals_panel:bitmap({
			name = "health_tick_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("health_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 5
		})
		vitals_panel:bitmap({
			name = "health_tick_lost_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("health_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 4,
			visible = false
		})
		vitals_panel:bitmap({
			name = "health_tick_bg_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("health_empty_black"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 3
		})
		
		new_panel_data.tick_data.health[i] = {
			fill = "full",
			variant = "normal"
		}
		--]]
	end
	
	for i = 1,HUNGER_TICKS do 
		vitals_panel:bitmap({
			name = "hunger_tick_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("hunger_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x + ((i - 0) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 3
		})
		vitals_panel:bitmap({
			name = "hunger_tick_bg_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("hunger_empty_black"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x + ((i - 0) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 2
		})
		new_panel_data.tick_data.hunger[i] = {
			fill = "full",
			variant = "normal"
		}
	end
	
	
	Hooks:Call("MinecraftHUDOnTeammateInit",_i,teammate_panel)
end)


--basic peer information
Hooks:PostHook(HUDTeammate,"set_name","mchud_teammate_setname",function(self,teammate_name)

end)

Hooks:PostHook(HUDTeammate,"set_cheater","mchud_teammate_setcheater",function(self,state)

end)

Hooks:PostHook(HUDTeammate,"set_callsign","mchud_teammate_setcallsign",function(self,color_id)
	if managers.experience then 
	
		local points = managers.experience:next_level_data_points()
		local current_points = managers.experience:next_level_data_current_points()
		
		MinecraftHUD:SetPlayerLevel(self._id,tostring(managers.experience:current_level()))
		MinecraftHUD:SetExperienceProgress(current_points/points)
		MinecraftHUD:SetPlayerColor(self._id,tweak_data.chat_colors[color_id])
	end
end)

Hooks:PostHook(HUDTeammate,"set_ai","mchud_teammate_setai",function(self,is_ai)
	
end)



--general setters
Hooks:PostHook(HUDTeammate,"set_health","mchud_teammate_sethealth",function(self,data)
	MinecraftHUD:SetHealth(self._id,data.current,data.total)
end)

Hooks:PostHook(HUDTeammate,"set_armor","mchud_teammate_setarmor",function(self,data)
	MinecraftHUD:SetArmor(self._id,data.current,data.total)
end)

--cable ties
Hooks:PostHook(HUDTeammate,"set_cable_tie","mchud_teammate_setcabletie",function(self,data)

end)

Hooks:PostHook(HUDTeammate,"set_cable_ties_amount","mchud_teammate_setcabletieamount",function(self,amount)

end)



--weapon info
Hooks:PostHook(HUDTeammate,"set_weapon_selected","mchud_teammate_setweaponselected",function(self,id,hud_icon)
	local is_secondary = id == 1
end)

Hooks:PostHook(HUDTeammate,"set_weapon_firemode","mchud_teammate_setweaponfiremode",function(self,id,firemode)
	local is_secondary = id == 1
end)

Hooks:PostHook(HUDTeammate,"set_ammo_amount_by_type","mchud_teammate_setammo",function(self,slot, max_clip, current_clip, current_left, max, weapon_panel)
	if self._main_player then 
--		log(slot, max_clip, current_clip, current_left, max)
		local current_reserve = current_left
		local index = 1
		if slot == "primary" then
			index = 2
		end
		if MinecraftHUD:IsRealAmmoDisplayEnabled() then 
			current_reserve = math.max(current_left - current_clip,0)
		end
		MinecraftHUD:SetHotbarIcon(index,nil,nil,current_clip,current_reserve,nil,nil)
	end
end)

--deployable info
Hooks:PostHook(HUDTeammate,"set_deployable_equipment","mchud_teammate_setdeployable",function(self,data)
	
end)
Hooks:PostHook(HUDTeammate,"set_deployable_equipment_from_string","mchud_teammate_setdeployablestring",function(self,data)
	
end)
Hooks:PostHook(HUDTeammate,"set_deployable_equipment_amount","mchud_teammate_setdeployableamount",function(self,index,data)
	
end)
Hooks:PostHook(HUDTeammate,"set_deployable_equipment_amount_from_string","mchud_teammate_setdeployableamountstring",function(self,index,data)
	
end)

--grenades/ability info
Hooks:PostHook(HUDTeammate,"set_grenades","mchud_teammate_setgrenades",function(self,data)

end)

Hooks:PostHook(HUDTeammate,"set_grenades_amount","mchud_teammate_setgrenadesamount",function(self,data)

end)

Hooks:PostHook(HUDTeammate,"set_ability_icon","mchud_teammate_setabilityicon",function(self,icon)

end)

Hooks:PostHook(HUDTeammate,"set_grenade_cooldown","mchud_teammate_setgrenadecooldown",function(self,data)

end)


--perk deck mechanics
Hooks:PostHook(HUDTeammate,"set_delayed_damage","mchud_teammate_setstoic",function(self,data)

end)

Hooks:PostHook(HUDTeammate,"set_stored_health_max","mchud_teammate_setexpresmax",function(self,stored_health_ratio)

end)

Hooks:PostHook(HUDTeammate,"set_stored_health","mchud_teammate_setexpres",function(self,stored_health_ratio)

end)

Hooks:PostHook(HUDTeammate,"set_absorb_active","mchud_teammate_setdamageabsorption",function(self,absorb_amount)

end)


--mission equipment
Hooks:PostHook(HUDTeammate,"add_special_equipment","mchud_teammate_addmissionequipment",function(self,data)

end)

Hooks:PostHook(HUDTeammate,"remove_special_equipment","mchud_teammate_removemissionequipment",function(self,equipment)

end)

Hooks:PostHook(HUDTeammate,"layout_special_equipments","mchud_teammate_layoutmissionequipment",function(self)

end)

Hooks:PostHook(HUDTeammate,"set_special_equipment_amount","mchud_teammate_setmissionequipmentamount",function(self,equipment_id,amount)

end)

--downed/swansong/tased
Hooks:PostHook(HUDTeammate,"set_condition","mchud_teammate_setcondition",function(self,icon_data)

end)

--interaction (separate from hudinteraction)
Hooks:PostHook(HUDTeammate,"teammate_progress","mchud_teammate_setprogress",function(self,enabled,tweak_data_id,timer,success)

end)

--timer (downed timer)
Hooks:PostHook(HUDTeammate,"start_timer","mchud_teammate_starttimer",function(self)

end)
Hooks:PostHook(HUDTeammate,"set_pause_timer","mchud_teammate_setpausetimer",function(self)

end)
Hooks:PostHook(HUDTeammate,"stop_timer","mchud_teammate_stop_timer",function(self)
	
end)

--animate hooks
Hooks:PostHook(HUDTeammate,"_damage_taken","mchud_teammate_ondamagetaken",function(self)

end)



--???
Hooks:PostHook(HUDTeammate,"set_info_meter","mchud_teammate_setinfometer",function(self,data)
end)

Hooks:PostHook(HUDTeammate,"set_custom_radial","mchud_teammate_setcustomradial",function(self,data)
	
end)

--team only (normal lootbag hud info is set in hudtemp)
Hooks:PostHook(HUDTeammate,"set_carry_info","mchud_teammate_setbag",function(self,carry_id,value)

end)
Hooks:PostHook(HUDTeammate,"remove_carry_info","mchud_teammate_removebag",function(self)

end)



