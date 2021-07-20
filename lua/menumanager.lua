--[[
	revert to old vitals tick settings to create bgs? 
	this would allow color changing without interference from set_health
	yeah probably that's the way
	
	display modes:	
		- faithful: 10 hearts (20 half hearts) of health and armor both
		- helpful: hearts x[amount]
		
	on gun loaded (hook to playerinventory):
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
		- main panel has default alignment
		- xp bar is aligned to bottom
		- level/infamy text is aligned to center
		- health/armor aligned left of level text, on top of xp bar
		- hunger aligned right of level text, on top of xp bar
		- item bar:
			1. weapon1
			2. throwable count
			3. deployable1
			4. deployable2
			5. cableties
			6. bodybags
			7. lootbag
			- offhand weapon2
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
	general:
		- main menu overhaul?
		- chat overhaul?




> assets todo:
	* non-outlined minecraft font
	* hotbar selection square
	* minecraft bow icon (default weapon)
		- draw "animation" on hotbar when adsing?

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
	xp_counter = Color("B7FD98"),
	xp_bar_potential = Color("888800"),
	durability_bg = Color("000000"),
	durability_high = Color("00ff00"),
	durability_medium = Color("ddff00"),
	durability_low = Color("ff7700"),
	durability_empty = Color("ff0000")
}

MinecraftHUD._fonts = {
	minecraft = "fonts/minecraftia_outline",
	minecraft_outline = "fonts/minecraftia_outline"
}

MinecraftHUD._textures = {
	atlas = {
		path = "guis/textures/mchud/hud/minecraft_atlas",
		extension = "texture"
	},
	hotbar = {
		path = "guis/textures/mchud/hud/minecraft_hotbar",
		extension = "texture"
	},
	--[[
	hotbar_selection = {
		--none yet
	},
	bow_icon = {
		--none yet
	},
	--]]
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
	atlas = {
		health_empty_black = {0,0}, --x,y,(optional) size
		health_empty_white = {1,0},
		health_empty_red = {2,0},
		health_heart_full = {3,0},
		health_heart_half = {4,0},
		health_transparent_full = {5,0},
		health_transparent_half = {6,0},
		armor_empty = {0,1},
		armor_half = {1,1},
		armor_full = {2,1},
		hunger_empty_black = {0,2},
		hunger_empty_white = {1,2},
		hunger_empty_red = {2,2},
		hunger_heart_full = {3,2},
		hunger_heart_half = {4,2},
		hunger_transparent_full = {5,2},
		hunger_transparent_half = {6,2}
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

function MinecraftHUD.get_atlas_icon(name)
	local item = (type(name) == "table" and name) or MinecraftHUD._hud_data.atlas[name]
	if item then 
		local x,y,size = unpack(item)
		size = size or MinecraftHUD._hud_data.size
		return {size * x, size * y, size, size}
	end
	return {0,0,size,size}
end

MinecraftHUD.settings = MinecraftHUD.settings or {}
MinecraftHUD.default_settings = MinecraftHUD.default_settings or {
	enabled = true,
	player_hud_scale = 1,
	team_hud_scale = 0.5,
	player_vitals_display_mode = 1, --1: faithful, 2: helpful
	team_vitals_display_mode = 1
}

MinecraftHUD._cache = {
	--store session-specific data
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

function MinecraftHUD:log(a,...)
	if Console then 
		Console:Log("MinecraftHUD: " .. tostring(a),...)
	else
		log("MinecraftHUD: " .. tostring(a),...)
	end
end

function MinecraftHUD:GetPlayerScale()
	return self.settings.player_hud_scale
end

function MinecraftHUD:GetTeammateScale()
	return self.settings.teammate_hud_scale
end

function MinecraftHUD:IsEnabled() --not used
	return self.settings.enabled
end

function MinecraftHUD:GetPlayerVitalsDisplayMode()
	return self.settings.player_vitals_display_mode
end

function MinecraftHUD:GetTeamVitalsDisplayMode()
	return self.settings.team_vitals_display_mode
end


-------------------------------visual HUD setters
function MinecraftHUD:SetExperienceProgress(percent)
	do return end
	local scale = self:GetPlayerScale()
	local w,h = unpack(self._textures.xp_full.size)
	xp_bar_full:set_w(percent * w * scale)
	xp_bar_full:set_texture_rect(0,0,percent * w,h)
	
end

--sets the amount of potential xp gained from 
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
	local w,h = unpack(self._textures.xp_full.size)
	xp_bar_potential:set_w(percent * w * scale)
	xp_bar_potential:set_texture_rect(0,0,percent * w,h)
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
	
	for i = HEALTH_TICKS,1,-1 do 
		local tick = vitals_panel:child("health_tick_" .. i)
		if alive(tick) then 
			local tick_ratio = (i - 1) / HEALTH_TICKS 
			if math.floor(tick_ratio * 10) >= math.floor(current_ratio * 10) then
				if tick_ratio * 10 < math.round(current_ratio * 10) then 
					tick:set_image(self._textures.atlas,unpack(get_icon("health_heart_half")))
				else
					tick:set_image(self._textures.atlas,unpack(get_icon("health_heart_full")))
				end
				tick:show()
			else
--				tick:set_image(self._textures.atlas,unpack(get_icon("health_empty_black")))
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
	
	for i = ARMOR_TICKS,1,-1 do 
		local tick = vitals_panel:child("armor_tick_" .. i)
		if alive(tick) then 
			local tick_ratio = (i - 1) / ARMOR_TICKS 
			if math.floor(tick_ratio * 10) >= math.floor(current_ratio * 10) then
				if tick_ratio * 10 < math.round(current_ratio * 10) then 
					tick:set_image(self._textures.atlas,unpack(get_icon("armor_half")))
				else
					tick:set_image(self._textures.atlas,unpack(get_icon("armor_full")))
				end
			else
				tick:set_image(self._textures.atlas,unpack(get_icon("armor_empty")))
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
	local panel_data = self._cache.teammate_panels[HUDManager.PLAYER_PANEL]
	local teammate_panel = panel_data.panel
	local hotbar_panel = teammate_panel:child("hotbar_panel")
	local item 
	if i == 0 then 
		item = hotbar_panel:child("hotbar_offhand_bg")
	else
		item = hotbar_panel:child("item_" .. tostring(i))
	end
	local done_any = count1 or count2 or bar_progress
	if alive(item) then 
		local counter_bottom = item:child("counter_bottom")
		local counter_top = item:child("counter_top")
		if count1 then 
			counter_bottom:set_text(tostring(count1))
		end
		if count2 then 
			counter_top:set_text(tostring(count2))
		end
		
		local durability_meter = item:child("durability_meter")
		local durability_meter_bg = item:child("durability_meter_bg")
		if bar_progress then 
			local hide_when_full = true
			local bar_color
			local durability_thresholds = self._hud_data.durability_thresholds
			if bar_progress >= durability_thresholds.medium then 
				bar_color = self._color_data.durability_high
			elseif bar_progress >= durability_thresholds.low then 
				bar_color = self._color_data.durability_medium
			elseif bar_progress >= durability_thresholds.empty then 
				bar_color = self._color_data.durability_low
			else
				bar_color = self._color_data.durability_empty
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
		
		local bitmap = item:child("bitmap")
		if icon then
			local texture,texture_rect
			if source == "weapon" then 
				if self._weapon_icons[icon] then 
					texture = self._weapon_icons[icon].path
				else
					self:log("ERROR: No weapon icon found by name " .. tostring(icon))
					return
				end
			elseif source == "atlas" then 
				texture = self._textures.atlas.path
				texture_rect = self.get_atlas_icon(icon)
			end
			
			if texture then 
				done_any = true
				bitmap:set_image(texture,texture_rect and unpack(texture_rect))
				bitmap:set_size(item:size())
				bitmap:show()
			end
		elseif icon == false then
			bitmap:hide()
		end
		item:set_visible(done_any)
	else
		self:log("ERROR: Invalid hotbar index " .. tostring(i))
	end
end

-------------------------------/visual HUD setters
--[[
local panel = MinecraftHUD._cache.teammate_panels[4].panel:child("vitals_panel")
adf = panel:animate(MinecraftHUD._animate_health_bar_wiggle,10,20,64,panel:h() - 36)
return adf

local weapons = {"aa12","legacy","g3","huntsman","hk21","gre_m79","galil","galil","deagle","czech"}
for i,weapon in ipairs(weapons) do 
	MinecraftHUD:LoadWeaponIcon(weapon)
	
	MinecraftHUD:SetHotbarIcon(i,weapon,"weapon",math.random(100),math.random(50),nil)
end

 MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("counter_bottom"):set_font_size(64)
return MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("bitmap"):visible()
MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("bitmap"):set_size(72,72)
local panel = MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("bitmap"):set_image(MinecraftHUD._weapon_icons.ppk.path)

local panel = MinecraftHUD._cache.teammate_panels[4].panel:child("hotbar_panel"):child("item_1"):child("bitmap"):set_image(MinecraftHUD.get_atlas_icon("hunger_empty_black"))

for i = 3, 9,1 do 
	MinecraftHUD:SetHotbarIcon(i,false,nil,"","",false)
end
MinecraftHUD:SetHotbarIcon(2,"aa12","weapon",12,40,false)
MinecraftHUD:SetHotbarIcon(1,"ppk","weapon","",456,0.2)

DB:has(Idstring("texture"),MinecraftHUD._weapon_icons.ppk.path)
--]]
-------------------------------HUD animations
function MinecraftHUD._animate_health_bar_wiggle(vitals_panel,ticks,speed,vertical_amount,y_orig)
	ticks = ticks or MinecraftHUD._hud_data.health_ticks
	speed = speed or 10
	vertical_amount = vertical_amount or 36
	y_orig = y_orig or 0
	local t = 0
	while abutd do 
		local dt = coroutine.yield()
		t = t + dt
		Console:SetTrackerValue("trackerb",tostring(t))
		for i = 1,ticks,-1 do 
			local tick = vitals_panel:child("health_tick_" .. tostring(i))
			if alive(tick) then 
				local tick_bg = vitals_panel:child("health_tick_bg_" .. tostring(i))
				local y_offset = y_orig + (vertical_amount * math.sin((speed * t) + (60 * i)))
				Console:SetTrackerValue("trackerc",tostring(y_offset))
				
				tick:set_y(y_offset)
				tick_bg:set_y(y_offset)
			else
				break
			end
		end
	end
end
function MinecraftHUD._animate_armor_bar_wiggle(vitals_panel,speed,vertical_amount)

end
function MinecraftHUD._animate_stamina_bar_wiggle(vitals_panel,speed,vertical_amount)

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

Hooks:Add("BaseNetworkSessionOnLoadComplete","mchud_basenetworkload",function() --PlayerManager_on_internal_load
	MinecraftHUD:CheckResourcesReady()
end)
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
		if DB:has(texture_ids, path) then 
			--do nothing; icon is already loaded
		else
			self:log("Loaded weapon icon [" .. tostring(id) .. "]")
			BLT.AssetManager:CreateEntry(Idstring(path),texture_ids,asset_path)
			
			managers.dyn_resource:load(texture_ids, Idstring(path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, function() log("Done loading asset " .. tostring(id) .. " " .. tostring(index)) end)
			
		end
	else
		self:log("ERROR: No weapon icon found by id [" .. tostring(id) .. "]!")
	end
end

-------------------------------/asset loading

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

	MenuCallbackHandler.callback_mchud_set_enabled = function(self,item)
		MinecraftHUD.settings.enabled = item:value() == "on"
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

MinecraftHUD:LoadSettings()

--register weapon icons, to be loaded later
local get_files = SystemFS and callback(SystemFS,SystemFS,"list") or file and callback(file,file,"GetFiles")
if get_files then 
	local texture_ids = Idstring("texture")
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
	
	for _,raw_filename in pairs(get_files(assets_path .. icons_path)) do
		local filename,extension = separate_extension(raw_filename)
		if not (filename and extension) then 
			MinecraftHUD:log("ERROR: bad filename when registering custom weapon icons: " .. tostring(raw_filename))
			return
		end
--		MinecraftHUD:log("Registering custom weapon icon for weapon with id: [" .. filename .. "]")
		
		local path = icons_path .. filename
		MinecraftHUD._weapon_icons[filename] = {
			id = filename, --not used but just in case
			path = path,
			asset_path = assets_path .. path .. "." .. extension,
			extension = extension
		}
	end
	
	--unload all here? not sure if textures are unloaded from memory between states
else
	MinecraftHUD:log("ERROR: could not load/register weapon icon pngs!")
end

MinecraftHUD:CheckResourcesAdded()