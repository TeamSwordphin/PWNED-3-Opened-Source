local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local Players 			= game:GetService("Players")

local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")

local FS 		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local Socket	= require(MODULES.socket)
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")


----------------------------

function Hint(msg)
	FS.spawn(function()
		local NewMsg = ReplicatedStorage.GUI.NormalGui.Message:Clone()
		NewMsg.Title.Text = msg
		NewMsg.Parent = GUI.Notification.Frame
		Debris:AddItem(NewMsg, 6)
		TweenService:Create(NewMsg, TweenInfo.new(.5), {BackgroundTransparency = 0.1}):Play()
		TweenService:Create(NewMsg.Bar, TweenInfo.new(.5), {BackgroundTransparency = 0.4}):Play()
		TweenService:Create(NewMsg.Bar, TweenInfo.new(5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, .05, 0)}):Play()
		TweenService:Create(NewMsg.Title, TweenInfo.new(.5), {TextTransparency = 0}):Play()
		wait(5)
		TweenService:Create(NewMsg, TweenInfo.new(.5), {BackgroundTransparency = 1}):Play()
		TweenService:Create(NewMsg.Bar, TweenInfo.new(.5), {BackgroundTransparency = 1}):Play()
		TweenService:Create(NewMsg.Title, TweenInfo.new(.5), {TextTransparency = 1}):Play()
		wait(.5)
		NewMsg.Visible = false
	end)
end

CLIENT.Bindables.Hint.Event:Connect(function(msg)
	Hint(msg)
end)

Socket:Listen("Hint", function(msg)
	Hint(msg)
end)


return Hint
