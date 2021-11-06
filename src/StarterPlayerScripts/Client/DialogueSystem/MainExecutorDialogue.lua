-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService 		= game:GetService("TweenService")
local Players			= game:GetService("Players")
local Lighting			= game:GetService("Lighting")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")

-- << Modules >> --
local DataValues 	= require(CLIENT.DataValues)
local animateText 	= require(CLIENT.UIEffects.TextScrolling)
local Hint			= require(CLIENT.UIEffects.Hint)

-- << Variables >> --
local bools 	= DataValues.bools
local Numbers	= DataValues.Numbers
local Objs		= DataValues.Objs
local Blur 		= Lighting:WaitForChild("Blur")
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid 	= Character:WaitForChild("Humanoid")


---------------------------
function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

PLAYER.CharacterAdded:Connect(OnRespawn)

return function(Story, DialogueMode)
	local ChatLabel		= GUI.MainDialogue.Dialogue.ChatLabel
	local CurrentLine 	= 1
	local Next 			= nil
	local Answered;
	local Choices		= {}
	local CurrentEmotion = nil
	if DataValues.ControllerType == "Touch" then
		ChatLabel.TextScaled = true
	else
		ChatLabel.TextScaled = false
	end
	ChatLabel.Parent.Visible = true
	ChatLabel.Parent.Visible = true
	if DialogueMode ~= nil then
		GUI.Main.Enabled = false
		GUI.MainDialogue.DialogueChoices.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		GUI.MainDialogue.DialogueChoices.Position = UDim2.new(.05, 0, .1, 0)
		TweenService:Create(GUI.MainDialogue.Background, TweenInfo.new(.1), {BackgroundTransparency = 0.4}):Play()
		TweenService:Create(Lighting.Blur, TweenInfo.new(.1), {Size = 30}):Play()
	else
		GUI.MainDialogue.DialogueChoices.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		GUI.MainDialogue.DialogueChoices.Position = UDim2.new(.05, 0, .4, 36)
	--	ChatLabel.Parent:TweenSizeAndPosition(UDim2.new(0.9,0,.3,0),UDim2.new(.05,0,0.05,0), "Out", "Quad", .5, true) wait(.5)
	end
	ChatLabel.Parent.ClipsDescendants = false
	
	local DialogueGui = GUI.MainDialogue.Dialogue
	DialogueGui.Visible = true
	TweenService:Create(DialogueGui.ImageLabel, TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
	
	while (CurrentLine <= #Story) do
		local CurrentStep = Story[CurrentLine]
		bools.InDialogue = true
		if Next then
			while CurrentStep.Label ~= Next do
				CurrentLine += 1
				CurrentStep = Story[CurrentLine]
			end
			Next = nil
		end
		if Next == nil then
			GUI.MainDialogue.DialogueChoices.Visible = false
			for _, fame in pairs(GUI.MainDialogue.DialogueChoices:GetChildren()) do
				if fame:IsA("Frame") then
					fame:Destroy()
				end
			end
			if CurrentStep.M ~= nil then
				if CurrentEmotion then
					CurrentEmotion.ImageTransparency = .999
				end
				if CurrentStep.Expression ~= nil then
					CurrentEmotion = GUI.MainDialogue.DialoguePortraits.Frame.Expressions[CurrentStep.Expression]
					CurrentEmotion.ImageTransparency = 0
					GUI.MainDialogue.DialoguePortraits.Visible = true
				else
					GUI.MainDialogue.DialoguePortraits.Visible = false
				end
				animateText(true,ChatLabel,CurrentStep.M)		
				
				if CurrentStep.Next ~= nil then
					Next = CurrentStep.Next
				end
				CurrentLine = CurrentLine + 1
			end
			if CurrentStep.Answers ~= nil then
				GUI.MainDialogue.DialogueChoices.Visible = true
				--display the question --CurrentStep.Question
				--display the answers --CurrentStep.Answers
				--choose an anshwer
				Answered = false
				local Answers = #CurrentStep.Answers
				for i = 1, Answers do
					local Answer = CurrentStep.Answers[i]
					local Choice = ReplicatedStorage.GUI.NormalGui.Choice1:Clone()
					Choice.ChatLabel.Text = Answer.A
					Choice.Parent = GUI.MainDialogue.DialogueChoices
					Choices[i] = Choice.ChatLabel.MouseButton1Click:Connect(function()
						if Answer.A == "Show me your wares." then
							Answered = nil
							bools.Skip = true
							CurrentLine = 999
						end
						if Answer.A == "Actually, I changed my mind. Goodbye." then
							Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
							Character.PrimaryPart.Anchored = false
							GUI.ShopGUI.Enabled = false
							Answered = nil
							bools.Skip = true
							CurrentLine = 999
						end
						if Answer.Next ~= nil then
							Next = Answer.Next
							Answered = nil
							bools.Skip = true
						end
					end)
				end
			end
		end
		repeat 
			wait() 
		until bools.Skip and Answered == nil
		bools.Skip = false
		bools.ShowText = 0
	end
	ChatLabel.Parent.ClipsDescendants = false
	for _,fame in pairs(GUI.MainDialogue.DialogueChoices:GetChildren()) do
		if fame:IsA("Frame") then
			fame:Destroy()
		end
	end
	animateText(true,ChatLabel,"")
	Objs.TextObj = nil
	bools.InDialogue = false
	ChatLabel.Parent.ClipsDescendants = true
	TweenService:Create(DialogueGui.ImageLabel, TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	if GUI.ShopGUI.Enabled == false then
		GUI.Main.Enabled = true
		TweenService:Create(Blur, TweenInfo.new(.1), {Size = 0}):Play()
	else
		TweenService:Create(Blur, TweenInfo.new(.25), {Size = 24}):Play()
	end
	TweenService:Create(GUI.MainDialogue.Background, TweenInfo.new(.1), {BackgroundTransparency = 1}):Play()
	GUI.MainDialogue.DialoguePortraits.Frame.Expressions:ClearAllChildren()
	wait(.1)
	ChatLabel.Parent.Visible = false
end
