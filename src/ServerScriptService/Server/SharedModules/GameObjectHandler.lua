local GameData = nil
local Enemies = {}

-----

local module = {}

function module:GetEnemies()
	return Enemies
end
function module:DeleteEnemies()
	Enemies = {}
end

function module:CreateGameData()
	GameData = {
		TimeElapsed		= 0,
		HeroMode		= false,
		EveryoneMustDie = false,
		TeamHP			= 500,
		MAXTeamHP		= 500,
		BaseGold		= 0,
		BaseXP	 		= 0, 
		CurrentWave 	= 0,
		CurrentMap	 	= nil,
		CurrentRunLogic = nil,
		DungeonLevel 	= 0,
		MaxEnemies		= 0,
		MaxEnemiesCAP	= 50,
		EnemiesToSpawn	= 0,
		LootsFound 		= 0, 
		EnemiesDefeated	= 0,
		InUltimate		= false,
		MapCompleted	= false,
		Objectives 		= {},
		DungeonMsg		= "",
		EnemiesFound	= {}
	}
end

function module:GameData()
	return GameData
end

function module:DeleteGameData()
	GameData = nil
end

return module
