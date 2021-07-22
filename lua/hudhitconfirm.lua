Hooks:PostHook(HUDHitConfirm,"init","mchud_hudhitconfirm_init",function(self,hud)
	local panel = hud.panel
	local mchud_crosshair = panel:panel({
		name = "mchud_crosshair",
	})
	self._mchud_crosshair = mchud_crosshair
	MinecraftHUD._cache.crosshair_panel = mchud_crosshair
	local crosshair = mchud_crosshair:bitmap({
		name = "crosshair",
		blend_mode = "sub",
		color = Color.white,
		alpha = 0.5,
		texture = "",
		w = 64,
		h = 64
	})
	crosshair:set_center(mchud_crosshair:w()/2,mchud_crosshair:h()/2)
end)