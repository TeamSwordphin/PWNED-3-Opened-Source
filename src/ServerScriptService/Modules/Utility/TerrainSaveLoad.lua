-- Terrain Save & Load
-- Crazyman32
-- January 17, 2015

--[[
	
	How to use:
	
	- Keep this under ServerScriptService or ServerStorage
	- Use from a Script on the server (not LocalScript)
	
	
	Example:
	
		local terrainSaveLoad = require(game.ServerScriptService.TerrainSaveLoad)
		
		-- Save terrain:
		local savedTerrain = terrainSaveLoad:Save(includeWaterProperties)
		
			-- Saves water properties too if "includeWaterProperties" is 'true'
		
		
		-- Load terrain:
		terrainSaveLoad:Load(savedTerrain)
	
--]]



local TerrainSaveLoad = {
	Version = "1.0.3";
}


function TerrainSaveLoad:Save(includeWaterProperties)
	
	local t = game.Workspace.Terrain
	
	-- Copy terrain:
	local tr = t:CopyRegion(t.MaxExtents)
		tr.Name = "SavedTerrain"
		tr.Parent = game.Workspace
	
	-- Save water properties:
	if (includeWaterProperties) then
		local waterProps = Instance.new("Configuration", tr)
		waterProps.Name = "WaterProperties"
		local function SaveProperty(class, name)
			local p = Instance.new(class, waterProps)
			p.Name = name
			xpcall(function()
				p.Value = t[name]
			end, function(err)
				print("Failed to get property: " .. tostring(err))
			end)
		end
		SaveProperty("Color3Value", "WaterColor")
		SaveProperty("NumberValue", "WaterReflectance")
		SaveProperty("NumberValue", "WaterTransparency")
		SaveProperty("NumberValue", "WaterWaveSize")
		SaveProperty("NumberValue", "WaterWaveSpeed")
	end
	
	-- Set as selected:
	game:GetService("Selection"):Set({tr})
	
	-- Return the TerrainRegion copy:
	return tr
	
end



function TerrainSaveLoad:Load(terrainRegion)
	
	-- Ensure 'terrainRegion' is correct:
	assert(typeof(terrainRegion) == "Instance" and terrainRegion:IsA("TerrainRegion"),
		"Load method for TerrainSaveLoad API requires a TerrainRegion object as an argument"
	)
	
	-- Find center position:
	local xPos = -math.floor(terrainRegion.SizeInCells.X * 0.5)
	local yPos = -math.floor(terrainRegion.SizeInCells.Y * 0.5)
	local zPos = -math.floor(terrainRegion.SizeInCells.Z * 0.5)
	local pos = Vector3int16.new(xPos, yPos, zPos)
	
	-- Load water properties:
	local waterProps = terrainRegion:FindFirstChild("WaterProperties")
	if (waterProps) then
		local function LoadProperty(name)
			local obj = waterProps:FindFirstChild(name)
			if (not obj) then return end
			xpcall(function()
				game.Workspace.Terrain[obj.Name] = obj.Value
			end, function(err)
				print("Failed to set property: " .. tostring(err))
			end)
		end
		LoadProperty("WaterColor")
		LoadProperty("WaterReflectance")
		LoadProperty("WaterTransparency")
		LoadProperty("WaterWaveSize")
		LoadProperty("WaterWaveSpeed")
	end
	
	-- Load in the terrain:
	game.Workspace.Terrain:PasteRegion(terrainRegion, pos, true)
	
end



-----------------------------------------------------------------

return TerrainSaveLoad