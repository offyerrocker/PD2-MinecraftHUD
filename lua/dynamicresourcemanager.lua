Hooks:PostHook(DynamicResourceManager,"post_init","mchud_on_dynresourceload",function(self)
	MinecraftHUD:CheckResourcesReady()
end)