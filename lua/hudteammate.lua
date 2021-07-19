--[[

> creation notes: 
	player: 
		- main panel has default alignment
		- xp bar is aligned to bottom
		- level/infamy text is aligned to center
		- health/armor aligned left of level text, on top of xp bar
		- hunger aligned right of level text, on top of xp bar
		- item bar:
			1. weapon1
			2. weapon2
			3. throwable/cooldown
			4. deployable1
			5. deployable2
			6. cableties
			7. bodybags
			8. lootbag
		- inventory keybind? or tabscreen:
			- mission equipments
			- pagers
		
		- boss hp bar:
			- assault progress? currently aimed at enemy?
		
		- buff counter bar in inventory screen?
			- tfw minecrafthud unironically is an infohud 
		- additional information:
			- current track?
			- hostages/jokers?
		- can't forget that good default minecraft crosshair (subtract blend mode)
		
		- nametag on bottom? 
	team:
		- name
		- level/infamy
		- health/armor
		- throwable
		- deployable(s)
		- cableties
		- lootbag
	general:
		- main menu overhaul?
		- chat overhaul?




> assets todo:
	* non-outlined minecraft font
	

> how am i going to make the character in the inventory screen

--]]


Hooks:PostHook(HUDTeammate,"init","mchud_teammate_init",function(self,i, teammates_panel, is_player, width)
	local mctd = MinecraftHUD._hud_data

	local scale = 1
	--todo scale from settings
	if self._main_player then
		scale = scale * 1
	else
		scale = scale * 0.5
	end
	
	local HEALTH_TICKS = mctd.health_ticks
	local HUNGER_TICKS = mctd.hunger_ticks
	local ARMOR_TICKS = mctd.armor_ticks
	local HOTBAR_SLOTS = mctd.hotbar_slots
	
	
	
	local teammate_panel = teammates_panel:panel({
		name = "mchud_" .. tostring(i)
	})
	
	local hud_center_x = teammate_panel:w() / 2
	local hud_center_y = teammate_panel:h() / 2
	
	
	
	local vitals_panel = teammate_panel:panel({
		name = "vitals_panel",
		x = 0,
		y = 0
	})
	
	local xp_panel = teammate_panel:panel({
		name = "xp_panel",
		x = 0,
		y = 0
	})
	

	local xp_empty = xp_panel:bitmap({ --728 20
		name = "xp_empty",
		texture = "textures/minecraft_xp_empty",
		layer = 2
	})
	xp_empty:set_size(xp_empty:w() / 2,xp_empty:h() / 2)
	
	xp_empty:set_x((xp_panel:w() - xp_empty:w()) / 2)
	xp_empty:set_y(hotbar:y() - (xp_empty:h() + 8))
	
	local xp_full = xp_panel:bitmap({
		name = "xp_full",
		texture = "textures/minecraft_xp_full",
		layer = 3
	})
	xp_full:set_size(xp_full:w() / 2,xp_full:h() / 2)
	
	xp_full:set_x((xp_panel:w() - xp_full:w()) / 2)
	xp_full:set_y(hotbar:y() - (xp_full:h() + 8))
	
	local level = xp_panel:text({
		name = "level",
		text = tostring(managers.experience and managers.experience:current_level() or "7"),
		color = Color("B7FD98"),
		font = self._fonts.minecraft,
		font_size = 24,
		layer = 3,
		align = "center"
	})


	local hotbar_panel = teammate_panel:panel({
		name = "hotbar_panel",
		y = -164,
		visible = self._main_player
	})
	local hotbar_bitmap = hotbar_panel:bitmap({
		name = "hotbar_bitmap",
		texture = ""
	})
	
	local center_x = teammate_panel:w() / 2
	local health_y = hotbar:y() - (size * 2)
	
	local get_icon = mctd.get_icon
	
	for i = 1,ARMOR_TICKS do 
		vitals_panel:bitmap({
			name = "armor_" .. i,
			texture = "textures/minecraft_atlas",
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
			name = "health_fill_" .. i,
			texture = "textures/minecraft_atlas",
			texture_rect = get_icon("health_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x - ((i + 1) * DEFAULT_SIZE),
			y = health_y,
			layer = 3
		})
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
	end
	
	for i = 1,HUNGER_TICKS do 
		vitals_panel:bitmap({
			name = "hunger_fill_" .. i,
			texture = "textures/minecraft_atlas",
			texture_rect = get_icon("hunger_heart_full"),
			w = DEFAULT_SIZE,
			h = DEFAULT_SIZE,
			x = center_x + ((i - 0) * DEFAULT_SIZE),
			y = health_y,
			layer = 3
		})
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
	end
	
	

	
	
	
	if self._main_player then 
		vitals_panel:set_y(-164)
	end
	
	
end)