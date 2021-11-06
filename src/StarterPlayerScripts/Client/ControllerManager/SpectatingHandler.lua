-- << Services >> --
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")
local TweenService			= game:GetService("TweenService")
local GuiService			= game:GetService("GuiService")
local ContextActionService 	= game:GetService("ContextActionService")
local Teams                 = game:GetService("Teams")
local Lighting              = game:GetService("Lighting")

-- << Constants >> --
local CLIENT    = script.Parent.Parent
local BINDABLES = CLIENT.Bindables
local MODULES   = CLIENT.Parent.Modules
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local SPECTATE 	= GUI:WaitForChild("SpectatingGUI")

-- << Modules >> --
local DataValues = require(CLIENT.DataValues)
local Socket     = require(MODULES.socket)
local Buttons    = require(MODULES.PlatformButtons)

-- << Variables >> --
local currentPlayer = 0
local currentPlayerList


-------------------------
Socket:Listen("SpectateOn", function()
    ContextActionService:BindActionAtPriority("SpectateClose", selection, false, 2, Enum.KeyCode.ButtonSelect, Enum.KeyCode.Tab)
    ContextActionService:BindActionAtPriority("SpectateLeft", selection, false, 2, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q)
    ContextActionService:BindActionAtPriority("SpectateRight", selection, false, 2, Enum.KeyCode.ButtonR1, Enum.KeyCode.E)
    currentPlayerList = Teams.InGame:GetPlayers()
    currentPlayer = 1
    DataValues.SpectatingTarget = currentPlayerList[currentPlayer]
    DataValues.SpectatingLastUpdatePosition = currentPlayerList[currentPlayer].Character.PrimaryPart.Position

    if workspace.StreamingEnabled then
        PLAYER:RequestStreamAroundAsync(DataValues.SpectatingTarget.Character.PrimaryPart.Position)
    end

    if workspace:FindFirstChild("Map") then
		local mup = workspace.Map
		if Lighting:FindFirstChild("Sky") then
			Lighting.Sky:Destroy()
		end
		if Lighting:FindFirstChild("Atmosphere") then
			Lighting.Atmosphere:Destroy()
		end

		if mup.VisualEffectsSettings:FindFirstChild("Sky") then
			mup.VisualEffectsSettings.Sky:Clone().Parent = Lighting
			Lighting.SunRays.Intensity = mup.VisualEffectsSettings.SunRays.Intensity
			Lighting.SunRays.Spread = mup.VisualEffectsSettings.SunRays.Spread
			Lighting.Bloom.Intensity = mup.VisualEffectsSettings.Bloom.Intensity
			Lighting.Blur.Size = mup.VisualEffectsSettings.Blur.Size
			Lighting.ColorCorrection.Brightness = mup.VisualEffectsSettings.ColorCorrection.Brightness
			Lighting.ColorCorrection.Contrast = mup.VisualEffectsSettings.ColorCorrection.Contrast
			Lighting.ColorCorrection.Saturation = mup.VisualEffectsSettings.ColorCorrection.Saturation
			Lighting.ColorCorrection.TintColor = mup.VisualEffectsSettings.ColorCorrection.TintColor
		end
		for _, setting in ipairs(mup.LightSettings:GetChildren()) do
			Lighting[setting.Name] = setting.Value
		end
    end

    SPECTATE.Bottom.PlayerName.Text = DataValues.SpectatingTarget.Name
    SPECTATE.Bottom.Left.Dir.Text = "Left"
    SPECTATE.Bottom.Right.Dir.Text = "Right"
    SPECTATE.Bottom.Close.Dir.Text = "Close"
    if DataValues.ControllerType == "Keyboard" then
        local TempLabel = Buttons:GetImageLabel("Q", "Light", "PC")
        SPECTATE.Bottom.Left.Image = TempLabel.Image
        SPECTATE.Bottom.Left.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Left.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("E", "Light", "PC")
        SPECTATE.Bottom.Right.Image = TempLabel.Image
        SPECTATE.Bottom.Right.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Right.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("Tab", "Light", "PC")
        SPECTATE.Bottom.Close.Image = TempLabel.Image
        SPECTATE.Bottom.Close.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Close.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
    elseif DataValues.ControllerType == "Controller" then
        local TempLabel = Buttons:GetImageLabel("ButtonL1", "Light", "XboxOne")
        SPECTATE.Bottom.Left.Image = TempLabel.Image
        SPECTATE.Bottom.Left.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Left.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("ButtonR1", "Light", "XboxOne")
        SPECTATE.Bottom.Right.Image = TempLabel.Image
        SPECTATE.Bottom.Right.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Right.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("ButtonSelect", "Light", "XboxOne")
        SPECTATE.Bottom.Close.Image = TempLabel.Image
        SPECTATE.Bottom.Close.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Close.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
    elseif DataValues.ControllerType == "Touch" then
        local TempLabel = Buttons:GetImageLabel("ButtonX", "Light", "PC")
        SPECTATE.Bottom.Left.Image = TempLabel.Image
        SPECTATE.Bottom.Left.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Left.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("ButtonX", "Light", "PC")
        SPECTATE.Bottom.Right.Image = TempLabel.Image
        SPECTATE.Bottom.Right.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Right.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        local TempLabel = Buttons:GetImageLabel("ButtonX", "Light", "PC")
        SPECTATE.Bottom.Close.Image = TempLabel.Image
        SPECTATE.Bottom.Close.ImageRectOffset = TempLabel.ImageRectOffset
        SPECTATE.Bottom.Close.ImageRectSize = TempLabel.ImageRectSize
        TempLabel:Destroy()
        SPECTATE.Bottom.Left.Dir.Text = "Left (Tap)"
        SPECTATE.Bottom.Right.Dir.Text = "Right (Tap)"
        SPECTATE.Bottom.Close.Dir.Text = "Close (Tap)"
    end

    SPECTATE.Enabled = true
end)

SPECTATE:GetPropertyChangedSignal("Enabled"):Connect(function()
    if not SPECTATE.Enabled then
        ContextActionService:UnbindAction("SpectateClose")
        ContextActionService:UnbindAction("SpectateLeft")
        ContextActionService:UnbindAction("SpectateRight")
        DataValues.SpectatingTarget = nil
        currentPlayer = 0
        currentPlayerList = nil
    end
end)

function selection(actionName, inputState, inputObject)
    if not DataValues.SpectatingTarget then return end

    if inputState == Enum.UserInputState.Begin and PLAYER.TeamColor == Teams.Lobby.TeamColor then
        currentPlayerList = Teams.InGame:GetPlayers()
        if actionName == "SpectateClose" then
            SPECTATE.Enabled = false
        else
            if actionName == "SpectateLeft" then
                currentPlayer -= 1
                if currentPlayer < 1 then
                    currentPlayer = #currentPlayerList
                end
            elseif actionName == "SpectateRight" then
                currentPlayer += 1
                if currentPlayer > #currentPlayerList then
                    currentPlayer = 1
                end
            end
            DataValues.SpectatingTarget = currentPlayerList[currentPlayer]
            DataValues.SpectatingLastUpdatePosition = currentPlayerList[currentPlayer].Character.PrimaryPart.Position
            SPECTATE.Bottom.PlayerName.Text = DataValues.SpectatingTarget.Name
            if workspace.StreamingEnabled then
                PLAYER:RequestStreamAroundAsync(DataValues.SpectatingTarget.Character.PrimaryPart.Position)
            end
        end
    end
end

SPECTATE.Bottom.Left.MouseButton1Down:Connect(function()
    selection("SpectateLeft", Enum.UserInputState.Begin)
end)
SPECTATE.Bottom.Right.MouseButton1Down:Connect(function()
    selection("SpectateRight", Enum.UserInputState.Begin)
end)
SPECTATE.Bottom.Close.MouseButton1Down:Connect(function()
    selection("SpectateClose", Enum.UserInputState.Begin)
end)
----------
return nil