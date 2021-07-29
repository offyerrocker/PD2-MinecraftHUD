Hooks:PostHook(HUDTemp,"show_carry_bag","mchud_showlootbag",function(self,carry_id,value)
	MinecraftHUD:SetPlayerCarry(carry_id,value)
end)
Hooks:PostHook(HUDTemp,"hide_carry_bag","mchud_hidelootbag",function(self)
	MinecraftHUD:HidePlayerCarry()
end)

Hooks:PostHook(HUDTemp,"set_stamina_value","mchud_hudtempsetstamina",function(self,amount)
	MinecraftHUD:SetHunger(amount,self._max_stamina)
end)

--Hooks:PostHook(HUDTemp,"set_max_stamina","mchud_hudtempsetmaxstamina",function(self,amount) end)

