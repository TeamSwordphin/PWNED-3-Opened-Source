local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Modules = script.Parent.Parent
local Stats = require(Modules.PlayerStatsObserver)
local WeaponCraft = require(Modules.CharacterManagement["WeaponCrafting"])
local LootInfo = require(Modules.CharacterManagement.LootInfo)

function module:FindGemstone(id, DesiredName)
	if id then
		local Stat = Stats:GetPlayerStat(id)
		if Stat then
			local CurrentClass = Stat.Characters[Stat.CurrentClass]
			
			if (CurrentClass.Gemstone1 ~= nil and LootInfo:GetLootFromID(true, CurrentClass.Gemstone1.ID).Name == DesiredName) then
				return CurrentClass.Gemstone1
			elseif (CurrentClass.Gemstone2 ~= nil and LootInfo:GetLootFromID(true, CurrentClass.Gemstone2.ID).Name == DesiredName) then
				return CurrentClass.Gemstone2
			elseif (CurrentClass.Gemstone3 ~= nil and LootInfo:GetLootFromID(true, CurrentClass.Gemstone3.ID).Name == DesiredName) then
				return CurrentClass.Gemstone3
			end
		end
	end
	return nil
end

function module:FindWeaponEffect(id, EnchantName)
	if id then
		local Stat = Stats:GetPlayerStat(id)
		if Stats then
			local CurrentClass = Stat.Characters[Stat.CurrentClass]
			for _,Skill in ipairs(CurrentClass.CurrentWeapon.Skls) do
				local Fetched = WeaponCraft:GetSkillFromID(Skill.I)
				if Fetched then
					if Fetched.Name == EnchantName then
						return Skill
					end
				end
			end
			for _,Skill in ipairs(CurrentClass.CurrentTrophy.Skls) do
				local Fetched = WeaponCraft:GetSkillFromID(Skill.I)
				if Fetched then
					if Fetched.Name == EnchantName then
						return Skill
					end
				end
			end
		end
	end
	return nil
end

function module:CreateEffect(Name, Duration, char, obj, DontShow)
	local Show = DontShow and DontShow or false
	local Effect = {}
	Effect.Name = Name or "nil"
	Effect.Object = nil
	Effect.Misc = obj
	Effect.TimeStamp = tick()
	Effect.Duration = Duration or 0

	if Effect.Duration > 0 and not Show then
		Effect.Object = ReplicatedStorage.GUI.NormalGui.Effect:Clone()
		Effect.Object.Namer.Text = Effect.Name
		Effect.Object.Parent = char.HumanoidRootPart.StatusEffects.Effects
		Debris:AddItem(Effect.Object, Effect.Duration+.2)
		TweenService:Create(Effect.Object.HPBar.Bar, TweenInfo.new(Duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(0,0,.7,0)}):Play()
	end	
	return Effect
end

function module:FindEffect(Name, id, removeAllSkill)
	if id then
		local ReturnEffect = nil
		local State = Stats:GetCombatState(id)
		for i,Effect in ipairs(State.StatusEffects) do
			if Effect.Name == Name then
				ReturnEffect = Effect
				if removeAllSkill then
					table.remove(State.StatusEffects, i)
				end
			end
		end
		if removeAllSkill then
			Stats:UpdateCombatState(id, State)
			local ply = Players:GetPlayerByUserId(id)
			if ply and ReturnEffect then
				for _, effect in ipairs(ply.Character.HumanoidRootPart.StatusEffects.Effects:GetChildren()) do
					if effect:IsA("Frame") then
						if effect.Namer.Text == ReturnEffect.Name then
							effect:Destroy()
						end
					end
				end
			end
		end
		return ReturnEffect
	end
end

return module
