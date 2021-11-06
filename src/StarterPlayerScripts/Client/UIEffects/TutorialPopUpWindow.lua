-- << Services >> --
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")

-- << Modules >> --
local DataValues 	= require(CLIENT.DataValues)
local FS 			= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local TutorialScreen = GUI:WaitForChild("TutorialScreen")


------------------------------
TutorialScreen.Close.MouseButton1Down:Connect(function()
	TutorialScreen.Enabled = false
end)

return function(Namer)
	TutorialScreen.Close.Visible = false
	for _,OtherTuts in ipairs(TutorialScreen.Helps:GetChildren()) do
		if OtherTuts:IsA("Frame") or OtherTuts:IsA("ScrollingFrame") then
			OtherTuts.Visible = false
		end
	end
	if TutorialScreen.Helps:FindFirstChild(Namer) then
		if DataValues.ControllerType == "Touch" then
			TutorialScreen.Helps[Namer].Position = UDim2.new(.1,0,.1,0)
			TutorialScreen.Helps[Namer].Size = UDim2.new(.8,0,.65,0)
			TutorialScreen.Close.Position = UDim2.new(.3,0,.85,0)
			TutorialScreen.Close.Size = UDim2.new(.4,0,.1,0)
		end
		TutorialScreen.Helps[Namer].Visible = true
		TutorialScreen.Enabled = true
	end
	FS.spawn(function()
		wait(5)
		TutorialScreen.Close.Visible = true
	end)
end