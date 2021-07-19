--[[
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

--]]

MinecraftHUD = MinecraftHUD or {}
MinecraftHUD._path = MinecraftHUD._path or ModPath
MinecraftHUD._save_path = MinecraftHUD._save_path or SavePath
MinecraftHUD._data_path = MinecraftHUD._data_path or (MinecraftHUD._save_path .. "minecrafthud.json")
MinecraftHUD._assets_path = MinecraftHUD._assets_path or (MinecraftHUD._path .. "assets/")
MinecraftHUD._assets_path = MinecraftHUD._assets_path or (MinecraftHUD._path .. "assets/")
MinecraftHUD._main_menu_path = MinecraftHUD._main_menu_path or (MinecraftHUD._path .. "menu/options.json")
MinecraftHUD._default_localization_file = MinecraftHUD._default_localization_path or "english.json"

MinecraftHUD._fonts = {
	minecraft = "fonts/minecraftia_outline",
	minecraft_outline = "fonts/minecraftia_outline"
}

MinecraftHUD._textures = {
	atlas = {
		file_name = "minecraft_atlas",
		local_path = "guis/textures/mchud/hud"
	},
	hotbar = {
		file_name = "minecraft_hotbar"
	},
	xp_empty = {
		file_name = "xp_empty"
	},
	xp_full = {
		file_name = "xp_full"
	}
}
MinecraftHUD._weapon_icons = {
	--auto-generated
}
--for filename,extension in weapon_icons_folder do
-- if extension == "png" then 
--    load texture
-- end
--end

MinecraftHUD._sounds = {
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
	atlas_name = "textures/minecraft_atlas"
	get_icon = function(name)
		local item = (type(name) == "table" and name) or MinecraftHUD._hud_data.atlas[name]
		if item then 
			local x,y,size = unpack(item)
			size = size or MinecraftHUD._hud_data.size
			return {size * x, size * y, size, size}
		end
		return {0,0,size,size}
	end
}


MinecraftHUD.settings = MinecraftHUD.settings or {}
MinecraftHUD.default_settings = MinecraftHUD.default_settings or {
	enabled = true,
	player_vitals_display_mode = 1, --1: faithful, 2: helpful
	team_vitals_display_mode = 1
}

function MinecraftHUD:IsEnabled()
	return self.settings.enabled
end

function MinecraftHUD:GetPlayerVitalsDisplayMode()
	return self.settings.player_vitals_display_mode
end

function MinecraftHUD:GetTeamVitalsDisplayMode()
	return self.settings.team_vitals_display_mode
end

-------------------------------asset loading

--Registers assets into the game's db so that they can be loaded later 
function MinecraftHUD:CheckResourcesAdded(skip_load)
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	
	for font_id,font_path in pairs(self._fonts) do 
		if DB:has(font_ids, font_path) then 
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
		local asset_path = texture_data.asset_path
		local local_path = texture_data.local_path
		local force_load = texture_data.force_load
		if DB:has(texture_id,asset_path) and not force_load then 
			--do nothing
		else
			if not skip_load then 
				local full_asset_path = self._assets_path .. asset_path
				BLT.AssetManager:CreateEntry(Idstring(asset_path),texture_ids,full_asset_path .. ".texture")
			end
		end
	
	end
	
	
end

--Loads assets into memory so that they can be used in-game
function MinecraftHUD:CheckFontResourcesReady(skip_load,done_loading_cb)
--	self:log("MinecraftHUD Checking font assets...")
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	
	local dyn_pkg = DynamicResourceManager.DYN_RESOURCES_PACKAGE

	if done_loading_cb and done_loading_cb ~= false then 
	
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
	return font_resources_ready
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
	
	MenuCallbackHandler.callback_mchud_menu_close = function(this)
		MinecraftHUD:SaveSettings()
	end
	MenuHelper:LoadFromJsonFile(MinecraftHUD._main_menu_path, MinecraftHUD, MinecraftHUD.settings)
end)

for k,v in pairs(MinecraftHUD.default_settings) do 
	if MinecraftHUD.settings[k] == nil then 
		MinecraftHUD.settings[k] = v
	end
end

MinecraftHUD:LoadSettings()

MinecraftHUD:CheckResourcesAdded()