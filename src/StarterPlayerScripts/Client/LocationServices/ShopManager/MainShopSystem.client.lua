-- << Services >> --
local MarketplaceService	= game:GetService("MarketplaceService")
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")
local TweenService			= game:GetService("TweenService")
local Lighting				= game:GetService("Lighting")
local RunService			= game:GetService("RunService")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")

-- << Modules >> --
local Socket 		= require(MODULES.socket)
local StoryTeller 	= require(MODULES.StoryTeller)
local MusicPlayer	= require(MODULES.MusicPlayer)
local DataValues 	= require(CLIENT.DataValues)
local Hint		  	= require(CLIENT.UIEffects.Hint)
local showS			= require(CLIENT.UIEffects.NumbersFlair)
local Animate 		= require(CLIENT.UIEffects.AnimateSpriteSheet)
local Dialogue 		= require(CLIENT.DialogueSystem.AutomatedDialogue)
local FS 		  	= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local Numbers	= DataValues.Numbers
local Ticks		= DataValues.Ticks
local Camera	= workspace.Camera
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid	= Character:WaitForChild("Humanoid")
local Blur		= Lighting:WaitForChild("Blur")
local Shop 		= GUI.ShopGUI
local Stocks 	= Shop.Stocks
local Sidebar 	= Shop.Sidebar
local Topbar 	= Shop.TopBar
local OldCamCF 	= nil
local Rotating 	= nil
local G, R, T
local Equip
local DevProductCooldown 	= 0
local DevProductPurchases	= 0
local MenuButtons 			= Sidebar.StartButtons:GetChildren()


---------------------------------
function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

PLAYER.CharacterAdded:Connect(OnRespawn)

Sidebar.StartButtons.Leave.MouseButton1Down:Connect(function()
	Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
	Character.PrimaryPart.Anchored = false
	Shop.Enabled = false
	GUI.Main.Enabled = true
end)

Sidebar.PurchaseInfo.Leave.MouseButton1Down:Connect(function()
	if script:FindFirstChild("Event") then
		script.Event:Fire()
	end
	if workspace:FindFirstChild("Shop") then
		workspace.Shop.Preview.SurfaceGui.ImageLabel.Image = ""
	end
	TweenService:Create(Blur, TweenInfo.new(.5), {Size = 24}):Play()
	if Rotating then
		Rotating:Disconnect()
		Rotating = nil
	end
	if OldCamCF then
		TweenService:Create(Camera, TweenInfo.new(.5), {CFrame = OldCamCF}):Play()
	end
	TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(-.2, 0, 0, 0)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0, 0, -0.11, 0)}):Play()
	wait(.5)
	Stocks.Visible = true
	DataValues.CameraEnabled = true
	Topbar.Categories.Visible = true
	Sidebar.StartButtons.Visible = true
	Sidebar.PurchaseInfo.Visible = false
	TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(-0.08, 0, 0, 0)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0, 0, 0, 0)}):Play()
end)

Socket:Listen("DeveloperProductSuccess", function(NewAccInfo, Amnt)
	local OldTears = DataValues.AccInfo.Tears
	DataValues.AccInfo = NewAccInfo
	showS(Topbar.Money.Tears.Price, OldTears, DataValues.AccInfo.Tears, Numbers.duration*.5, Numbers.fps )
	Hint("Thank you for your support! " .. tostring(Amnt).. " Tears have been added to your account!")
end)

local function CreateShopList(ShopItems, Contributors)
	local OldStuff = Stocks:GetChildren()
	for i = 1, #OldStuff do
		if not OldStuff[i]:IsA("UIGridLayout") then
			OldStuff[i]:Destroy()
		end
	end
	workspace.Shop.Preview.PreviewModels:ClearAllChildren()
	if Contributors == nil then
		Stocks.UIGridLayout.CellSize = UDim2.new(0, 225, 0, 225)
		for i = 1, #ShopItems do
			local Item = ShopItems[i]
			if Item.Reveal then
				local Stock = ReplicatedStorage.GUI.NormalGui.NewStock:Clone()
				local Block = Stock.Details
				local PriceUI = Block.Misc.PriceIndicator.Spacer
				Stock.LayoutOrder = (-(Item.GoldPrice + (Item.TearsPrice*100)))
				if Item.PreviewModel then
					local SkinModel = Item.PreviewModel:Clone()
					SkinModel.Parent = Block.ItemImage.ViewportFrame
					local CameraSkin = Instance.new("Camera")
					CameraSkin.CameraType = Enum.CameraType.Scriptable
					CameraSkin.CameraSubject = SkinModel
					local modelCF, size = SkinModel:GetBoundingBox()
					local CF = modelCF * CFrame.new(-size.X, 2, 1)
					CameraSkin.CFrame = CFrame.new(CF.Position, modelCF.Position)
					CameraSkin.Parent = SkinModel
					Block.ItemImage.ViewportFrame.CurrentCamera = CameraSkin
				else
					if typeof(Item.Thumb) == "Instance" then
						if Item.Thumb:IsA("ImageLabel") then
							Block.ItemImage.Image = Item.Thumb.Image
							if Item.Thumb:FindFirstChild("Framerate") then
								FS.spawn(function()
									while Block.ItemImage ~= nil do
										Block.ItemImage.ImageRectOffset = Vector2.new(-Item.Thumb.Width.Value.X,0)
										Block.ItemImage.ImageRectSize = Vector2.new(Item.Thumb.Width.Value.X, Item.Thumb.Width.Value.Y)
										local NumOfSpritesX = Item.Thumb.NumOfSprites.Value.X ~= 0 and Item.Thumb.NumOfSprites.Value.X or 3
										local NumOfSpritesY = Item.Thumb.NumOfSprites.Value.Y ~= 0 and Item.Thumb.NumOfSprites.Value.Y or 9
										Animate(Block.ItemImage, false, NumOfSpritesX, NumOfSpritesY, Item.Thumb.Framerate.Value, 0,0, Item.Thumb.Maxframes.Value)
									end
								end)
							end
						end
					else
						Block.ItemImage.Image = Item.Thumb
					end
				end
				Block.Misc.Outline.ImageColor3 = Item.BorderColor
				Block.Misc.Nam.Title.Text = Item.Name
				if DataValues.AccInfo.Characters[Item.Name] == nil then
					if Item.Available then
						if Item.RobuxPrice then
							Stock.LayoutOrder = Item.RobuxPrice
							PriceUI.Robux.Price.Text = Item.RobuxPrice
							PriceUI.Gold.Visible = false
							PriceUI.Robux.Visible = true
							PriceUI.Tears.Visible = false
							if Item.Type == "GamePass" then
								local success = pcall(function()
									return MarketplaceService:UserOwnsGamePassAsync(PLAYER.UserId, Item.GoldPrice)
								end)
								if success then
									PriceUI.Info.Title.Text = "OWNED"
									PriceUI.Robux.Visible = false
									PriceUI.Info.Visible = true
								end
							end
						else
							PriceUI.Gold.Price.Text = (Item.OnSale ~= 0 and math.floor(Item.GoldPrice * (1 - Item.OnSale)) or Item.GoldPrice)
							PriceUI.Tears.Price.Text = (Item.OnSale ~= 0 and math.floor(Item.TearsPrice * (1 - Item.OnSale)) or Item.TearsPrice)
							PriceUI.Gold.Visible = (Item.GoldPrice > 0 and true or false)
							PriceUI.Tears.Visible = (Item.TearsPrice > 0 and true or false)
							PriceUI.Robux.Visible = false
						end
					else
						PriceUI.Gold.Visible = false
						PriceUI.Robux.Visible = false
						PriceUI.Tears.Visible = false
						PriceUI.Info.Visible = true
					end
				else
					PriceUI.Gold.Visible = false
					PriceUI.Robux.Visible = false
					PriceUI.Tears.Visible = false
					PriceUI.Info.Title.Text = "OWNED"
					PriceUI.Info.Visible = true
				end
				Block.ItemImage.MouseButton1Down:Connect(function()
					if G then
						G:Disconnect()
						G = nil
					end
					if R then
						R:Disconnect()
						R = nil
					end
					if T then
						T:Disconnect()
						T = nil
					end
					if Equip then
						Equip:Disconnect()
						Equip = nil
					end
					workspace.Shop.Preview.PreviewModels:ClearAllChildren()
					if Item.PreviewModel == nil then
						if workspace:FindFirstChild("Shop") then
							workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectOffset = Vector2.new(0, 0)
							workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectSize = Vector2.new(0, 0)
							if typeof(Item.Thumb) == "Instance" then
								if Item.Thumb:IsA("ImageLabel") then
									workspace.Shop.Preview.SurfaceGui.ImageLabel.Image = Item.Thumb.Image
									if Item.Thumb:FindFirstChild("Framerate") then
										FS.spawn(function()
											local Continue = true
											local Bindable = Instance.new("BindableEvent", script)
											Bindable.Event:Connect(function()
												Continue = false
												Bindable:Destroy()
											end)
											while Continue do
												workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectOffset = Vector2.new(-Item.Thumb.Width.Value.X,0)
												workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectSize = Vector2.new(Item.Thumb.Width.Value.X, Item.Thumb.Width.Value.Y)
												local NumOfSpritesX = Item.Thumb.NumOfSprites.Value.X ~= 0 and Item.Thumb.NumOfSprites.Value.X or 3
												local NumOfSpritesY = Item.Thumb.NumOfSprites.Value.Y ~= 0 and Item.Thumb.NumOfSprites.Value.Y or 9
												Animate(workspace.Shop.Preview.SurfaceGui.ImageLabel, false, NumOfSpritesX, NumOfSpritesY, Item.Thumb.Framerate.Value, 0,0, Item.Thumb.Maxframes.Value)
											end
											workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectOffset = Vector2.new(0, 0)
											workspace.Shop.Preview.SurfaceGui.ImageLabel.ImageRectSize = Vector2.new(0, 0)
										end)
									end
								end
							else
								workspace.Shop.Preview.SurfaceGui.ImageLabel.Image = Item.Thumb
							end
						end
					else
						local Preview = Item.PreviewModel:Clone()
						Preview.Parent = workspace.Shop.Preview.PreviewModels

						if Item.Type == "Pet" then
							Preview.PrimaryPart.Anchored = true
						end
					end
					Stocks.Visible = false
					TweenService:Create(Blur, TweenInfo.new(.5), {Size = 0}):Play()
					DataValues.CameraEnabled = false
					OldCamCF = Camera.CFrame
					TweenService:Create(Camera, TweenInfo.new(.5), {CFrame = CFrame.new(workspace.Shop.Preview.Position+((workspace.Shop.Preview.CFrame.LookVector.unit)*14), workspace.Shop.Preview.Position)}):Play()
					TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(-.2, 0, 0, 0)}):Play()
					TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0, 0, -0.11, 0)}):Play()
					wait(.5)
					Sidebar.PurchaseInfo.Info.Info.Text = Item.Name.. "\n\n" ..Item.Description
					Sidebar.PurchaseInfo.Equip.Visible = false
					
					Equip = Sidebar.PurchaseInfo.Equip.MouseButton1Down:Connect(function()
						if Item.Type == "Class" then
							if DataValues.AccInfo.CurrentClass == Item.Name then
								Hint("You are currently this character already!")
							else
								local Confirmation, Timer = Socket:Request("Shop", "Equip", {Item.Name})
								if typeof(Confirmation) == "table" then
									DataValues.AccInfo = Confirmation
									Hint("Successfully changed character! Leave the shop to see changes.")
								elseif Confirmation == "CD" then
									Hint("You're switching characters too fast! Please wait another " ..Timer.. " seconds.")
								else
									Hint(Confirmation)
								end
							end
						end
					end)
					
					local function BuyItem(Mode)
						if os.time() - Ticks.BuyCooldown >= 1 then
							Ticks.BuyCooldown = os.time()
							local Confirmation, Msg = Socket:Request("Shop", Mode, {Item.Name})
							if typeof(Confirmation) == "table" then
								DataValues.AccInfo = Confirmation
								Topbar.Money.Gold.Price.Text = DataValues.AccInfo.Gold
								Topbar.Money.Tears.Price.Text = DataValues.AccInfo.Tears
								if Item.Type == "Class" then
									Sidebar.PurchaseInfo.Robux.Visible = false
									Sidebar.PurchaseInfo.Gold.Visible  = false
									Sidebar.PurchaseInfo.Tears.Visible = false
									Sidebar.PurchaseInfo.Equip.Visible = true
									PriceUI.Gold.Visible = false
									PriceUI.Robux.Visible = false
									PriceUI.Tears.Visible = false
									PriceUI.Info.Title.Text = "OWNED"
									PriceUI.Info.Visible = true
									Hint("Purchased (" ..Item.Name.. ") successfully! Can be equipped on your left.")
								else
									Hint(Msg)
								end
							else
								Hint(Confirmation)
								if Mode == "BuyWGold" then
									Topbar.Money.Gold.Price.TextColor3 = Color3.fromRGB(255, 56, 56)
									TweenService:Create(Topbar.Money.Gold.Price, TweenInfo.new(.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
								else
									Topbar.Money.Tears.Price.TextColor3 = Color3.fromRGB(255, 56, 56)
									TweenService:Create(Topbar.Money.Tears.Price, TweenInfo.new(.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
								end
							end
						else
							Hint("You are going too fast!")
						end
					end
					
					if DataValues.AccInfo.Characters[Item.Name] == nil then
						if Item.RobuxPrice ~= nil then
							R = Sidebar.PurchaseInfo.Robux.MouseButton1Down:Connect(function()
								if Item.Type == "GamePass" then
									local success = pcall(function()
										return MarketplaceService:UserOwnsGamePassAsync(PLAYER.UserId, Item.GoldPrice)
									end)
									if success then
										Hint("You already own this game pass!")
									else
										MarketplaceService:PromptGamePassPurchase(PLAYER, Item.GoldPrice)
									end
								elseif Item.Type == "Tears" then
									local CD = os.time() - DevProductCooldown
									if CD >= 60 then
										DevProductCooldown = os.time()
										DevProductPurchases = 0
									end
									if DevProductPurchases <= 4 then
										DevProductPurchases = DevProductPurchases + 1
										MarketplaceService:PromptProductPurchase(PLAYER, Item.GoldPrice)
									else
										Hint("Please wait " ..math.floor(60 - CD).. " seconds before buying another Developer Product!")
									end
								end
							end)
							Sidebar.PurchaseInfo.Robux.Currency.Price.Text = Item.RobuxPrice
							Sidebar.PurchaseInfo.Robux.Visible = true
							Sidebar.PurchaseInfo.Gold.Visible  = false
							Sidebar.PurchaseInfo.Tears.Visible = false
						else
							if Item.GoldPrice > 0 then
								G = Sidebar.PurchaseInfo.Gold.MouseButton1Down:Connect(function()
									BuyItem("BuyWGold")
								end)
							end
							if Item.TearsPrice > 0 then
								T = Sidebar.PurchaseInfo.Tears.MouseButton1Down:Connect(function()
									BuyItem("BuyWTears")
								end)
							end
							Sidebar.PurchaseInfo.Gold.Currency.Price.Text = (Item.OnSale ~= 0 and math.floor(Item.GoldPrice * (1 - Item.OnSale)) or Item.GoldPrice)
							Sidebar.PurchaseInfo.Tears.Currency.Price.Text = (Item.OnSale ~= 0 and math.floor(Item.TearsPrice * (1 - Item.OnSale)) or Item.TearsPrice)
							Sidebar.PurchaseInfo.Gold.Visible = (Item.GoldPrice > 0 and true or false)
							Sidebar.PurchaseInfo.Tears.Visible = (Item.TearsPrice > 0 and true or false)
							Sidebar.PurchaseInfo.Robux.Visible = false
						end
					else
						Sidebar.PurchaseInfo.Robux.Visible = false
						Sidebar.PurchaseInfo.Gold.Visible  = false
						Sidebar.PurchaseInfo.Tears.Visible = false
						Sidebar.PurchaseInfo.Equip.Visible = true
					end
					Topbar.Categories.Visible = false
					Sidebar.StartButtons.Visible = false
					Sidebar.PurchaseInfo.Visible = true
					TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(0, 0, 0, 0)}):Play()
					TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0, 0, 0, 0)}):Play()
					if Item.PreviewModel then
						local rotationValue = 90
						Rotating = RunService.RenderStepped:Connect(function()
							local rotatedCF = CFrame.Angles(0, math.rad(rotationValue), 0)
							rotatedCF = CFrame.new(workspace.Shop.Preview.Position) * rotatedCF
							TweenService:Create(Camera, TweenInfo.new(.05, Enum.EasingStyle.Linear), {CFrame = rotatedCF:ToWorldSpace(CFrame.new(Vector3.new(0, 0, 14)))}):Play()
							rotationValue += 0.3
						end)
					end
					
					if not Item.Available then
						Sidebar.PurchaseInfo.Robux.Visible = false
						Sidebar.PurchaseInfo.Gold.Visible  = false
						Sidebar.PurchaseInfo.Tears.Visible = false
					end
				end)
				Stock.Parent = Stocks
			end
		end
	else
		Stocks.UIGridLayout.CellSize = UDim2.new(1, 0, 0, 70)
		local Date = os.date("*t")
		local Durp = ReplicatedStorage.GUI.NormalGui.Durp:Clone()
		Durp.Durp.Text = "This month's top 50 supporters! (Resets in: ".. tostring(31-Date.day).. " days) [Updates every few mins]"
		Durp.LayoutOrder = -1
		Durp.Parent = Stocks
		if ShopItems then
			local StartRank = 1
			local GettingHighScore = true
			for _, entry in pairs(ShopItems) do
				local PlayerID = tonumber(entry.key)
				local PlayerName = nil
				local success, errormsg = pcall(function()
					PlayerName = Players:GetNameFromUserIdAsync(PlayerID)
				end)
				if success then
					if GettingHighScore == false then
						break
					else
						local User = ReplicatedStorage.GUI.NormalGui.User:Clone()
						User.Usering.Ind.Spacer.Namer.Price.Text = StartRank.. ". " ..PlayerName
						User.Usering.Ind.Spacer.Tears.Price.Text = entry.value
						User.LayoutOrder = StartRank
						User.Parent = Stocks
						StartRank = StartRank + 1
					end
				else
					Hint(errormsg)
				end
			end
		end
	end
	Stocks.CanvasPosition = Vector2.new(0,0)
	Stocks.CanvasSize = UDim2.new(0, 0, 0, Stocks.UIGridLayout.AbsoluteContentSize.Y)
end

local TopbarContents = Topbar.Categories:GetChildren()

for v = 1, #TopbarContents do
	if TopbarContents[v]:IsA("Frame") then
		local Tabs = TopbarContents[v]:GetChildren()
		for i = 1, #Tabs do
			local Tab = Tabs[i]
			if Tab:IsA("TextButton") then
				Tab.MouseButton1Down:Connect(function()
					local ShopItems = Socket:Request("Shop", "Category", {Tab.Parent.MenuType.Value, Tab.TabType.Value})
					if Tab.Parent.MenuType.Value == "Characters" then
						DataValues.AccInfo = Socket:Request("getAccountInfo")
					end
					CreateShopList(ShopItems, Tab.TabType.Value == "TopContributors" and true or nil)
				end)
			end
		end
	end
end

for i = 1, #MenuButtons do
	local Button = MenuButtons[i]
	if Topbar.Categories:FindFirstChild(Button.Name) then
		local Category = Topbar.Categories[Button.Name]
		Category:GetPropertyChangedSignal("Visible"):Connect(function()
			if Category.Visible then
				local ShopItems = Socket:Request("Shop", "Category", {Category.MenuType.Value, Category.Tab1.TabType.Value})
				if Category.MenuType.Value == "Characters" then
					DataValues.AccInfo = Socket:Request("getAccountInfo")
					FS.spawn(function()
						if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, "ShopkeeperCharacterHint") then
							Socket:Emit("Story", "ShopkeeperCharacterHint")
							table.insert(DataValues.AccInfo.StoryProgression, "ShopkeeperCharacterHint")
							wait(3)
							Dialogue("If you find any memory modules out there, I can unlock them for you.", "Shopkeeper")
							wait(3)
							Dialogue("... For a price of course.", "Shopkeeper")
						end
					end)
				end
				CreateShopList(ShopItems)
				if DataValues.ControllerType ~= "Touch" then
					Stocks.UIGridLayout.CellSize = UDim2.new(0, 225, 0, 225)
				end
				Stocks.Visible = true
			end
		end)
		Button.MouseButton1Down:Connect(function()
			for v = 1, #TopbarContents do
				if TopbarContents[v]:IsA("Frame") then
					TopbarContents[v].Visible = false
				end
			end
			Category.Visible = true
			Topbar.Visible = true
			TweenService:Create(Blur, TweenInfo.new(.25), {Size = 24}):Play()
			TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0,0,0,0)}):Play()
			TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(-0.08,0,0,0)}):Play()
		end)
	end
end

Shop:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Shop.Enabled then
		MusicPlayer:Overwrite(ReplicatedStorage.Sounds.Music.ShopMusic)

		if workspace:FindFirstChild("Shop") then
			workspace.Shop.Preview.SurfaceGui.ImageLabel.Image = ""
		end
		Topbar.Money.Gold.Price.Text = DataValues.AccInfo.Gold
		Topbar.Money.Tears.Price.Text = DataValues.AccInfo.Tears
		OldCamCF = nil
		GUI.Main.Enabled = false
		Sidebar.StartButtons.Visible = true
		Sidebar.PurchaseInfo.Visible = false
		Topbar.Visible = false
		Topbar.Categories.Visible = true
		Stocks.Visible = false
		Topbar.Position = UDim2.new(0, 0, -0.11, 0)
		Sidebar.Position = UDim2.new(-0.08, 0, 0, 0)
		
		for v = 1, #TopbarContents do
			if TopbarContents[v]:IsA("Frame") then
				TopbarContents[v].Visible = false
			end
		end
		Topbar.Categories["Characters"].Visible = true
		Topbar.Visible = true
		TweenService:Create(Blur, TweenInfo.new(.25), {Size = 24}):Play()
		TweenService:Create(Topbar, TweenInfo.new(.25), {Position = UDim2.new(0,0,0,0)}):Play()
		TweenService:Create(Sidebar, TweenInfo.new(.25), {Position = UDim2.new(-0.08,0,0,0)}):Play()
	else
		MusicPlayer:StopOverwrite(ReplicatedStorage.Sounds.Music.ShopMusic)
		TweenService:Create(Blur, TweenInfo.new(.25), {Size = 0}):Play()
	end
end)