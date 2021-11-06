local Modules = script.Parent.Parent:WaitForChild("Modules")
local Effects = require(Modules.Effects)
local Socket = require(Modules.socket)

local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

local Player = game.Players.LocalPlayer
local Gui = Player:WaitForChild("PlayerGui")

Socket:Listen("EffectEnabled", function(ClassType, Character)
	Effects.CreateHitEffects(ClassType, Character)
end)

Socket:Listen("SuddenDeath", function(TEXT)
	if not TEXT then
		spawn(function()
			RS.Sounds.SFX.PVP.Overtime.Volume = 0.25
			RS.Sounds.SFX.PVP.Overtime:Play()
			wait(4)
			TweenService:Create(RS.Sounds.SFX.PVP.Overtime, TweenInfo.new(.5), {Volume = 0}):Play()
		end)
	else
		RS.Sounds.SFX.PVP.Finish:Play()
	end
	local SuddenUI = Gui.DesktopPauseMenu.Base.OtherUI.PVP.SuddenDeath
	SuddenUI.Text = TEXT and TEXT or "SUDDEN DEATH"
	SuddenUI.Visible = true
	TweenService:Create(SuddenUI, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0}):Play() wait(TEXT and 2.5 or 1)
	TweenService:Create(SuddenUI, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play() wait(1)
	SuddenUI.Visible = false
end)

Socket:Listen("TeamScores", function(RedScore, BlueScore)
	local UI = Gui.DesktopPauseMenu.Base.OtherUI.PVP.TeamScores
	UI.RedScore.Text = RedScore
	UI.BlueScore.Text = BlueScore
	if Player.TeamColor == Teams.Team1.TeamColor then
		UI.RedScore.LayoutOrder = 0
		UI.BlueScore.LayoutOrder = 2
	else
		UI.RedScore.LayoutOrder = 2
		UI.BlueScore.LayoutOrder = 0
	end
	UI.Visible = true
	TweenService:Create(UI.Dash, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
	TweenService:Create(UI.Dash, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
	TweenService:Create(UI.BlueScore, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
	TweenService:Create(UI.RedScore, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0}):Play() wait(2)
	TweenService:Create(UI.Dash, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(UI.Dash, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(UI.BlueScore, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(UI.RedScore, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play() wait(1)
	UI.Visible = false
end)
