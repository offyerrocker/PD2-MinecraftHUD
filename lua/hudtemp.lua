Hooks:PostHook(HUDTemp,"show_carry_bag","mchud_showlootbag",function(self,carry_id,value)
	MinecraftHUD:SetPlayerCarry(carry_id,value)
end)
Hooks:PostHook(HUDTemp,"hide_carry_bag","mchud_hidelootbag",function(self)
	MinecraftHUD:HidePlayerCarry()
end)