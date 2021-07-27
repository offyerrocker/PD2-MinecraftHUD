Hooks:PostHook(HUDHitConfirm,"init","mchud_hudhitconfirm_init",function(self,hud)
	local panel = hud.panel
	local mchud_crosshair = panel:panel({
		name = "mchud_crosshair",
	})
	self._mchud_crosshair = mchud_crosshair
	MinecraftHUD._cache.crosshair_panel = mchud_crosshair
	local texture,texture_rect = MinecraftHUD.get_atlas_icon("crosshair")
	local crosshair = mchud_crosshair:bitmap({
		name = "crosshair",
		blend_mode = "normal",
		color = Color.white,
		alpha = 0.75,
		texture = texture,
		texture_rect = texture_rect,
		layer = 11
--		w = 64,
--		h = 64
	})
	crosshair:set_center(mchud_crosshair:w()/2,mchud_crosshair:h()/2)
	
	
	local texture,texture_rect = MinecraftHUD.get_atlas_icon("attack_indicator_crosshair_empty")
	local crosshair_crit_indicator_empty = mchud_crosshair:bitmap({
		name = "crosshair_crit_indicator_empty",
		alpha = 2/3,
		texture = texture,
		texture_rect = texture_rect,
		layer = 10,
		visible = false
	})
	
	local texture,texture_rect = MinecraftHUD.get_atlas_icon("attack_indicator_crosshair_full")
	local crosshair_crit_indicator_full = mchud_crosshair:bitmap({
		name = "crosshair_crit_indicator_full",
		alpha = 1,
		texture = texture,
		texture_rect = texture_rect,
		layer = 13,
		visible = false
	})
	
	local crit_x = (mchud_crosshair:w() - crosshair_crit_indicator_empty:w()) / 2 
	local crit_y = crosshair:bottom()
	
	crosshair_crit_indicator_empty:set_position(crit_x,crit_y)
	crosshair_crit_indicator_full:set_position(crit_x,crit_y)
end)