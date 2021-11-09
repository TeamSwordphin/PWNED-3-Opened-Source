--[[
	
	Skills should have a stamina cost, with it increasing by 5% per skill rank (TBA)
	Light Attack Mastery increases light attack speed
	Dark Souls-like Level Up (level up manually)
	
SOULS LIKE LOOL
		
	Faith Points per 1 FP upgrade:
		HP
			local StartingHP = 5
			local DecayRate = .7
			
			local Total = 200
			
			for level = 1, 10 do
				local formula = StartingHP*(DecayRate)^level
				Total = Total + math.max(1, formula)
			end
			
			print(Total)
			
--]]


local module = {}

function module:GetLevelRates()
	local LevelRates = {
		HP = {
			Start = 190,
			Decay = 0.94,
			Minimum = 15
		},
		ATK = {
			Start = 25,
			Decay = 0.94, --- around 40 - 50 levels till it decays
			Minimum = 5
		},
		DEF = {
			Start = .009,
			Decay = .9,
			Minimum = .0001
		},
		STA = {
			Start = 10,
			Decay = .88,
			Minimum = 3
		},
		CRT = {
			Start = 13,
			Decay = .99,
			Minimum = 2
		},
		CRD = {
			Start = 10,
			Decay = .98,
			Minimum = 1
		}
	}
	return LevelRates
end

function UpdateSkill(id, costs, lvlreq, PercentageIncrease, ActiveSkill, prefix, nam, desc, class, Cooldown, Image, StamCost)
	local Skill = {}
	Skill.AnimId = id == "" and nil or id
	Skill.Cost = costs
	Skill.LevelReq = lvlreq
	Skill.PercentageIncrease = PercentageIncrease ---now a table
	Skill.IsActive = ActiveSkill
	Skill.Name = nam
	Skill.Description = desc
	Skill.Prefix = prefix
	Skill.Class = class or nil
	Skill.Cooldown = Cooldown
	Skill.ImageIcon = Image
	Skill.StaminaCost = StamCost
	return Skill
end

local SkillDataBase = {
		--Passives
	UpdateSkill(nil, 0, 0, {.01, .02, .03, .04, .05, .06, .07, .08, .09, .1--[[Exceed1--]], .11, .12, .13, .14, .15, .16, .17, .18, .19, .2, .21, .22, .23, .24}, false, "% DMG", "Attack Speed Mastery", "Fortifies the user's <font color = '#ffffff'>light attacks</font>, enabling more devastating <font color = '#ff8000'>damage</font> to enemies. \n\nAlso increases Ultimate Damage by <font color = '#ff8000'>20%</font> of this amount and damage-dealing dodge skills by the same amount.\n\n<font color = '#6b7687'><i>Increases Attack Speed by 1.5% per Rank. Attack speed affects all light attacks, active skills, and damaging spells.</i></font>", nil, nil, "rbxassetid://5566455396"),
	UpdateSkill(nil, 250, 10, {.01, .02, .03, .04, .05, .06, .07, .08, .09, .1--[[Exceed1--]], .11, .12, .13, .14, .15, .16, .17, .18, .19, .2, .21, .22, .23, .24}, false, "% DMG", "Skillful Mastery", "Fortifies the user's <font color = '#ffffff'>active skills</font>, enabling more devastating <font color = '#ff8000'>damage</font> to enemies. This also increases Ultimate Damage by <font color = '#ff8000'>35%</font> of this amount.\n\n<font color = '#6b7687'><i>This passive affects all active skills.</i></font>", nil, nil, "rbxassetid://5566456403"),
	UpdateSkill(nil, 250, 10, {-.015, -.03, -.045, -.06, -.075, -.09, -.105, -.12, -.135, -.15--[[Exceed1--]], -.16, -.17, -.18, -.19, -.2, -.21, -.22, -.23, -.24, -.25, -.26, -.27, -.28, -.3}, false, "% STAM", "Stamina Mastery", "Decreases <font color = '#ffffff'>Stamina usage</font>.\n\nAffects light, active skills, dodges, and most actions that consumes stamina.\n\n<font color = '#6b7687'><i>Does not affect the amount of stamina taken via blocking.</i></font>", nil, nil, "rbxassetid://5566456744"),
	UpdateSkill(nil, 10000, 40, {.015, .02, .03, .04, .05, .06, .07, .08, .09, .1--[[Exceed1--]], .11, .12, .13, .14, .15, .16, .17, .18, .19, .2, .21, .22, .23, .24}, false, "% DMG", "Critical Mastery", "Increases the <font color = '#ff8000'>critical damage</font> of all <font color = '#ffffff'>damaging attacks</font>. Additionally, half of this value is converted to <font color = '#ffffff'>bonus Critical Chance</font>, regardless of the enemy's critical defense.\n\n<font color = '#6b7687'><i>Critical Chance applies to all damage dealt.</i></font>", nil, nil, "rbxassetid://5566455757"),
	UpdateSkill(nil, 17500, 50, {.1, .2, .3, .4, .5, .6, .7, .8, .9, 1--[[Exceed1--]], 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4}, false, "% STAM REGEN", "Focus Mastery", "While out of combat, your <font color = '#ffffff'>passive stamina regeneration</font> is increased.", nil, nil, "rbxassetid://5566456015"),
		
		---- Character skills are updated with child module scripts
}

local ClassAutoScales = {}

for _, class in ipairs(script:GetChildren()) do
	if class:IsA("ModuleScript") then
		local classModule = require(class)
		local skillList = classModule:FetchSkillList()
		local AutoScale = classModule:AutoAttackScaling()
		
		ClassAutoScales[class.Name] = AutoScale * 0.01
		
		for _, skill in ipairs(skillList) do
			if skill.Available then
				local NewSkill = UpdateSkill(
					skill.AnimationId, 
					skill.SkillGoldCost,
					skill.SkillLevelReq,
					skill.PercentagePerLevel,
					skill.IsActiveSkill,
					skill.SkillPrefix,
					skill.SkillName,
					skill.SkillDescription,
					class.Name,
					skill.SkillCooldown,
					skill.ImageIcon,
					skill.SkillStamCost
				)
				table.insert(SkillDataBase, NewSkill)
			end
		end
	end
end

function FindSkill(name)
	for i = 1, #SkillDataBase do
		local Skill = SkillDataBase[i]
		if Skill.Name == name then
			return Skill
		end
	end
	return nil
end

function MakeSkill(nam)
	local Skill = {}
	local FoundSkil = FindSkill(nam)
	if FoundSkil and FoundSkil.PercentageIncrease == nil then
		Skill.Rank = 23
		Skill.Unlocked = true
	else
		Skill.Rank = 0
		Skill.Unlocked = false
	end
	Skill.Name = nam
	return Skill
end

function module:GetSkillInfo(name)
	return FindSkill(name)
end

function module:UpdateClassSkills(Skil, Class)
	local Skills = Skil
	
	--- Checking for new skills that we haven't learnt yet
	for v = 1, #SkillDataBase do
		local SkillData = SkillDataBase[v]
		if SkillData.Class == Class or SkillData.Class == nil then
			local DoNotHave = true
			for i = 1, #Skills do
				local Skill = Skills[i]
				if Skill.Name == SkillData.Name then
					DoNotHave = false
				end
			end
			
			if DoNotHave then
				table.insert(Skills, MakeSkill(SkillData.Name))
				print("Player [",Class,"] does not have", SkillData.Name, "Skill | Installing...")
			end
		end
	end

	--- Checking for other class skills
	for _, TruthSkill in ipairs(SkillDataBase) do
		if TruthSkill.Class ~= nil then
			for i, Skill in ipairs(Skills) do
				if Skill.Name == TruthSkill.Name and TruthSkill.Class ~= Class then
					--- Wait how did this player get another class' skills??
					print("Removing irregular skills ".. Skill.Name .. " from " ..Class)
					table.remove(Skills, i)
				end
			end
		end
	end
	
	--- Checking for duplicate class skills
	for i = 1, #Skills do
		local foundSkillName = {}
		for i, Skill in ipairs(Skills) do
			--- Do another round of checks
			if not table.find(foundSkillName, Skill.Name) then
				table.insert(foundSkillName, Skill.Name)
			else
				print(string.format("Removed duplicate skill %s", Skill.Name))
				table.remove(Skills, i)
			end
		end
	end
	
	--- Checking for inactive skills that are no longer in use
	for i, Skill in ipairs(Skills) do
		local Has = false
		for v = 1, #SkillDataBase do
			local SkillData = SkillDataBase[v]
			if Skill.Name == SkillData.Name then
				Has = true
			end
		end
		if not Has then
			print("Player [",Class,"] possesses oudated ", Skill.Name, "Skill | Uninstalling...")
			table.remove(Skills, i )
		end
	end
	
	return Skills
end

function module:FetchAutoScale()
	return ClassAutoScales
end

function module:GetClassInfo(name, typeOf)
	local HP = 0
	local ATK = 0
	local DEF = 0
	local STA = 0
	local CRIT = 0
	local CRITDEF = 0
	local SKILLS = {}
	local function AddPassives()
		table.insert(SKILLS, MakeSkill("Attack Speed Mastery"))
		table.insert(SKILLS, MakeSkill("Skillful Mastery"))
		table.insert(SKILLS, MakeSkill("Stamina Mastery"))
		table.insert(SKILLS, MakeSkill("Critical Mastery"))
		table.insert(SKILLS, MakeSkill("Focus Mastery"))
	end
	if typeOf == "StartStats" then
		if name == "Null" then ---Boilerplate
			HP = 10
			ATK = 0 
			DEF = 0
			STA = 0
			CRIT = 0
			CRITDEF = 0
		else
			HP = 300
			ATK = 20
			DEF = .025
			STA = 200
			CRIT = 10
			CRITDEF = 3
		end
		SKILLS = module:UpdateClassSkills(SKILLS, name)
		AddPassives()
	end
	return {HP, ATK, DEF, STA, CRIT, CRITDEF, SKILLS}
end

return module
