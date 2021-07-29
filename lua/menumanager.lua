--[[
	player:
		underbarrel detection (local only)
		tick bouncing animations
		figure out a melee slot, swap selection box to it while melee is active
		deployable selection box
		
		system for tracking and stopping specific animations by thread

		
	unload unused weapon icon assets to prevent fuckups like the one i just spent 12 hours on
	
	revert to old vitals tick settings to create bgs? 
	this would allow color changing without interference from set_health
	yeah probably that's the way
	
	display modes:	
		- faithful: 10 hearts (20 half hearts) of health and armor both
		- helpful: hearts x[amount]
		
	on gun loaded:
		use mc bow icon until asset loaded
		- search for icon by gun id 
			--TODO do mass lookup by all guns in weapontweakdata for existing icon
			-- log missing guns to missing_guns
		- if gun icon exists, use it
		- if not, use bow icon
		- if possible, uses set_gun_icon function as callback on asset loaded

	settings:
		- infamy, level, or both


> creation notes: 
	player: 
		- item bar:
			0 (offhand). underbarrel? melee?
			1. weapon1
			2. weapon2
			3. throwable count
			4. deployable1
			5. deployable2
			6. cableties
			7. bodybags
			8. lootbag
			9. pagers? melee?
			
			- offhand weapon?
		- minecraft crit meter is throwable cooldown meter
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
		
		- nametag on bottom? (menu option)
	team:
		- nametag above head
			-upside down easter egg?
		- level/infamy
		- health/armor
		- throwable
		- deployable(s)
		- cableties
		- lootbag




> assets todo:
	* better non-outlined, shadowed font
	* minecraft bow icon (default weapon)
		- draw "animation" on hotbar when adsing?
	* status effects interface in ui, for buffs panel later
> how am i going to make the character in the inventory screen

--]]

MinecraftHUD = MinecraftHUD or {}
MinecraftHUD._path = MinecraftHUD._path or ModPath
MinecraftHUD._save_path = MinecraftHUD._save_path or SavePath
MinecraftHUD._data_path = MinecraftHUD._data_path or (MinecraftHUD._save_path .. "minecrafthud.json")
MinecraftHUD._assets_path = MinecraftHUD._assets_path or (MinecraftHUD._path .. "assets/")
MinecraftHUD._main_menu_path = MinecraftHUD._main_menu_path or (MinecraftHUD._path .. "menu/options.json")
MinecraftHUD._default_localization_file = MinecraftHUD._default_localization_path or "english.json"

MinecraftHUD._color_data = {
	text_white = Color("ffffff"),
	text_shadow = Color("3e3e3e"),
	tooltip_color_default = Color("ffffff"),
	tooltip_color_nicknamed = Color("00ffff"),
	tooltip_color_lootbag = Color("ffd700"),
	level_text = Color("7efc20"),
	xp_counter = Color("B7FD98"),
	xp_bar_potential = Color("888800"),
	durability_bg = Color("000000"),
	durability_high = Color("00ff00"),
	durability_medium = Color("ddff00"),
	durability_low = Color("ff7700"),
	durability_empty = Color("ff0000")
}

MinecraftHUD._fonts = {
	minecraft = "fonts/minecraftia",
	minecraft_outline = "fonts/minecraftia_outline"
}

MinecraftHUD._textures = {
	icons_atlas = {
		path = "guis/textures/mchud/hud/icons_atlas",
		extension = "texture"
	},
	ui_atlas = {
		path = "guis/textures/mchud/hud/ui_atlas",
		extension = "texture"
	},
	bow_icon = {
		path = "guis/textures/mchud/hud/bow_standby",
		extension = "png"
	}
	--[[
	,
	hotbar = {
		path = "guis/textures/mchud/hud/minecraft_hotbar",
		extension = "texture"
	},
	hotbar_selection = {
		--none yet
	},
	xp_empty = {
		path = "guis/textures/mchud/hud/minecraft_xp_empty",
		extension = "texture"
	},
	xp_full = {
		path = "guis/textures/mchud/hud/minecraft_xp_full",
		extension = "texture",
		size = {
			728, 20
		}
	}
	--]]
}
MinecraftHUD._weapon_icons_path = "guis/textures/mchud/vanilla_guns/"
MinecraftHUD._weapon_icons = {
	--auto-generated
}

MinecraftHUD._sounds = { --not done/used
	player_hit = {
		file = "oof",
		type = "ogg"
	}
}
	
MinecraftHUD._hud_data = {
	size = 36,
	health_ticks = 10,
	armor_ticks = 10,
	hunger_ticks = 10,
	hotbar_slots = 9,
	SLOT_WEAPON_PRIMARY = 1,
	SLOT_WEAPON_SECONDARY = 2,
	SLOT_GRENADE = 3,
	SLOT_DEPLOYABLE_PRIMARY = 4,
	SLOT_DEPLOYABLE_SECONDARY = 5,
	SLOT_CABLETIES = 6,
	SLOT_BODYBAGS = 7,
	SLOT_LOOTBAGS = 8,
	atlas = {
		--icons
		health_empty_black = {
			xy = {0,0},
			atlas = "icons"
		},
		health_empty_white  = {
			xy = {1,0},
			atlas = "icons"
		},
		health_empty_red  = {
			xy = {2,0},
			atlas = "icons"
		},
		health_empty_white_but_again  = {
			xy = {3,0},
			atlas = "icons"
		},
		health_heart_full  = {
			xy = {4,0},
			atlas = "icons"
		},
		health_heart_half  = {
			xy = {5,0},
			atlas = "icons"
		},
		health_transparent_full  = { --alpha should be handled by Lua; these should not be used
			xy = {6,0},
			atlas = "icons"
		},
		health_transparent_half  = {
			xy = {7,0},
			atlas = "icons"
		},
		health_poison_full  = {
			xy = {8,0},
			atlas = "icons"
		},
		health_poison_half  = {
			xy = {9,0},
			atlas = "icons"
		},
		health_transparent_poison_full  = {
			xy = {10,0},
			atlas = "icons"
		},
		health_transparent_poison_half  = {
			xy = {11,0},
			atlas = "icons"
		},
		health_wither_full  = {
			xy = {12,0},
			atlas = "icons"
		},
		health_wither_half  = {
			xy = {13,0},
			atlas = "icons"
		},
		health_transparent_wither_full  = {
			xy = {14,0},
			atlas = "icons"
		},
		health_transparent_wither_half  = {
			xy = {15,0},
			atlas = "icons"
		},
		health_goldenapple_full  = {
			xy = {16,0},
			atlas = "icons"
		},
		health_goldenapple_half  = {
			xy = {17,0},
			atlas = "icons"
		},
		health_frozen_full  = {
			xy = {18,0},
			atlas = "icons"
		},
		health_frozen_half  = {
			xy = {19,0},
			atlas = "icons"
		},
		health_hardcore_empty_black = {
			xy = {0,1},
			atlas = "icons"
		},
		health_hardcore_empty_white  = {
			xy = {1,1},
			atlas = "icons"
		},
		health_hardcore_empty_red  = {
			xy = {2,1},
			atlas = "icons"
		},
		health_hardcore_empty_white_but_again  = {
			xy = {3,1},
			atlas = "icons"
		},
		health_hardcore_heart_full  = {
			xy = {4,1},
			atlas = "icons"
		},
		health_hardcore_heart_half  = {
			xy = {5,1},
			atlas = "icons"
		},
		health_hardcore_transparent_full  = {
			xy = {6,1},
			atlas = "icons"
		},
		health_hardcore_transparent_half  = {
			xy = {7,1},
			atlas = "icons"
		},
		health_hardcore_poison_full  = {
			xy = {8,1},
			atlas = "icons"
		},
		health_hardcore_poison_half  = {
			xy = {9,1},
			atlas = "icons"
		},
		health_hardcore_transparent_poison_full  = {
			xy = {10,1},
			atlas = "icons"
		},
		health_hardcore_transparent_poison_half  = {
			xy = {11,1},
			atlas = "icons"
		},
		health_hardcore_wither_full  = {
			xy = {12,1},
			atlas = "icons"
		},
		health_hardcore_wither_half  = {
			xy = {13,1},
			atlas = "icons"
		},
		health_hardcore_transparent_wither_full  = {
			xy = {14,1},
			atlas = "icons"
		},
		health_hardcore_transparent_wither_half  = {
			xy = {15,1},
			atlas = "icons"
		},
		health_hardcore_goldenapple_full  = {
			xy = {16,1},
			atlas = "icons"
		},
		health_hardcore_goldenapple_half  = {
			xy = {17,1},
			atlas = "icons"
		},
		health_hardcore_frozen_full  = {
			xy = {18,1},
			atlas = "icons"
		},
		health_hardcore_frozen_half  = {
			xy = {19,1},
			atlas = "icons"
		},
		health_u_full  = {
			xy = {4,2},
			atlas = "icons"
		},
		health_u_half  = {
			xy = {5,2},
			atlas = "icons"
		},
		health_transparent_u_full  = {
			xy = {6,2},
			atlas = "icons"
		},
		health_transparent_u_half  = {
			xy = {7,2},
			atlas = "icons"
		},
		hunger_sample_full = {
			xy = {9,2},
			atlas = "icons"
		},
		breath_bubble = {
			xy = {11,2},
			atlas = "icons"
		},
		breath_pop = {
			xy = {12,2},
			atlas = "icons"
		},
		hunger_empty_black = {
			xy = {0,3},
			atlas = "icons"
		},
		hunger_empty_white = {
			xy = {1,3},
			atlas = "icons"
		},
		hunger_empty_red = {
			xy = {2,3},
			atlas = "icons"
		},
		hunger_empty_white_but_again = {
			xy = {3,3},
			atlas = "icons"
		},
		hunger_heart_full = {
			xy = {4,3},
			atlas = "icons"
		},
		hunger_heart_half = {
			xy = {5,3},
			atlas = "icons"
		},
		hunger_transparent_full = {
			xy = {6,3},
			atlas = "icons"
		},
		hunger_transparent_half = {
			xy = {7,3},
			atlas = "icons"
		},
		hunger_poison_full = {
			xy = {8,3},
			atlas = "icons"
		},
		hunger_poison_half = {
			xy = {9,3},
			atlas = "icons"
		},
		hunger_transparent_poison_full = {
			xy = {10,3},
			atlas = "icons"
		},
		hunger_transparent_poison_half = {
			xy = {11,3},
			atlas = "icons"
		},
		hunger_empty_orange = {
			xy = {12,3},
			atlas = "icons"
		},
		hunger_empty_green = {
			xy = {13,3},
			atlas = "icons"
		},
		armor_empty = {
			xy = {0,4},
			atlas = "icons"
		},
		armor_half = {
			xy = {1,4},
			atlas = "icons"
		},
		armor_full = {
			xy = {2,4},
			atlas = "icons"
		},
		armor_full_but_again = {
			xy = {3,4},
			atlas = "icons"
		},
		armor_blue_half = {
			xy = {5,4},
			atlas = "icons"
		},
		armor_blue_full = {
			xy = {6,4},
			atlas = "icons"
		},
		
		--ui
		xp_bar_empty = {
			rect = {0,0,728,20},
			atlas = "ui"
		},
		xp_bar_full = {
			rect = {0,22,728,20},
			atlas = "ui"
		},
		boss_bar_empty = {
			rect = {0,44,728,20},
			atlas = "ui"
		},
		boss_bar_full = {
			rect = {0,66,728,20},
			atlas = "ui"
		},
		jump_bar_empty = {
			rect = {0,88,728,20},
			atlas = "ui"
		},
		jump_bar_full = {
			rect = {0,110,728,20},
			atlas = "ui"
		},
		attack_indicator_hotbar_empty = {
			rect = {0,132,72,72},
			atlas = "ui"
		},
		attack_indicator_hotbar_full = {
			rect = {74,132,72,72},
			atlas = "ui"
		},
		attack_indicator_crosshair_empty = {
			rect = {148,132,64,32},
			atlas = "ui"
		},
		attack_indicator_crosshair_full = {
			rect = {214,132,64,32},
			atlas = "ui"
		},
		attack_indicator_crosshair_sweep = {
			rect = {280,132,64,32},
			atlas = "ui"
		},
		crosshair = {
			rect = {346,132,36,36},
			atlas = "ui"
		},
		hotbar = {
			rect = {0,206,728,88},
			atlas = "ui"
		},
		hotbar_selection = {
			rect = {2,296,96,96},
			atlas = "ui"
		},
		hotbar_offhand = {
			rect = {102,300,88,88},
			atlas = "ui"
		},
		connection_bar_color_1 = {
			rect = {2,394-0,40,32},
			atlas = "ui"
		},
		connection_bar_color_2 = {
			rect = {2,428-0,40,32},
			atlas = "ui"
		},
		connection_bar_color_3 = {
			rect = {2,462-0,40,32},
			atlas = "ui"
		},
		connection_bar_color_4 = {
			rect = {2,496-0,40,32},
			atlas = "ui"
		},
		connection_bar_color_5 = {
			rect = {2,530-0,40,32},
			atlas = "ui"
		},
		connection_bar_color_6 = {
			rect = {2,564-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_1 = {
			rect = {44,394-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_2 = {
			rect = {44,428-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_3 = {
			rect = {44,462-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_4 = {
			rect = {44,496-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_5 = {
			rect = {44,530-0,40,32},
			atlas = "ui"
		},
		connection_bar_searching_6 = {
			rect = {44,564-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_1 = {
			rect = {86,394-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_2 = {
			rect = {86,428-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_3 = {
			rect = {86,462-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_4 = {
			rect = {86,496-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_5 = {
			rect = {86,530-0,40,32},
			atlas = "ui"
		},
		connection_bar_green_6 = {
			rect = {86,564-0,40,32},
			atlas = "ui"
		}
	},
	durability_thresholds = {
		high = 1, --not used
		medium = 0.5,
		low = 0.25,
		empty = 0.1
	},
	atlas_name = "textures/minecraft_atlas", --not used
	get_icon = function(...)
		MinecraftHUD:log("get_icon() is deprecated! Please use MinecraftHUD.get_atlas_icon() instead!")		
		return MinecraftHUD.get_atlas_icon(...)
	end
}

MinecraftHUD.settings = MinecraftHUD.settings or {}
MinecraftHUD.default_settings = MinecraftHUD.default_settings or {
	real_ammo_display = true,
	tooltips_enabled = true,
	player_hud_scale = 1,
	team_hud_scale = 0.5,
	player_vitals_display_mode = 1, --1: faithful, 2: helpful
	team_vitals_display_mode = 1
}

MinecraftHUD._cache = {
	--store session-specific data
	crosshair_panel = nil,
	teammate_panels = {
		--indexed 1-4, contains data in addition to hud panel, eg:
		--[[
		{
			armor_ticks = 5
			health_ticks = 5,
			panel = Panel
		}
		
		--]]
	}
}


------------------------------utils


function MinecraftHUD.get_atlas_icon(name)
	local item = (type(name) == "table" and name) or MinecraftHUD._hud_data.atlas[name]
	if item then 
		local padding = item.padding or 2
		local texture = "guis/textures/mchud/hud/icons_atlas"
		local rect
		local atlas_name = item.atlas 
		if item.path then 
			texture = item.path
		elseif atlas_name == "ui" then 
			texture = "guis/textures/mchud/hud/ui_atlas"
		elseif atlas_name == "icons" then 
			texture = "guis/textures/mchud/hud/icons_atlas"
		end
		
		if item.rect then 
			rect = item.rect
		elseif item.xy then 
			local x,y = unpack(item.xy)
			local size = item.size or MinecraftHUD._hud_data.size
			rect = {padding + ((size + padding) * x),padding + ((size + padding) * y), size, size}
		end
		return texture,rect
	end
	return
end

function MinecraftHUD.old_get_atlas_icon(name)
	local item = (type(name) == "table" and name) or MinecraftHUD._hud_data.atlas[name]
	if item then 
		local x,y,size = unpack(item)
		size = size or MinecraftHUD._hud_data.size
		return {size * x, size * y, size, size}
	end
	return {0,0,size,size}
end


function MinecraftHUD.get_peer_id_by_panel_id(panel_id)
	return 1
end

function MinecraftHUD.get_panel_id_by_peer_id(peer_id)
	return 4
end

function MinecraftHUD:log(a,...)
	if Console then 
		Console:Log("MinecraftHUD: " .. tostring(a),...)
	else
		log("MinecraftHUD: " .. tostring(a),...)
	end
end



------------------------------/utils
------------------------------settings getters

function MinecraftHUD:GetPlayerScale()
	return self.settings.player_hud_scale
end

function MinecraftHUD:GetTeammateScale()
	return self.settings.teammate_hud_scale
end

function MinecraftHUD:GetPlayerVitalsDisplayMode()
	return self.settings.player_vitals_display_mode
end

function MinecraftHUD:GetTeamVitalsDisplayMode()
	return self.settings.team_vitals_display_mode
end

function MinecraftHUD:IsRealAmmoDisplayEnabled()
	return self.settings.real_ammo_display
end

function MinecraftHUD:IsTooltipEnabled()
	return self.settings.tooltips_enabled
end

function MinecraftHUD:ShouldShowWeaponNickname()
	return true
end

------------------------------/settings getters
-------------------------------visual HUD setters

function MinecraftHUD:GetHeartDataByTickIndex(panel_id,tick_index,bar_type)
	bar_type = bar_type or "health"
	local data = self._cache.teammate_panels[panel_id]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local tick_data = data.tick_data
	local bar_type = tick_data and tick_data[bar_type]
	return bar_type and bar_type[tick_index]
end

--check and set appropriate heart container types for any given player/bar type
function MinecraftHUD:CheckHeartTicks(i,bar_type)

end


function MinecraftHUD:SetPlayerColor(i,color)
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		panel:child("nametag"):set_color(color)
	end
end

function MinecraftHUD:SetExperienceProgress(percent)
	local scale = self:GetPlayerScale()
	local w = MinecraftHUD._hud_data.atlas.xp_bar_full.rect[3]
	local h = MinecraftHUD._hud_data.atlas.xp_bar_full.rect[4]
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		local xp_bar_full = panel:child("xp_panel"):child("xp_full")
		xp_bar_full:set_w(percent * w * scale)
		xp_bar_full:set_texture_rect(0,0,percent * w,h)
	end
	
end

--sets the amount of potential xp gained from completing the current heist
function MinecraftHUD:SetExperiencePotential(xp)
	if not managers.experience then 
		return
	end
	local current_amount = 0
	local needed_amount_to_next_level = 0
	local total_amount_to_next_level = 0
	
	local percent = math.min((current_amount + xp) / total_amount_to_next_level,1)
	
	do return end
	
	local scale = self:GetPlayerScale()
	local w = MinecraftHUD._hud_data.atlas.xp_bar_full.rect[3]
	local h = MinecraftHUD._hud_data.atlas.xp_bar_full.rect[4]
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		local xp_bar_potential = panel:child("xp_panel"):child("xp_bar_potential")
		xp_bar_potential:set_w(percent * w * scale)
		xp_bar_potential:set_texture_rect(0,0,percent * w,h)
	end
	
end

function MinecraftHUD:SetPlayerLevel(i,lvl)
	local data = self._cache.teammate_panels[i]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		panel:child("xp_panel"):child("level"):set_text(lvl)
	end
end

function MinecraftHUD:SetHealth(i,current,total)
	local data = self._cache.teammate_panels[i]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local get_icon = self.get_atlas_icon
	local HEALTH_TICKS = data.health_ticks or self._hud_data.health_ticks
	
	local current_ratio = current
	if not current then 
		return
	elseif total then 
		current_ratio = current / total
	end
	current_ratio = 1 - current_ratio
	
	local panel = data.panel
	local vitals_panel = panel:child("vitals_panel")
	
	
	
	local health_half_texture,health_half_texture_rect = get_icon("health_heart_half")
	local health_full_texture,health_full_texture_rect = get_icon("health_heart_full")
--	local health_empty_texture,health_empty_texture_rect = get_icon("health_empty_black")
	
	for i = HEALTH_TICKS,1,-1 do 
		local tick = vitals_panel:child("health_tick_" .. i)
		if alive(tick) then 
			local tick_ratio = (i - 1) / HEALTH_TICKS 
			if math.floor(tick_ratio * 10) >= math.floor(current_ratio * 10) then
				if tick_ratio * 10 < math.round(current_ratio * 10) then 
					tick:set_image(health_half_texture,unpack(health_half_texture_rect or {}))
				else
					tick:set_image(health_full_texture,unpack(health_full_texture_rect or {}))
				end
				tick:show()
			else
--				tick:set_image(health_empty_texture,unpack(health_empty_texture_rect or {}))
				tick:hide()
			end
		else
			break
		end
	end
end

function MinecraftHUD:SetArmor(i,current,total)
	local data = self._cache.teammate_panels[i]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local get_icon = self.get_atlas_icon
	local ARMOR_TICKS = data.armor_ticks or self._hud_data.armor_ticks
	
	
	if not (total and current and total > 0) then 
		return
	end
	local current_ratio = 1 - (current / total)
	
	local panel = data.panel
	local vitals_panel = panel:child("vitals_panel")
	
	local armor_half_texture,armor_half_texture_rect = get_icon("armor_half")
	local armor_full_texture,armor_full_texture_rect = get_icon("armor_full")
	local armor_empty_texture,armor_empty_texture_rect = get_icon("armor_empty")
	
	for i = ARMOR_TICKS,1,-1 do 
		local tick = vitals_panel:child("armor_tick_" .. i)
		if alive(tick) then 
			local tick_ratio = (i - 1) / ARMOR_TICKS 
			if math.floor(tick_ratio * 10) >= math.floor(current_ratio * 10) then
				if tick_ratio * 10 < math.round(current_ratio * 10) then 
					tick:set_image(armor_half_texture,unpack(armor_half_texture_rect or {}))
				else
					tick:set_image(armor_full_texture,unpack(armor_full_texture_rect or {}))
				end
			else
				tick:set_image(armor_empty_texture,unpack(armor_empty_texture_rect or {}))
			end
		else
			break
		end
	end
end

function MinecraftHUD:SetHunger(i,current,total)
	local data = self._cache.teammate_panels[i]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local get_icon = self.get_atlas_icon
	local HUNGER_TICKS = self._hud_data.hunger_ticks
	
	local current_ratio = current
	if not current then 
		return
	elseif total then 
		current_ratio = (current / total)
	end
	current_ratio = 1 - current_ratio
	
	local panel = data.panel
	local vitals_panel = panel:child("vitals_panel")
	
	for i = 1,HUNGER_TICKS do 
		local tick = panel:child("hunger_tick_" .. i)
		local r = (i - 1) / HUNGER_TICKS 
		if math.round(r * 10) >= current_ratio * 10 then
			tick:show()
			tick:set_image(data.atlas_name,unpack(get_icon("hunger_heart_full")))			
		elseif math.round(r * 10) >= math.floor(current_ratio * 10) then
--			tick:show()
			tick:set_image(data.atlas_name,unpack(get_icon("hunger_heart_half")))
		else
			tick:set_image(data.atlas_name,unpack(get_icon("hunger_empty_black")))
--			tick:hide()
		end
	end
	
end

function MinecraftHUD:SetHealthTicks(i,num)
	local data = self._cache.teammate_panels[i]
	if data then 
		data.health_ticks = num
		if alive(data.panel) then 
			local vitals_panel = data.panel:child("vitals_panel")
			for i = 1,self._hud_data.health_ticks do 
				local tick = vitals_panel:child("health_fill_" .. tostring(i))
				if alive(tick) then 
					--health is created right to left
					tick:set_visible(i >= num)
				else
					break
				end
			end
		end
	end
end

function MinecraftHUD:SetHotbarIcon(i,icon,source,count1,count2,bar_progress)
	--self:log(tostring(i) .. " " .. tostring(icon) .. " " .. tostring(source) .. " " .. tostring(count1) .. " " .. tostring(count2) .. " " .. tostring(bar_progress))
	local panel_data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not panel_data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local teammate_panel = panel_data.panel
	local hotbar_panel = teammate_panel:child("hotbar_panel")
	local item 
	if i == 0 then 
		item = hotbar_panel:child("hotbar_offhand_panel")
	else
		item = hotbar_panel:child("item_" .. tostring(i))
	end
	local done_any = count1 or count2 or bar_progress
	if alive(item) then 
	
	--text labels
		local counter_bottom = item:child("counter_bottom")
		local counter_top = item:child("counter_top")
		if count1 then 
			counter_top:set_text(tostring(count1))
			counter_top:show()
		elseif count1 == false then 
			counter_top:hide()
		end
		if count2 then 
			counter_bottom:set_text(tostring(count2))
			counter_bottom:show()
		elseif count2 == false then
			counter_bottom:hide()
		end
		
	--durability bar
		local durability_meter = item:child("durability_meter")
		local durability_meter_bg = item:child("durability_meter_bg")
		if bar_progress then 
			local hide_when_full = true
			local bar_color
			local durability_thresholds = self._hud_data.durability_thresholds
			local color_data = self._color_data
			if bar_progress >= durability_thresholds.medium then 
				bar_color = color_data.durability_high
			elseif bar_progress >= durability_thresholds.low then 
				bar_color = color_data.durability_medium
			elseif bar_progress >= durability_thresholds.empty then 
				bar_color = color_data.durability_low
			else
				bar_color = color_data.durability_empty
			end
			
			if bar_progress >= 1 and hide_when_full then 
				durability_meter:hide()
				durability_meter_bg:hide()
			else
				durability_meter:set_color(bar_color)
				durability_meter:set_w(bar_progress * durability_meter_bg:w())
				durability_meter:show()
				durability_meter_bg:show()
			end
		elseif bar_progress == false then
			durability_meter:hide()
			durability_meter_bg:hide()
		end
	
	--icon
		local bitmap = item:child("bitmap")
		if icon then
			local texture,texture_rect
			if source == "weapon" then 
				if self._weapon_icons[icon] then 
					texture = self._weapon_icons[icon].path
				else
--					self:log("ERROR: No weapon icon found by name " .. tostring(icon))
--					return

					texture = self._textures.bow_icon.path
					texture_rect = self._textures.bow_icon.texture_rect
				end
			elseif source == "atlas" then 
				texture,texture_rect = self.get_atlas_icon(icon)
			elseif source == "mchud" then
				if self._textures[icon] then 
					texture = self._textures[icon].path
					texture_rect = self._textures[icon].texture_rect
				end
			elseif source == "texture" then 
				if type(icon) == "table" then 
					texture = icon[1]
					texture_rect = icon[2]
				else
					texture = icon
				end
			end
			
			if texture then 
				done_any = true
				bitmap:set_image(texture,unpack(texture_rect or {}))
--				bitmap:set_size(item:size())
--				bitmap:set_center(item:w() / 2,item:h() / 2)
				bitmap:show()
			elseif texture_rect then 
--				bitmap:set_texture_rect(texture_rect)
			end
		elseif icon == false then
			bitmap:hide()
		end
		item:set_visible(done_any and true or false)
	else
		self:log("ERROR: Invalid hotbar index " .. tostring(i))
	end
end

function MinecraftHUD:SetSelectedWeapon(slot)
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		local hotbar_panel = panel:child("hotbar_panel")
		local hotbar_selection_box = hotbar_panel:child("hotbar_selection_box")
		local item
		if slot == 0 then 
			item = hotbar_panel:child("hotbar_offhand_panel")
		else 
			item = hotbar_panel:child("item_" .. tostring(slot))
		end
		if alive(item) then 
			hotbar_selection_box:show()
			hotbar_selection_box:set_center(item:center())
		else
			hotbar_selection_box:hide()
		end
	end
end

function MinecraftHUD:AddPlayerMissionEquipment(equipment_id,amount)
	
end

function MinecraftHUD:RemovePlayerMissionEquipment(equipment_id)

end

function MinecraftHUD:SetPlayerMisssionEquipmentAmount(equipment_id,amount)

end

function MinecraftHUD:AddTeammateMissionEquipment(equipment_id,amount)

end

function MinecraftHUD:RemoveTeammateMissionEquipment(equipment_id)

end

function MinecraftHUD:SetTeammateMissionEquipmentAmount(equipment_id,amount)

end

--local player only
function MinecraftHUD:CheckDeployableEquipment(do_icon,do_amount1,do_amount2)

	local pm = managers.player
	local player = pm:local_player()
	if alive(player) then 
		for slot,equipment in ipairs(pm._equipment.selections) do 
			local amounts = {
				false,
				false
			}
			for i,raw in ipairs(equipment.amount) do 
				amounts[i] = Application:digest_value(raw,false)
			end
--				local equipment_id = equipment.equipment
			local hotbar_slot = self._hud_data.SLOT_DEPLOYABLE_PRIMARY
			if slot == 2 then 
				hotbar_slot = self._hud_data.SLOT_DEPLOYABLE_SECONDARY
			end
			
			local icon,source
			if do_icon then 
				icon = {tweak_data.hud_icons:get_icon_data(equipment.icon)}
				source = "texture"
			end
			
			self:SetHotbarIcon(hotbar_slot,
				icon,
				source,
				do_amount2 and amounts[2] or nil,
				do_amount1 and amounts[1] or nil,
				nil
			)
		end
	end
end

function MinecraftHUD:SetBodybagsAmount(amount)
	self:SetHotbarIcon(self._hud_data.SLOT_BODYBAGS,
		{tweak_data.hud_icons:get_icon_data("equipment_body_bag")},
		"texture",
		nil,
		amount,
		nil
	)
end

function MinecraftHUD:SetPlayerCarry(carry_id,value,skip_tooltip)
	local carry_data = tweak_data.carry[carry_id]
	local name_id = carry_data.name_id and managers.localization:text(carry_data.name_id)
--	local value_string = value and managers.experience:cash_string(value) or ""
	
	if not skip_tooltip then 
		self:AnimateShowTooltip(name_id,MinecraftHUD._color_data.tooltip_color_lootbag)
	end
	
	self:SetHotbarIcon(self._hud_data.SLOT_LOOTBAGS,
		{
			"guis/textures/pd2/hud_tabs",
			{
				32,
				33,
				32,
				31
			}
		},
		"texture",
		nil,
		nil,
		nil
	)
end

function MinecraftHUD:HidePlayerCarry()
	self:SetHotbarIcon(self._hud_data.SLOT_LOOTBAGS,
		false,
		nil,
		nil,
		nil,
		nil
	)
end

function MinecraftHUD:AnimateShowTooltip(s,color)
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then
		if s == "" then 
			tooltip_text:stop()
		else
			color = color or self._color_data.tooltip_color_default
			local tooltip_text = panel:child("vitals_panel"):child("tooltip_text")
			tooltip_text:set_color(color)
			tooltip_text:set_alpha(1)
			tooltip_text:stop()
			tooltip_text:animate(self._animate_fadeout,2,1)
		end
	end
	self:SetTooltipText(s)
end

function MinecraftHUD:SetTooltipText(s)
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		panel:child("vitals_panel"):child("tooltip_text"):set_text(s)
	end
end

function MinecraftHUD:AnimateDurabilityBar(slot,from,to,duration)
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
	
		local durability_thresholds = self._hud_data.durability_thresholds
		local color_data = self._color_data
		local hotbar_panel = panel:child("hotbar_panel")
		local item
		if slot == 0 then 
			item = hotbar_panel:child("hotbar_offhand_panel")
		else 
			item = hotbar_panel:child("item_" .. tostring(slot))
		end
		local durability_w = 64 * 0.9
		if item then 
			local durability_meter_bg = item:child("durability_meter_bg")
			local durability_meter = item:child("durability_meter")
			
			local function anim_func(o,_from,_to,_duration,w)
				local t = 0
				local delta = _to - _from
				repeat 
					local dt = coroutine.yield()
					t = t + dt
					
					if alive(o) then 
						local bar_progress = to
					
						if duration > 0 then 
							bar_progress = _from + ((t / _duration) * delta)
						end
						
						local bar_color
						if bar_progress >= 1 then 
							o:hide()
							durability_meter_bg:hide()
						else
							durability_meter_bg:show()
							o:show()
							if bar_progress >= durability_thresholds.medium then 
								bar_color = color_data.durability_high
							elseif bar_progress >= durability_thresholds.low then 
								bar_color = color_data.durability_medium
							elseif bar_progress >= durability_thresholds.empty then 
								bar_color = color_data.durability_low
							else
								bar_color = color_data.durability_empty
							end
						end
						if bar_color then 
							o:set_color(bar_color)
						end
						
						o:set_w(w * bar_progress)
					else
						return
					end
				until t >= _duration
			end
			durability_meter:stop()
			durability_meter:animate(anim_func,from,to,duration,durability_w)
		end
	end
end

function MinecraftHUD:SetCritBar(from,to,duration)
	local crosshair_panel = self._cache.crosshair_panel
	if alive(crosshair_panel) then 
		local crit_indicator = crosshair_panel:child("crosshair_crit_indicator_full")
		local crit_indicator_empty = crosshair_panel:child("crosshair_crit_indicator_full")
		
		crit_indicator:stop()
		crit_indicator:show()
		crit_indicator_empty:show()
		local texture,texture_rect = self.get_atlas_icon("attack_indicator_crosshair_full")
		if not from then 
			local x,y,w,h = unpack(texture_rect)
			crit_indicator:set_texture_rect(x,y,to * w,h)
			crit_indicator:set_w(to * w)
		else
			local done_cb = function(o)
				if alive(crit_indicator) then 
					crit_indicator:hide()
				end
				if alive(crit_indicator_empty) then 
					crit_indicator_empty:hide()
				end
			end
			crit_indicator:animate(self._animate_progress_bar_w,duration,from,to,texture_rect,cb)
		end
	end
end

-------------------------------/visual HUD setters
-------------------------------HUD animations

--regeneration wave effect
function MinecraftHUD._animate_health_bar_wave(vitals_panel,ticks,speed,vertical_amount,y_orig)
	ticks = ticks or MinecraftHUD._hud_data.health_ticks
	speed = speed or 10
	vertical_amount = vertical_amount or 36
	y_orig = y_orig or 0
	local t = 0
	while true do 
		local dt = coroutine.yield()
		t = t + dt
		for i = 1,ticks,1 do 
			local tick = vitals_panel:child("health_tick_" .. tostring(i))
			if alive(tick) then 
				local tick_bg = vitals_panel:child("health_tick_bg_" .. tostring(i))
				local y_offset = y_orig + (vertical_amount * math.round(math.sin((speed * t * 360) + (60 * i))) )
				tick:set_y(y_offset)
				tick_bg:set_y(y_offset)
			else
				break
			end
		end
	end
end

--on damage flash (outline color + transparent heart)
function MinecraftHUD._animate_health_bar_flash(panel_index,ticks,speed,duration)
	ticks = ticks or MinecraftHUD._hud_data.health_ticks
	speed = speed or 10
	local panel_data = MinecraftHUD._cache.teammate_panels[panel_index]
	local panel = panel_data and panel_data.panel
	local vitals_panel = panel:child("vitals_panel")
	local t = 0
	while t < duration do 
		local dt = coroutine.yield()
		t = t + dt
		
		for i = 1,ticks,-1 do 
			local tick = vitals_panel:child("health_tick_" .. tostring(i))
			if alive(tick) then 
				local tick_bg = vitals_panel:child("health_tick_bg_" .. tostring(i))
				
				local bg_atlas_sub = "health_empty_red"

				local atlas_sub = "health_heart_full"

				local tick_data = MinecraftHUD:GetHeartDataByTickIndex(panel_index,i,"health")
				if tick_data then 
					if tick_data.fill == "half" then
						full = false
					end
				end
				
				local s = math.sin(speed * t * 360)
				if s > 0 then
					bg_atlas_sub = "health_empty_black"
					tick:show()
				else
					tick:hide()
				end
				
				local texture_rect = MinecraftHUD.get_atlas_icon(bg_atlas_sub)
				tick_bg:set_texture_rect(texture_rect)
				
			else
				break
			end
		end
	end

end

--low health wiggle
function MinecraftHUD._animate_health_bar_wiggle(vitals_panel,ticks,speed,vertical_amount,y_orig)

end

function MinecraftHUD._animate_armor_bar_wiggle(vitals_panel,speed,vertical_amount)

end
function MinecraftHUD._animate_stamina_bar_wiggle(vitals_panel,speed,vertical_amount)

end

function MinecraftHUD._animate_fadeout(o,hold_duration,fadeout_duration)
	local t = 0
	hold_duration = hold_duration or 2
	fadeout_duration = fadeout_duration or 0.5
	local start_alpha = o:alpha()
	while t <= hold_duration + fadeout_duration do 
		local dt = coroutine.yield()
		t = t + dt
		
		
		local new_alpha = 1
		if t < hold_duration then 
			--nothing
		else
			local progress = (t - hold_duration) / fadeout_duration
			o:set_alpha(start_alpha * (1 - (progress * progress)))
		end
	end
end

function MinecraftHUD._animate_rect_bar_w(o,duration,from,to,w,cb)
	local t = 0
	local delta = to - from
	while t < duration do 
		local dt = coroutine.yield()
		t = t + dt
		
		if alive(o) then 
			local progress = from + ((t / duration) * delta)
			o:set_w(w * progress)
		else
			return
		end
	end
	if cb then 
		cb(o)
	end
end

function MinecraftHUD._animate_progress_bar_w(o,duration,from,to,x,y,w,h,cb)
	local t = 0
	local delta = to - from
	if type(x) == "table" then 
		x,y,w,h = unpack(x)
	end
	while t < duration do 
		local dt = coroutine.yield()
		t = t + dt
		local progress = from + ((t / duration) * delta)
		
		if alive(o) then 
			o:set_texture_rect(x,y,w * progress,h)
			o:set_w(w * progress)
		else
			return
		end
	end
	if cb then 
		cb(o)
	end
end

-------------------------------/animations


-------------------------------asset loading

--Registers assets into the game's db so that they can be loaded later 
function MinecraftHUD:CheckResourcesAdded(skip_load)
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	
	for font_id,font_path in pairs(self._fonts) do 
		if DB:has(font_ids, font_path) then 
			--font already loaded, do nothing
--			self:log("Font " .. font_id .. " at path " .. font_path .. " is verified.")
		else
			--assume that if the .font is not loaded, then the .texture is not either (both are needed anyway)
--			self:log("Font " .. font_id .. " at path " .. font_path .. " is not created!")
			if not skip_load then 
				local full_asset_path = self._assets_path .. font_path
				BLT.AssetManager:CreateEntry(Idstring(font_path),font_ids,full_asset_path .. ".font")
				BLT.AssetManager:CreateEntry(Idstring(font_path),texture_ids,full_asset_path .. ".texture")
			end
		end
	end
	
	for texture_id,texture_data in pairs(self._textures) do 
		local path = texture_data.path
		local extension = texture_data.extension or "texture"
		local force_load = texture_data.force_load
		if DB:has(texture_ids,path) and not force_load then 
--			self:log("Texture " .. texture_id .. " at path " .. path .. " is verified.")
			--texture already loaded, do nothing
		else
			if not skip_load then 
				local full_asset_path = self._assets_path .. path
				BLT.AssetManager:CreateEntry(Idstring(path),texture_ids,full_asset_path .. "." .. extension)
				
--				local done_loading_cb = nil
--				managers.dyn_resource:load(texture_ids, Idstring(path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, done_loading_cb)
			end
		end
	
	end
	
	
end

--Loads assets into memory so that they can be used in-game
function MinecraftHUD:CheckResourcesReady(skip_load,done_loading_cb)
--	self:log("MinecraftHUD Checking font assets...")
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	local dyn_pkg = DynamicResourceManager.DYN_RESOURCES_PACKAGE

	if done_loading_cb then 
		done_loading_cb = function(done,resource_type_ids,resource_ids)
			if done then 
--				self:log("Completed manual asset loading for " .. tostring(resource_ids))
			end
		end
		
	end
	
	local font_resources_ready = true
	for font_id,font_path in pairs(self._fonts) do 
		if not managers.dyn_resource:is_resource_ready(font_ids,Idstring(font_path),dyn_pkg) then 
			if not skip_load then 

--				self:log("Creating DB entry for " .. tostring(font_ids) .. ", " .. tostring(font_path) .. ", " .. tostring(self._assets_path .. font_path .. ".font"))
				
				managers.dyn_resource:load(font_ids, Idstring(font_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, done_loading_cb)
				managers.dyn_resource:load(texture_ids, Idstring(font_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, done_loading_cb)
				
			end
--			self:log("Font " .. tostring(font_id) .. " is not ready!" .. (skip_load and " Skipped loading for " or " Started manual load for ") .. font_path)
			font_resources_ready = false
		else
--			self:log("Font asset " .. font_id .. " at path " .. font_path .. " is ready.")
		end
	end
	
	
	for texture_id,texture_data in pairs(self._textures) do 
		local path = texture_data.path
		local extension = texture_data.extension or "texture"
		local force_load = texture_data.force_load
		if DB and DB:has(texture_ids,path) and not force_load then 
--			self:log("Texture " .. texture_id .. " at path " .. path .. " is verified.")
			--texture already loaded, do nothing
		else
			if not skip_load then 
				local full_asset_path = self._assets_path .. path
				--BLT.AssetManager:CreateEntry(Idstring(path),texture_ids,full_asset_path .. "." .. extension)
				
				local done_loading_cb = nil
				managers.dyn_resource:load(texture_ids, Idstring(path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, done_loading_cb)
			end
		end
	
	end
	
	return font_resources_ready,texture_resources_ready
end

function MinecraftHUD:LoadWeaponIcon(id,index)
	local icon_data = id and self._weapon_icons[id] 
	if icon_data then 
		local path = icon_data.path
		local asset_path = icon_data.asset_path
		local texture_ids = Idstring("texture")
--		if DB:has(texture_ids, path) and false then 
			--do nothing; icon is already loaded
--		else
--			self:log("Loaded weapon icon [" .. tostring(id) .. "] from asset path " .. tostring(asset_path))
			BLT.AssetManager:CreateEntry(Idstring(path),texture_ids,asset_path)
			
			managers.dyn_resource:load(texture_ids, Idstring(path), DynamicResourceManager.DYN_RESOURCES_PACKAGE,
				function(a)
					--self:log("Done loading asset " .. tostring(id) .. " " .. tostring(index) .. " " .. tostring(a))
				end
			)
			
--		end
		return true
	else
		self:log("ERROR: No weapon icon found by id [" .. tostring(id) .. "]!")
		return false
	end
end

-------------------------------/asset loading
-------------------------------menus and localization

Hooks:Add("LocalizationManagerPostInit","mchud_load_localization",function(self)
	if BeardLib then 
		--do nothing; allow BeardLib's Localization Module to handle localization
	else
		self:load_localization_file( MinecraftHUD._path .. MinecraftHUD._default_localization_file)
	end
end)

function MinecraftHUD:LoadSettings()
	for k,v in pairs(self.default_settings) do 
		if self.settings[k] == nil then 
			self.settings[k] = v
		end
	end

	local file = io.open(self._data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		MinecraftHUD:SaveSettings() --create data in case there's no mod save data
	end
end

function MinecraftHUD:SaveSettings()
	local file = io.open(self._data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add( "MenuManagerInitialize", "mchud_init_menumanager", function(menu_manager)

	MenuCallbackHandler.callback_mchud_set_realammo = function(self,item)
		MinecraftHUD.settings.real_ammo_display = item:value() == "on"
		MinecraftHUD:SaveSettings()
	end
	
	MenuCallbackHandler.callback_mchud_set_player_hud_scale = function(self,item)
		MinecraftHUD.settings.player_hud_scale = tonumber(item:value())
		MinecraftHUD:SaveSettings()
	end
	MenuCallbackHandler.callback_mchud_set_team_hud_scale = function(self,item)
		MinecraftHUD.settings.team_hud_scale = tonumber(item:value())
		MinecraftHUD:SaveSettings()
	end
	
	MenuCallbackHandler.callback_mchud_menu_close = function(self)
--		MinecraftHUD:SaveSettings()
	end
	MenuHelper:LoadFromJsonFile(MinecraftHUD._main_menu_path, MinecraftHUD, MinecraftHUD.settings)
end)

-------------------------------/menus and localization

-------------------------------initialization
MinecraftHUD:LoadSettings()

--register weapon icons, to be loaded later
local get_files = SystemFS and callback(SystemFS,SystemFS,"list") or file and callback(file,file,"GetFiles")
if get_files then 
--	local texture_ids = Idstring("texture")
	local assets_path = MinecraftHUD._assets_path
	local icons_path = MinecraftHUD._weapon_icons_path
	
	local function separate_extension(s)
		--find last period in the string; assume anything after it is the extension
		local j
		for i = string.len(s),1,-1 do 
			if string.sub(s,i,i) == "." then 
				j = i
			end
		end
		if not j then 
			return 
		end
		return string.sub(s,1,j-1),string.sub(s,j+1)
	end
	
	local ext_whitelist = {
		png = true,
		texture = true
	}
	local function is_extension_allowed(ext)
		return ext and ext_whitelist[string.lower(ext)]
	end
	
	for i,raw_filename in ipairs(get_files(assets_path .. icons_path)) do
		local filename,extension = separate_extension(raw_filename)
		if is_extension_allowed(extension) then 
			if not (filename and extension) then 
				MinecraftHUD:log("ERROR: bad filename when registering custom weapon icons: " .. tostring(raw_filename))
				return
			end
	--		MinecraftHUD:log("Registering custom weapon icon for weapon with id: [" .. filename .. "]")
			
			local path = icons_path .. filename
			MinecraftHUD._weapon_icons[filename] = {
				id = filename, --not used but just in case
				index = i,
				path = path,
				asset_path = assets_path .. path .. "." .. extension,
				extension = extension
			}
		end
	end
	
	--unload all here? not sure if textures are unloaded from memory between states
else
	MinecraftHUD:log("ERROR: could not load/register weapon icon pngs!")
end

MinecraftHUD:CheckResourcesAdded()

-------------------------------/initialization







--[[




function MinecraftHUD:SetSomething()
	local data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	if not data then 
--		self:log("ERROR: No teammate panel found: " .. tostring(i))
		return
	end
	local panel = data.panel
	if alive(panel) then 
		local hotbar_panel = panel:child("hotbar_panel")
		
	end

end



local panel = MinecraftHUD._cache.teammate_panels[4].panel:child("vitals_panel")
panel:stop()
adf = panel:animate(MinecraftHUD._animate_health_bar_wiggle,10,800,6,panel:h() - 36)
return adf

local weapons = {"new_raging_bull","s552","ppk","g3","huntsman","hk21","gre_m79","galil","deagle"}
for i,weapon in ipairs(weapons) do 
	MinecraftHUD:LoadWeaponIcon(weapon)
	MinecraftHUD:SetHotbarIcon(i,weapon,"weapon",math.random(100),math.random(50),nil)
end

MinecraftHUD:SetHotbarIcon(2, "s552", "weapon", nil, nil, nil, false)
MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("counter_bottom"):set_font_size(64)
MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("bitmap"):set_size(72,72)

MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_4"):child("bitmap"):set_image(MinecraftHUD._weapon_icons.msr.path)

MinecraftHUD:SetHotbarIcon(1,"bow_standby","mchud",0,0,false)


for i = 3, 9,1 do 
	MinecraftHUD:SetHotbarIcon(i,false,nil,"","",false)
end
MinecraftHUD:LoadWeaponIcon("ppk")
MinecraftHUD:SetHotbarIcon(3,"ppk","weapon",12,40,0.5)
MinecraftHUD:SetHotbarIcon(1,"p226","weapon","32","456",0.2)



managers.dyn_resource:load(Idstring("texture"), Idstring(MinecraftHUD._weapon_icons.p226.path), DynamicResourceManager.DYN_RESOURCES_PACKAGE)
managers.dyn_resource:load(Idstring("texture"), Idstring(MinecraftHUD._weapon_icons.msr.path), DynamicResourceManager.DYN_RESOURCES_PACKAGE)







local function safe_load( path, ext )
    -- Does it exist?
    if managers.dyn_resource and DB:has( ext, path ) then
        local asset_type = Idstring(ext)
        local asset_path = Idstring(path)
        local asset_package = DynamicResourceManager.DYN_RESOURCES_PACKAGE

        -- Check if it's loaded.
        local key = managers.dyn_resource._get_resource_key( asset_type, asset_path, asset_package )
        local entry = managers.dyn_resource._dyn_resources[key]

        if not entry then
            -- Unload it.
            managers.dyn_resource:load( asset_type, asset_path, asset_package, false )
        end

        -- Success!
        return true
    end

    -- Failure!
    return false
end





MinecraftHUD:SetHotbarIcon(3,"ak5","weapon")
	
	local dyn_pkg = DynamicResourceManager.DYN_RESOURCES_PACKAGE
	local tids = Idstring("texture")
	for weapon,data in pairs(MinecraftHUD._weapon_icons) do 
		local a = DB:has(tids,data.path)
		local b = managers.dyn_resource:is_resource_ready(tids,Idstring(data.path),dyn_pkg)
		
		log("Item " .. tostring(weapon) .. " of index " .. tostring(data.index) .. " readiness: " .. tostring(a)  .. "/" .. tostring(b))
--BLT.AssetManager:CreateEntry(Idstring(path),texture_ids,asset_path)
	end
	

--]]