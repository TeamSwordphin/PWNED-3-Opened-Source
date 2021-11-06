local module = {PLAYER_LEVEL_CAP = 100}

local PlayerStats = {}
local CombatStates = {}

local function findValue(tab, val, indexFind)
	for i,v in pairs(tab) do
		if indexFind then
			if i == val then return true end
		end
		if v == val then return true end
	end return false
end

function module:FetchPlayerStats()
	return PlayerStats
end

function module:GetPlayerStat(id)
	if PlayerStats[id] then
		return PlayerStats[id].Data
	end
end

function module:GetPlayerProfile(id)
	return PlayerStats[id]
end

function module:UpdatePlayerStat(id, Object) --- should be used sparingly
	if id ~= nil then
		PlayerStats[id] = Object
	end
end

function module:RemovePlayerStat(id)
	if PlayerStats[id] then
		PlayerStats[id] = nil
	end
end

----------------------

function module:FetchCombatStates()
	return CombatStates
end

function module:UpdateStaleAttack(id, AnimID)
	if CombatStates[id] then
		if os.time() - CombatStates[id].StaleCooldown >= 2 then
			CombatStates[id].StaleCooldown = os.time()
			if CombatStates[id].StaleStep > 10 then
				CombatStates[id].StaleStep = 1
			end
			CombatStates[id].StaleAttacks[CombatStates[id].StaleStep] = AnimID
			CombatStates[id].StaleStep = CombatStates[id].StaleStep + 1
		end
	end
end

function module:GetStaleCount(id, AnimID)
	if CombatStates[id] then
		local Count = 0
		for _, Attacks in ipairs(CombatStates[id].StaleAttacks) do
			if Attacks == AnimID then
				Count = Count + 1
			end
		end
		return Count
	end
end 

function module:UpdateCombatState(id, Object)
	if id ~= nil and id ~= 0 then
		if Object and CombatStates[id] ~= nil then
			CombatStates[id] = Object
		elseif CombatStates[id] == nil then
			local Player = game.Players:GetPlayerByUserId(id)
			CombatStates[id] = {
				ActiveCharacterProfile = nil,
				Name = Player.Name,
				Redeeming = false,
				HoursPlaying = os.time(), 
				CharChange = os.time(), 
				TPCD = 0, GuildCD = 0, 
				GuildAccept = "", 
				Character = nil, 
				LastSave = 0, 
				GemSwap = tick(), 
				MailboxSwap = os.time(), 
				Ready = false,
				LastAnim = nil, 
				UltimateCounter = 0, 
				ComboCount = 0, 
				ComboTimer = 0, 
				Dodging = false, 
				Blocking = false, 
				Ultimate = false,
				StaleStep = 1,
				StaleAttacks = {},
				ParryAmount = 0, --- 0.5-(PARRIESAMOUNT*.09)
				RecentlyParried = 0,
				StaleCooldown = 0,
				AttackOrder = {},
				ChainCooldowns = nil,
				MaxBlockHP = 0, RecentlyBlocked = 0, Fatigued = 0, CryFormCD = 0, CryPoints = 50, CryForm = false, StatusEffects = {}, CriticalWounds = 0, MAXHP = 0, DPS = 0, HighestCombo = 0, DodgedAttacks = 0, DamageTaken = 0, SupportSkills = 0, Revivals = 0, LastAim = nil, AttackSpeed = 1, ConsumedDamage = 0, IsSpecial = false, SpecialBar = 0}
		end
	end
end

function module:GetCombatState(id)
	if findValue(CombatStates, id, true) then
		return CombatStates[id]
	end
end

function module:RemoveCombatState(id)
	if findValue(CombatStates, id, true) then
		CombatStates[id] = nil
	end
end

return module
