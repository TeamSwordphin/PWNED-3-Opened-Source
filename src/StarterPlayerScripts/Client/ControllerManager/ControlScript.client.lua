for _, module in ipairs(script.Parent:GetChildren()) do
	if module:IsA("ModuleScript") then
		require(module)
	end
end