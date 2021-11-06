-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")
local Debris			= game:GetService("Debris")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local PLAYERUI 	= GUI:WaitForChild("Main").GameGUI.PlayerUI

-- << Modules >> --
local Socket 			= require(MODULES.socket)
local RainAPI			= require(MODULES.Rain)
local MusicPlayer		= require(MODULES.MusicPlayer)
local DataValues 		= require(CLIENT.DataValues)
local DamageIndicator	= require(CLIENT.UIEffects.DamageIndicator)
local AnimManage		= require(script.Parent.AnimationManager)
local BattleModeON 		= require(script.Parent.RebuildBattleMode)

-- << Variables >> --
local bools		= DataValues.bools
local Options	= DataValues.Options
local Numbers	= DataValues.Numbers
local Objs		= DataValues.Objs
local Ticks		= DataValues.Ticks
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid 	= Character:WaitForChild("Humanoid")

-- << Lua Functions >>--
local Floor = math.floor


----------------------------
function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

PLAYER.CharacterAdded:Connect(OnRespawn)



-- << Sockets >> --
Socket:Listen("ResetAnim", function()
	if Character:FindFirstChild("Animate") then
		Character.Animate:Destroy()
	end
	local Anims = Character.Humanoid:GetPlayingAnimationTracks()
	for _,Anim in next, Anims do
		Anim:Stop()
		Anim:Destroy()
	end
	ReplicatedStorage.Scripts.Animate:Clone().Parent = Character
	bools.Debounce = false
	if Options.RainEffects then
		RainAPI:StartRain()
	end
	if Options.PlayMusic then
		MusicPlayer:Play(ReplicatedStorage.Sounds.Music.LobbyMusic, 4)
	end
	for i = 1, #DataValues.Enemies do
		table.remove(DataValues.Enemies, i)
	end
	DataValues.Enemies = {}
	workspace.Enemies:ClearAllChildren()
	PLAYERUI.Left.BossHPBar.Visible = false
	PLAYERUI.Left.BossHPBar.Bar.Size = UDim2.new(.98,0,.7,0)
	PLAYERUI.Left.BossHPBar.Underbar.Size = UDim2.new(.98,0,.7,0)
	PLAYERUI.Left.BossHPBar.Namer.Text = ""
end)

Socket:Listen("AdjustAtt", function(newAttk, timer)
	if Numbers.Att < 1.95 then
		Numbers.Att += newAttk
		wait(timer)
		Numbers.Att -= newAttk
	end
end)

Socket:Listen("Knockback", function(bool, critw)
	Numbers.CritWounds = critw or Numbers.CritWounds
	if Numbers.CritWounds > 0 then
		local HealthPercentage 				= Numbers.CritWounds/Numbers.OriginalMaxHP
		PLAYERUI.Left.Bars.HPBar.Bar3.Visible = true
		PLAYERUI.Left.Bars.HPBar.Bar3.Size 	= UDim2.new(.98*-(HealthPercentage),0,.7,0)
	end
	--[[
	local AninName = ""
	local db = false
	if bool == true then
		AninName = "X1"
	elseif bool == false then
		AninName = "X2"
	elseif bool == nil then
		AninName = nil
	end
	bools.Stunned = true
	bools.LeftMouseButtonDown = false
	bools.TPS = false
	if AninName ~= nil then
		local AnimTrack2 = Humanoid:LoadAnimation(Character.Animate.attacked[AninName])
		AnimTrack2:Play()
		wait(AnimTrack2.Length)
	end
	bools.Stunned = false
	bools.Debounce = false
	bools.IsBlocking = false
	bools.IsDodging = false
	--]]
end)

Socket:Listen("DamageIndicator", function(val, DamageScope, Target, ComboCount, cT, Ult, Crit, stats, critValue, SpecialBar)
	if SpecialBar ~= nil and bools.IsSpecial then
		Numbers.SpecialBar = SpecialBar
		local Percentage = SpecialBar/100
		PLAYERUI.Left.Bars.ZSpecialBar.Bar.Size = UDim2.new(.98*(Percentage),0,.7,0)
	end
	local HasCrit = Crit or false
	if Ult ~= nil and Numbers.UltimateBar ~= Ult then
		Numbers.UltimateBar = Ult
		--local UltimateGUI = Camera.TopRightStatus.TopRightStatus.TopRightStatus.Frame.UltimateBars
		local UltimateGUI = PLAYERUI.Left.UltimateBars
		UltimateGUI.Number.Text = Floor(Numbers.UltimateBar*.01)
		if Numbers.UltimateBar >= 300 then
			local newNum = Numbers.UltimateBar-300
			UltimateGUI["25Bar"].Bar.Size 		= UDim2.new(.96,0,.5,0)
			UltimateGUI["25Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["50Bar"].Bar.Size 		= UDim2.new(.96,0,.56,0)
			UltimateGUI["50Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["75Bar"].Bar.Size 		= UDim2.new(.96,0,.6,0)
			UltimateGUI["75Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["100Bar"].Bar.Size 		= UDim2.new(-(.94*(newNum*.01)),0,.63,0)
			UltimateGUI["100Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
		elseif Numbers.UltimateBar >= 200 then
			local newNum = Numbers.UltimateBar-200
			UltimateGUI["25Bar"].Bar.Size 		= UDim2.new(.96,0,.5,0)
			UltimateGUI["25Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["50Bar"].Bar.Size 		= UDim2.new(.96,0,.56,0)
			UltimateGUI["50Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["75Bar"].Bar.Size 		= UDim2.new(-(.94*(newNum*.01)),0,.6,0)
			UltimateGUI["75Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["100Bar"].Bar.Size 		= UDim2.new(0,0,.63,0)
			UltimateGUI["100Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
		elseif Numbers.UltimateBar >= 100 then
			local newNum = Numbers.UltimateBar-100
			UltimateGUI["25Bar"].Bar.Size 		= UDim2.new(.96,0,.5,0)
			UltimateGUI["25Bar"].Bar.Position 	= UDim2.new(.02,0,.25,0)
			UltimateGUI["50Bar"].Bar.Size 		= UDim2.new(-(.94*(newNum*.01)),0,.56,0)
			UltimateGUI["50Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["75Bar"].Bar.Size 		= UDim2.new(0,0,.6,0)
			UltimateGUI["75Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["100Bar"].Bar.Size 		= UDim2.new(0,0,.63,0)
			UltimateGUI["100Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
		else
			local newNum = Numbers.UltimateBar
			UltimateGUI["25Bar"].Bar.Size 		= UDim2.new(-(.94*(newNum*.01)),0,.5,0)
			UltimateGUI["25Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["50Bar"].Bar.Size 		= UDim2.new(0,0,.56,0)
			UltimateGUI["50Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["75Bar"].Bar.Size 		= UDim2.new(0,0,.6,0)
			UltimateGUI["75Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
			UltimateGUI["100Bar"].Bar.Size 		= UDim2.new(0,0,.63,0)
			UltimateGUI["100Bar"].Bar.Position 	= UDim2.new(.96,0,.25,0)
		end
	end
	Ticks.Combo_Time = cT
	if DamageScope == "BLOCKED!" or DamageScope == "BLOCK BREAK!" then
		Ticks.StaminaRate = tick()
		--PLAYERUI.Left.Lvl.Text = "LV. " ..Objs.CurrentLevel
		--PLAYERUI.Left.Bars.StaminaBar.NumberValue.Value = ComboCount
		--PLAYERUI.Left.Bars.StaminaBar.Bar.Size = UDim2.new(.98*(ComboCount/Objs.CurrentStaminaRate),0,.7,0)
	end
	if stats ~= nil then
		if Target:FindFirstChild("Stats") == nil then
			ReplicatedStorage.GUI.BillboardGui.Stats:Clone().Parent = Target
		end
		local StatFol = Target.Stats
		StatFol.Lvl.Value = stats.Level
		StatFol.Hp.Value = stats.HP
		StatFol.Atk.Value = stats.Atk
		StatFol.Def.Value = stats.Def
		StatFol.Crit.Value = critValue
	end
	if Target then
		if Numbers.MaxCC > 0  then
			Numbers.MaxCC = Numbers.MaxCC - 1
		end
	end
	DamageIndicator(val, DamageScope, Target, ComboCount, HasCrit)
end)
