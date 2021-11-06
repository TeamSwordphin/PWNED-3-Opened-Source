local module = {}

local KDATable = {}
local RedWins = 0
local BlueWins = 0

local InPVP = false

function module:GetScores()
	return RedWins, BlueWins
end

function module:AddScore(TeamName)
	if TeamName == "Red" then
		RedWins = RedWins + 1
	else
		BlueWins = BlueWins + 1
	end
end

function module:Reset()
	InPVP = false
	RedWins = 0
	BlueWins = 0
	for PlayerObject, _ in pairs(KDATable) do
		KDATable[PlayerObject] = nil
	end
end

function module:CreatePVPTags()
	InPVP = true
	for _, Player in ipairs(game.Players:GetPlayers()) do
		local Tag = {
			Kills = 0,
			Deaths = 0,
			DamageDealt = 0
		}
		KDATable[Player] = Tag
	end
end

function module:Add(Player, StatType, ValueToAdd)
	if KDATable[Player] then
		KDATable[Player][StatType] = KDATable[Player][StatType] + ValueToAdd
	end
end

function module:IsPVP()
	return InPVP
end

function module:ReturnKDATable()
	return KDATable
end

function module:ReturnPlayerTable(Player)
	return KDATable[Player]
end

return module
