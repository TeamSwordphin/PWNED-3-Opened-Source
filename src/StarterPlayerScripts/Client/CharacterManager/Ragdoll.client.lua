local YEET_VELOCITY = 10

-------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RagdollHandler = ReplicatedStorage.Scripts.Modules:WaitForChild("RagdollHandler")

local CLIENT = script.Parent.Parent
local MODULES = CLIENT.Parent:WaitForChild("Modules")
local PLAYER = Players.LocalPlayer
local GUI = PLAYER:WaitForChild("PlayerGui")
local NEWMENU = GUI:WaitForChild("DesktopPauseMenu").Base.Mask

local FS = require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local DataValues = require(CLIENT.DataValues)
local Socket = require(MODULES.socket)
local StoryTeller = require(MODULES.StoryTeller)
local BattleModeON = require(script.Parent.RebuildBattleMode)

Socket:Listen("Ragdoll", function(val, pos, yeet)
	if val then
		if not DataValues.bools.ded then
			FS.spawn(function()
				if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, "DiedOnce") then
					table.insert(DataValues.AccInfo.StoryProgression, "DiedOnce")
					local Help = NEWMENU.Parent.OtherUI.LifeForceHelp
					Help.Visible = true
					TweenService:Create(Help.ArrowFrame["arrow_upward"], TweenInfo.new(1), {ImageTransparency = 0}):Play() wait(1)
					TweenService:Create(Help.Instruction, TweenInfo.new(1), {TextTransparency = 0}):Play() wait(7)
					TweenService:Create(Help.Instruction, TweenInfo.new(1), {TextTransparency = 1}):Play() wait(.5)
					TweenService:Create(Help.Instruction2, TweenInfo.new(1), {TextTransparency = 0}):Play() wait(10)
					Help.Visible = false
				end
			end)
			local character = PLAYER.Character
			local humanoid = character.Humanoid
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			character.Animate.Disabled = true
			DataValues.bools.ded = true
			for _,v in pairs(humanoid:GetPlayingAnimationTracks()) do
				v:Stop(0)
			end
			if pos then
				local velocity = yeet and yeet or YEET_VELOCITY
				local dir = (character.PrimaryPart.Position - pos) * velocity
				character.PrimaryPart.Velocity = dir
			end
		end
	else
		DataValues.bools.ded = false
		local character = PLAYER.Character
		local humanoid = character.Humanoid
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		character.Animate.Disabled = false
		DataValues.bools.ded = false
		BattleModeON()
	end
end)

require(RagdollHandler)