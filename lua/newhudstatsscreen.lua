do return end
--currently just flashes a red screen when you press tab
--since there are no associated informational trackers yet

Hooks:PostHook(HUDStatsScreen,"init","mchud_hudstatsscreen_init",function(self)
	local parent_panel = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel
	self._left:hide()
	self._right:hide()
	self._bottom:hide()
	
	local panel = parent_panel:panel({
		name = "mchud_stats",
		alpha = 1
	})
	local debug_rect = panel:rect({
		name = "debug",
		color = Color.red,
		alpha = 0.5
	})
	MinecraftHUD._cache.stats_panel = panel
	self._mchud_stats_panel = panel
	
	
	--[[
		-mission data
			crimespree:
				mission name from data
				cs level
			normal:
				current day
				number of days
				is stealthable icon
				level name
				difficulty name
				is one down
				payout
				
			all objectives (0+)
			converted enemies
			if stealth:
				pagers used
				pagers total
	
			lobby player info:
				info on players in your lobby
				
			lootbags:
				-mandatory amount
				-secured amount
				-bonus amount
				-secured bags value
				-instant cash
			
			
		-mutators
			list of mutators ig
		-current playing track
		-tracked achievements
	
	--]]
	
end)


local orig_hudstatsscreen_show = HUDStatsScreen.show
function HUDStatsScreen:show(...)
	local full = managers.hud.STATS_SCREEN_FULLSCREEN

	managers.hud:show(full)
	
	if alive(self._mchud_stats_panel) then 
		self._mchud_stats_panel:show()
	end
end

local orig_hudstatsscreen_hide = HUDStatsScreen.hide
function HUDStatsScreen:hide(...)
	if alive(self._mchud_stats_panel) then 
		self._mchud_stats_panel:hide()
	end
end

Hooks:PostHook(HUDStatsScreen,"loot_value_updated","mchud_hudstatsscreen_lootvalueupdated",function(self)

end)
Hooks:PostHook(HUDStatsScreen,"on_ext_inventory_changed","mchud_hudstatsscreen_onextinventorychanged",function(self)

end)

--[[
function HudTrackedAchievement:update_progress(...)
	
end
--]]