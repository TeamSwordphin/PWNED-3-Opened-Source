-- << Services >> --
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")
local TweenService		= game:GetService("TweenService")
local CAS				= game:GetService("ContextActionService")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")

-- << Modules >> --
local PlatformButtons 	= require(MODULES.PlatformButtons)
local DataValues 		= require(CLIENT.DataValues)
local FS 				= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

return function(Buttons, TxtMessage, Timer)
	FS.spawn(function()
		local TempLabel;
		if Buttons then
			if DataValues.ControllerType == "Keyboard" then
				TempLabel = PlatformButtons:GetImageLabel(Buttons.Keyboard, "Light", "PC")
			elseif DataValues.ControllerType == "Controller" then
				TempLabel = PlatformButtons:GetImageLabel(Buttons.Controller, "Light", "XboxOne")
			elseif DataValues.ControllerType == "Touch" and Buttons.Touch then
				local button = CAS:GetButton(Buttons.Touch)
				if button then
					TempLabel = button:Clone()
				end
			end
			if TempLabel then
				TempLabel.Active = false
				TempLabel.Visible = true
				TempLabel.Position = UDim2.new(0,0,0,0)
				TempLabel.Size = UDim2.new(1,0,1,0)
				TempLabel.Name = "ImageLabel"
				TempLabel.ImageTransparency = 1
				TempLabel.Parent = GUI.Notification.TutorialFrame.IconFrame
				TweenService:Create(TempLabel, TweenInfo.new(.5), {ImageTransparency = 0}):Play()
			end
		end
		GUI.Notification.TutorialFrame.TextLabel.Text = TxtMessage
		TweenService:Create(GUI.Notification.TutorialFrame.TextLabel, TweenInfo.new(.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
		wait(Timer and Timer or 10)
		if Buttons and TempLabel then
			TweenService:Create(TempLabel, TweenInfo.new(.5), {ImageTransparency = 1}):Play()
		end
		TweenService:Create(GUI.Notification.TutorialFrame.TextLabel, TweenInfo.new(.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		wait(.5)
		GUI.Notification.TutorialFrame.IconFrame:ClearAllChildren()
	end)
end
