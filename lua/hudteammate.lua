Hooks:PostHook(HUDTeammate,"init","mchud_teammate_init",function(self,_i, teammates_panel, is_player, width)
	if not self._main_player then return end
	
--get some useful minecrafthud "tweakdata" values
	local mctd = MinecraftHUD._hud_data
	local texture_data = MinecraftHUD._textures
	local scale = 1
	if self._main_player then
		scale = scale * MinecraftHUD:GetPlayerScale()
	else
		scale = scale * MinecraftHUD:GetTeammateScale()
	end
	local HEALTH_TICKS = mctd.health_ticks
	local HUNGER_TICKS = mctd.hunger_ticks
	local ARMOR_TICKS = mctd.armor_ticks
	local HOTBAR_SLOTS = mctd.hotbar_slots
	
	local get_icon = MinecraftHUD.get_atlas_icon
	
--main mchud panel for any given criminal
	local teammate_panel = teammates_panel:panel({
		name = "mchud_" .. tostring(i)
	})

--set some useful alignment variables
	local hotbar_bottom_margin = 64 --space between hotbar bottom and screen bottom edge
	local xp_bottom_margin = 10 --space between xp bar bottom and hotbar
	local vitals_bottom_margin = 4 --space between vitals bottom and xp bar
	local center_y = teammate_panel:h() / 2
	local center_x = teammate_panel:w() / 2
	
--subpanel creation
	local hotbar_panel = teammate_panel:panel({
		name = "hotbar_panel",
		visible = self._main_player
	})
	hotbar_panel:set_bottom(-hotbar_bottom_margin)
	
	local hotbar_bg = hotbar_panel:bitmap({
		name = "hotbar_bg",
		texture = texture_data.hotbar.path
	})
	--todo populate hotbar
	for i=1,HOTBAR_SLOTS,1 do
		local item_w = 36 * scale
		local item_h = 36 * scale
		local item_offset_x = 0
		local item = hotbar:panel({
			name = "item_" .. tostring(i),
			x = item_offset_x + (item_w * scale),
			y = 0,
			w = item_w,
			h = item_h,
			visible = false
		})
		local counter_top = item:text({
			name = "counter_top",
			font = font_data.minecraft,
			font_size = 12,
			text = "",
			color = Color.white,
			align = "right",
			vertical = "top"
		})
		local counter_bottom = item:text({
			name = "counter_bottom",
			font = font_data.minecraft,
			font_size = 12,
			text = "",
			color = Color.white,
			align = "right",
			vertical = "bottom"
		})
		local bitmap = item:bitmap({
			name = "bitmap",
			texture = ""
		})
		bitmap:set_center(item:center())
		
		local debug_rect = item:rect({
			name = "debug",
			color = Color(math.random(),math.random(),math.random()),
			alpha = 0.1
		})
	end
	
	
	local xp_panel = teammate_panel:panel({
		name = "xp_panel",
		w = 700,
		h = 400
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
		text = tostring(managers.experience and managers.experience:current_level() or "0"),
		color = MinecraftHUD._color_data.xp_counter,
		font = MinecraftHUD._fonts.minecraft,
		font_size = 24,
		layer = 5,
		align = "center",
--		vertical = "bottom",
		y = xp_empty:y()
	})


	

	--health/armor/stamina etc
	local vitals_panel = teammate_panel:panel({
		name = "vitals_panel",
		w = 700,
		h = 400,
		x = 0,
		y = 0
	})
	vitals_panel:set_bottom(xp_panel:y() - vitals_bottom_margin)
	local health_y = vitals_panel:h()

	for i = 1,ARMOR_TICKS do 
		vitals_panel:bitmap({
			name = "armor_tick_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("armor_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y - (DEFAULT_SIZE),
			layer = 3
		})
	end
	for i = 1,HEALTH_TICKS do
		vitals_panel:bitmap({
			name = "health_tick_" .. i,
			texture = texture_data.atlas.path,
			texture_rect = get_icon("health_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y,
			layer = 3
		})
		--[[
		vitals_panel:bitmap({
			name = "health_bg_" .. i,
			texture = "textures/minecraft_atlas",
			texture_rect = get_icon("health_empty_black"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y,
			layer = 2
		})
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
			y = health_y,
			layer = 3
		})
		--[[
		vitals_panel:bitmap({
			name = "hunger_bg_" .. i,
			texture = "textures/minecraft_atlas",
			texture_rect = get_icon("hunger_empty_black"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x + ((i - 0) * DEFAULT_SIZE),
			y = health_y,
			layer = 2
		})
		--]]
	end
	
	
	
end)



