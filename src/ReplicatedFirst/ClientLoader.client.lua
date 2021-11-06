--- Manages the loading screen
-- @author colbert2677

local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local LoadingGui = script.Parent.LoadingGui
local Container = LoadingGui.Container

local TIPS = {
    "Vestige of Lithe: You can cancel your own attack animations early by dodging! By repositioning yourself every now and then, you can maximize your DPS.",
    "Blocking right before an attack hits will parry them instead. Parrying rewards bonus attack speed, invulnerability, and guaranteed critical strikes.",
    "Keep your combos up! Your base damage will gradually increase as you deal more combos.",
    "Patience is key! Memorize your enemy's attack patterns and see where they open up to a counter attack!",
    "Sometimes a good defense is the best offense! Running away or simply blocking is wise if you need a few moments to breathe.",
    "Powerful bosses can only be fought by opening rare Lore pages.",
    "Found cheaters? By providing evidence against their kind, you may be rewarded for your heroic efforts!",
    "Try playing on mobile or with a controller and see what plays better.",
    "Like reading? Hate reading? Either way, find the Lore pages scattered about the world and open them! They might have a little surprise in them...",
    "Be nice and work as a team! The entire team gets the same amount of XP, Gold and Loot Drops so no need to steal things!",
    "Blocking all the time is not wise as if you run out of stamina, you will be stunned instead leaving you vulnerable!",
    "Play Darwin if you have no friends.",
    "Enemies are dangerous in the world of PWNED, so get some friends to help you out! You will also gain more EXP per additional player in your party.",
    "Leaving in the middle of a dungeon will forfeit all loot drops, EXP, and Gold gains.",
    "Read your abilities!",
    "After chatting with an NPC, try talking to them again! New dialogue options may appear.",
    "When leaving a dungeon, standing on the teleporter button will quicken the countdown."
}

--- Linear interpolation
-- Because I don't want to figure out the math myself.
-- @param a lower value
-- @param b upper value
-- @param t delta value
-- @return a value that is t percent between a and b
local function lerp(a, b, t)
    return a + (b - a) * t
end

--- Modify the chat settings by giving back new settings to use
-- @return a dictionary of chat settings overrides
local function getChatSettings()
    return {
		ShowChannelsBar = true,
		ChatWindowTextSize = 17,
		ChatBarTextSize = 17,
		DefaultFont = Enum.Font.Gotham,
		BackGroundColor = Color3.fromRGB(34, 34, 34),
		DefaultMessageColor = Color3.fromRGB(235, 225, 204),
		ChatBarBoxColor = Color3.fromRGB(255, 235, 224),
		ChatBarTextColor = Color3.fromRGB(34, 34, 34)
	}
end

local function getBubbleChatSettings()
    return {
     --   BackgroundColor3 = Color3.fromRGB(38, 40, 43),
     --   TextColor3 = Color3.fromRGB(172, 172, 172),
    }
end

--- Change transparency of elements according to image background
local function updateElementTransparency()
    local barBelow = Container.BarBelow
    local transparency = Container.BackgroundImage.Transparency

    local tipTextTransparency = lerp(0.4, 1, transparency)

    barBelow.ImageTransparency = transparency
    barBelow.TipTitle.TextTransparency = tipTextTransparency
    barBelow.Tip.TextTransparency = tipTextTransparency
end

--- Initialise the Gui for use
local function init()
    Container.BarBelow.Tip.Text = TIPS[Random.new():NextInteger(1, #TIPS)]
    LoadingGui.Parent = PlayerGui

    local SERVER_STATS = ReplicatedStorage:WaitForChild("SERVER_STATS", 15)
    if SERVER_STATS then
        local PrivateBool = SERVER_STATS:WaitForChild("IsPrivateServer", 15)
        if PrivateBool and PrivateBool.Value then
            Container.BackgroundImage.Image = "rbxassetid://5728002657"
        end
    end

    ContentProvider:PreloadAsync({LoadingGui})
    ReplicatedFirst:RemoveDefaultLoadingScreen()

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    wait(5)

    local fadeOutTween = TweenService:Create(
        Container.BackgroundImage,
        TweenInfo.new(1),
        {ImageTransparency = 1}
    )
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()

    LoadingGui:Destroy()
end

Container.BackgroundImage:GetPropertyChangedSignal("ImageTransparency"):Connect(updateElementTransparency)

Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, getChatSettings)
pcall(function() Chat:SetBubbleChatSettings(getBubbleChatSettings) end)

init()