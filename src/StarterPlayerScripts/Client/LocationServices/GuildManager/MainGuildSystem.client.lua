local GuildMenu = Gui.Main.Guilds
local Currency = "Gold"
local Transition = false

GuildMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	if GuildMenu.Visible then
		Transition = true
		Currency = "Gold"
		GuildMenu.Buttons.Visible = true
		TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .65, 0), Size = UDi(.9, 0, .07, 0)}):Play()
		DataValues.AccInfo = Socket:Request("getAccountInfo")
		if DataValues.AccInfo.Guild ~= "" then
			GuildMenu.Buttons.CreateGuild.Visible = false
			GuildMenu.Buttons.TeleportQueue.Visible = true
			GuildMenu.Buttons.GuildInfo.Visible = true
		else
			GuildMenu.Buttons.CreateGuild.Visible = true
			GuildMenu.Buttons.TeleportQueue.Visible = false
			GuildMenu.Buttons.GuildInfo.Visible = false
		end
		wait(.5)
		Transition = false
	end
end)

GuildMenu.Back.MouseButton1Down:Connect(function()
	Transition = true
	TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.09, 0, .13, 0), Size = UDi(0, 0, .05, 0)}):Play()
	wait(.25)
	GuildMenu.Back.Visible = false
	GuildMenu.Buttons.Visible = true
	TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .65, 0), Size = UDi(.9, 0, .07, 0)}):Play()
	TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
	TweenService:Create(GuildMenu.TeleportQueue, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
	TweenService:Create(GuildMenu.GuildInfo, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
	wait(.5)
	GuildMenu.CreateGuild.Visible = false
	GuildMenu.TeleportQueue.Visible = false
	GuildMenu.GuildInfo.Visible = false
	Transition = false
end)

local function UpdateCreateUI(Change)
	local C = Change and Change or true
	local CreateMenu = GuildMenu.CreateGuild
	if Currency == "Gold" then
		CreateMenu.Currency.TextColor3 = Color3.fromRGB(188, 195, 113)
		CreateMenu.CurrencyCost.TextColor3 = Color3.fromRGB(188, 195, 113)
	else
		CreateMenu.Currency.TextColor3 = Color3.fromRGB(94, 255, 255)
		CreateMenu.CurrencyCost.TextColor3 = Color3.fromRGB(94, 255, 255)
	end
	CreateMenu.Currency.Text = Currency == "Gold" and "Current Gold: " .. tostring(format_int(DataValues.AccInfo.Gold)) or "Current Tears: " ..tostring(format_int(DataValues.AccInfo.Tears))
	CreateMenu.CurrencyCost.Text = Currency == "Gold" and "Gold Cost: FREE (for now)" or "Tears Cost: FREE (for now)"
	CreateMenu.ConfirmYes.Visible = false
	CreateMenu.ConfirmWarning.Visible = false
	GuildMenu.CreateGuild.GuildNameBox.Visible = true
	GuildMenu.CreateGuild.GuildDescBox.Visible = true
	CreateMenu.Use.Visible = true
	if C then
		CreateMenu.GuildDescBox.Text = ""
		CreateMenu.GuildNameBox.Text = ""
	end
end

GuildMenu.CreateGuild.GuildNameBox.Focused:Connect(function()
	GuildMenu.CreateGuild.ConfirmYes.Visible = false
	GuildMenu.CreateGuild.ConfirmWarning.Visible = false
	GuildMenu.CreateGuild.Use.Visible = true
end)
GuildMenu.CreateGuild.GuildDescBox.Focused:Connect(function()
	GuildMenu.CreateGuild.ConfirmYes.Visible = false
	GuildMenu.CreateGuild.ConfirmWarning.Visible = false
	GuildMenu.CreateGuild.Use.Visible = true
end)

GuildMenu.CreateGuild.GuildNameBox.FocusLost:Connect(function(enterPressed)
	local NewMsg = Socket:Request("Guild", "Filter", {GuildMenu.CreateGuild.GuildNameBox.Text})
	GuildMenu.CreateGuild.GuildNameBox.Text = NewMsg
end)
GuildMenu.CreateGuild.GuildDescBox.FocusLost:Connect(function(enterPressed)
	local NewMsg = Socket:Request("Guild", "Filter", {GuildMenu.CreateGuild.GuildDescBox.Text})
	GuildMenu.CreateGuild.GuildDescBox.Text = NewMsg
end)

GuildMenu.CreateGuild.Use.MouseButton1Down:Connect(function()
	local CanProceed = true
	if string.len(GuildMenu.CreateGuild.GuildDescBox.Text) > 100 then
		GuildMenu.CreateGuild.Use.Title.Text = "Guild Description is too long! (100 characters max)"
		CanProceed = false
	end
	if string.len(GuildMenu.CreateGuild.GuildNameBox.Text) > 20 then
		GuildMenu.CreateGuild.Use.Title.Text = "Guild Name is too long! (3-20 characters)"
		CanProceed = false
	elseif string.len(GuildMenu.CreateGuild.GuildNameBox.Text) < 3 then
		GuildMenu.CreateGuild.Use.Title.Text = "Guild Name is too short! (3-20 characters)"
		CanProceed = false
	end
	if CanProceed then
		GuildMenu.CreateGuild.ConfirmYes.Visible = true
		GuildMenu.CreateGuild.ConfirmWarning.Visible = true
		GuildMenu.CreateGuild.Use.Visible = false
	else
		wait(2)
		GuildMenu.CreateGuild.Use.Title.Text = "Create Guild"
	end
end)

GuildMenu.CreateGuild.ConfirmYes.MouseButton1Down:Connect(function()
	GuildMenu.CreateGuild.ConfirmYes.Visible = false
	GuildMenu.CreateGuild.Use.Visible = false
	GuildMenu.CreateGuild.GuildDescBox.Visible = false
	GuildMenu.CreateGuild.GuildNameBox.Visible = false
	local Settings = {
		Name = GuildMenu.CreateGuild.GuildNameBox.Text,
		Description = GuildMenu.CreateGuild.GuildDescBox.Text
	}
	local Success, NewAcc = Socket:Request("Guild", "CreateGuild", Settings)
	if Success == "Success" then
		DataValues.AccInfo = NewAcc
		GuildMenu.Buttons.CreateGuild.Visible = false
		GuildMenu.Buttons.TeleportQueue.Visible = true
		GuildMenu.Buttons.GuildInfo.Visible = true
		Transition = true
		TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.09, 0, .13, 0), Size = UDi(0, 0, .05, 0)}):Play()
		wait(.25)
		GuildMenu.Back.Visible = false
		GuildMenu.Buttons.Visible = true
		TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .65, 0), Size = UDi(.9, 0, .07, 0)}):Play()
		TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
		wait(.5)
		GuildMenu.CreateGuild.Visible = false
		Transition = false
	elseif Success == "There is already a guild name with that!" then
		GuildMenu.CreateGuild.Use.Visible = true
		GuildMenu.CreateGuild.GuildDescBox.Visible = true
		GuildMenu.CreateGuild.GuildNameBox.Visible = true
		Hint("There is already a guild with that name!")
	elseif Success == "Throttled" then
		Hint("Guild Services are a little busy right now. Try again later.")
	end
end)

GuildMenu.CreateGuild.PurchasingMode.Button.MouseButton1Down:Connect(function()
	if Currency == "Gold" then
		Currency = "Tears"
		TweenService:Create(GuildMenu.CreateGuild.PurchasingMode.Button, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(0.5, 0, 0, 0)}):Play()
	else
		Currency = "Gold"
		TweenService:Create(GuildMenu.CreateGuild.PurchasingMode.Button, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(0, 0, 0, 0)}):Play()
	end
	UpdateCreateUI(false)
	GuildMenu.CreateGuild.PurchasingMode.Button.Title.Text = Currency
end)

GuildMenu.Buttons.CreateGuild.MouseButton1Down:Connect(function()
	if not Transition then
		Transition = true
		Currency = "Gold"
		UpdateCreateUI()
		GuildMenu.CreateGuild.Use.Title.Text = "Create Guild"
		TweenService:Create(GuildMenu.CreateGuild.PurchasingMode.Button, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(0, 0, 0, 0)}):Play()
		GuildMenu.CreateGuild.Visible = true
		TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.9, 0, 0, 0)}):Play()
		if Gui.Main.AbsoluteSize.X <= 900 and Gui.Main.AbsoluteSize.Y <= 410 then
			TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(0, 0, 0, 0), Size = UDi(1, 0, 1, 0)}):Play()
		else
			TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.87, 0, .8, 0)}):Play()
		end
		wait(.5)
		GuildMenu.Buttons.Visible = false
		GuildMenu.Back.Visible = true
		TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.09, 0, .13, 0), Size = UDi(.08, 0, .05, 0)}):Play()
		wait(.25)
		Transition = false
	end
end)

local function UpdateTeleportQueue(GuildRoom, Num)
	local Number = Num and Num or nil
	if Number then
		GuildMenu.TeleportQueue.Timer.Text = "Teleporting in: " ..Number
	end
	if GuildRoom then
		local PlayerList = GuildMenu.TeleportQueue.PlayerList:GetChildren()
		local Slots = {}
		for i = 1, #PlayerList do
			local List = PlayerList[i]
			if List:IsA("TextLabel") then
				List.Text = ""
				tbi(Slots, List)
			end
		end
		for i = 1, #GuildRoom do
			Slots[i].Text = GuildRoom[i].Name
		end
	end
end

Socket:Listen("TeleportQueueUpdate", function(NewGuildRoom, Number)
	UpdateTeleportQueue(NewGuildRoom, Number)
end)

GuildMenu.Buttons.TeleportQueue.MouseButton1Down:Connect(function()
	if not Transition then
		Transition = true
		local Success, GuildRoom = Socket:Request("Guild", "TeleportJoin")
		if GuildRoom and typeof(GuildRoom) == "table" then
			UpdateTeleportQueue(GuildRoom)
			GuildMenu.TeleportQueue.Visible = true
			TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.9, 0, 0, 0)}):Play()
			if Gui.Main.AbsoluteSize.X <= 900 and Gui.Main.AbsoluteSize.Y <= 410 then
				TweenService:Create(GuildMenu.TeleportQueue, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(0, 0, 0, 0), Size = UDi(1, 0, 1, 0)}):Play()
			else
				TweenService:Create(GuildMenu.TeleportQueue, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.87, 0, .8, 0)}):Play()
			end
			wait(.5)
			GuildMenu.Buttons.Visible = false
		else
			if Success == "TPCooldown" then
				local m = {Title = "TP Cooldown", ImageId = "", M = "Teleport Queue has been put on cooldown for one minute."}
				Hint(m)
			elseif Success == "Full" then
				local m = {Title = "TP Cooldown", ImageId = "", M = "Teleport Queue is currently full. Please try again later."}
				Hint(m)
			else
				local m = {Title = "TP Cooldown", ImageId = "", M = "Teleport Queue encountered an error. Please try again later."}
				Hint(m)
			end
		end
		wait(.25)
		Transition = false
	end
end)

GuildMenu.TeleportQueue.ConfirmNo.MouseButton1Down:Connect(function()
	if not Transition then
		local Success, GuildRoom = Socket:Request("Guild", "TeleportRemove")
		if Success then
			Transition = true
			GuildMenu.Buttons.Visible = true
			TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .65, 0), Size = UDi(.9, 0, .07, 0)}):Play()
			TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
			TweenService:Create(GuildMenu.TeleportQueue, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
			wait(.5)
			GuildMenu.CreateGuild.Visible = false
			GuildMenu.TeleportQueue.Visible = false
			Transition = false
		else
			print(Success)
		end
	end
end)

local GuildStuff = nil

GuildMenu.GuildInfo.Leave.MouseButton1Down:Connect(function()
	if GuildMenu.GuildInfo.Leave.Title.Text == "Are you sure?" then
		local Success, NewAccInfo = Socket:Request("Guild", "LeaveGuild")
		if Success ~= "DisbandFirst" and NewAccInfo then
			DataValues.AccInfo = NewAccInfo
			if DataValues.AccInfo.Guild ~= "" then
				GuildMenu.Buttons.CreateGuild.Visible = false
				GuildMenu.Buttons.TeleportQueue.Visible = true
				GuildMenu.Buttons.GuildInfo.Visible = true
			else
				GuildMenu.Buttons.CreateGuild.Visible = true
				GuildMenu.Buttons.TeleportQueue.Visible = false
				GuildMenu.Buttons.GuildInfo.Visible = false
			end
			Transition = true
			TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.09, 0, .13, 0), Size = UDi(0, 0, .05, 0)}):Play()
			wait(.25)
			GuildMenu.Back.Visible = false
			GuildMenu.Buttons.Visible = true
			TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .65, 0), Size = UDi(.9, 0, .07, 0)}):Play()
			TweenService:Create(GuildMenu.CreateGuild, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
			TweenService:Create(GuildMenu.TeleportQueue, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
			TweenService:Create(GuildMenu.GuildInfo, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.87, 0, 0, 0)}):Play()
			wait(.5)
			GuildMenu.CreateGuild.Visible = false
			GuildMenu.TeleportQueue.Visible = false
			GuildMenu.GuildInfo.Visible = false
			Transition = false
		elseif Success == "DisbandFirst" then
			Hint("All members must be kicked before disbanding.")
		end
	else
		GuildMenu.GuildInfo.Leave.Title.Text = "Are you sure?"
		FS.spawn(function()
			wait(3)
			if Player.UserId == GuildStuff.Owner then
				GuildMenu.GuildInfo.Leave.Title.Text = "Disband Guild"
			else
				GuildMenu.GuildInfo.Leave.Title.Text = "Leave Guild"
			end
		end)
	end
end)

local function UpdateGuildPlayerList()
	if GuildStuff then
		local Items = GuildMenu.GuildInfo.Categories.PlayerList:GetChildren()
		for i = 1,#Items do
			if not Items[i]:IsA("UIGridLayout") then
				Items[i]:Destroy()
			end
		end
		for i = 1, #GuildStuff.Members do
			local Member = GuildStuff.Members[i]
			local PlayerGuildBlock = ReplicatedStorage.GUI.NormalGui.PlayerGuildBlock:Clone()
			local PlayerName = nil
			PlayerGuildBlock.EXPContributions.Text = "EXP Contributions: " ..format_int(math.floor(Member.EXPContributions))
			PlayerGuildBlock.JoinDate.Text = "Join Date: " ..Member.JoinDate.month.. "/" ..Member.JoinDate.day.. "/" ..Member.JoinDate.year
			if Player.UserId == GuildStuff.Owner and Member.ID ~= GuildStuff.Owner then
				PlayerGuildBlock.Kick.Visible = true
				PlayerGuildBlock.Kick.MouseButton1Down:Connect(function()
					if PlayerGuildBlock.Kick.Title.Text == "Are you sure?" then
						print(Member.ID)
						local Success = Socket:Request("Guild", "RemoveUser", {Member.ID})
						if Success then
							PlayerGuildBlock:Destroy()
						end
					else
						PlayerGuildBlock.Kick.Title.Text = "Are you sure?"
						FS.spawn(function()
							wait(3)
							if PlayerGuildBlock then
								PlayerGuildBlock.Kick.Title.Text = "Kick Member"
							end
						end)
					end
				end)
			end
			local success, errormsg = pcall(function()
				PlayerName = Players:GetNameFromUserIdAsync(Member.ID)
			end)
			local Owner = GuildStuff.Owner == Member.ID and "(Guild Leader)" or ""
			if success then
				PlayerGuildBlock.PlayerName.Text = PlayerName.. " " ..Owner
			else
				PlayerGuildBlock.PlayerName.Text = Member.ID.. " " ..Owner
			end
			PlayerGuildBlock.Parent = GuildMenu.GuildInfo.Categories.PlayerList
		end
		GuildMenu.GuildInfo.Leave.Visible = true
		if Player.UserId == GuildStuff.Owner then
			GuildMenu.GuildInfo.Leave.Title.Text = "Disband Guild"
			local PlayerGuildBlock = ReplicatedStorage.GUI.NormalGui.PlayerGuildBlock:Clone()
			PlayerGuildBlock.AddNewPlayer.Use.Title.Text = "Invite More Players (" ..#GuildStuff.Members.. "/"  .. GuildStuff.MaxM  .. ")"
			PlayerGuildBlock.AddNewPlayer.Use.MouseButton1Down:Connect(function()
				if Player.UserId == GuildStuff.Owner then
					GuildMenu.GuildInfo.PromptUser.NameBox.Text = ""
					GuildMenu.GuildInfo.PromptUser.Visible = true
				end
			end)
			PlayerGuildBlock.BackgroundTransparency = 1
			PlayerGuildBlock.AddNewPlayer.Visible = true
			PlayerGuildBlock.Kick.Visible = false
			PlayerGuildBlock.EXPContributions.Visible = false
			PlayerGuildBlock.JoinDate.Visible = false
			PlayerGuildBlock.PlayerName.Visible = false
			PlayerGuildBlock.LayoutOrder = #GuildStuff.Members+1
			PlayerGuildBlock.Parent = GuildMenu.GuildInfo.Categories.PlayerList
		end
	end
end
local function UpdateGuildInfo()
	local GuildInfo = Socket:Request("Guild", "Info")
	if typeof(GuildInfo) == "table" then
		GuildStuff = GuildInfo
		local GuildI = GuildMenu.GuildInfo
		GuildI.GuildName.Text = GuildStuff.Name
		GuildI.Description.Sub1.Text = GuildStuff.GuildDesc
		GuildI.Pts.Text = "Perk Points: ".. format_int(math.floor(GuildStuff.Pts+.5))
		GuildI.GuildXP.Info1.Info.Text = math.floor(GuildStuff.XP)
		GuildI.GuildXP.Info1.Text = "LV. " ..GuildStuff.CurLvl
		UpdateGuildPlayerList()
		FS.spawn(function()
			Animate(GuildI.GuildXP, true, 10, 10, 600, 0,0,  math.floor((0.05 * math.sqrt(GuildStuff.XP)%1)*100+.5), {91,255,62}, {255,30,30})
		end)
	end
	return GuildInfo
end

GuildMenu.GuildInfo.PromptUser.NameBox.FocusLost:Connect(function(enterPressed)
	local PlyName = GuildMenu.GuildInfo.PromptUser.NameBox.Text
	local FoundPlayer = Socket:Request("Guild", "AskPlayer", {string.lower(PlyName)})
	if FoundPlayer then
		GuildMenu.GuildInfo.PromptUser.NameBox.Text = "Invited user " ..PlyName
	else
		GuildMenu.GuildInfo.PromptUser.NameBox.Text = "No player in server with that name!"
	end
	wait(2)
	GuildMenu.GuildInfo.PromptUser.Visible = false
end)

Socket:Listen("AskToJoin", function(GuildName)
	if GuildMenu.Parent.GuildPrompt.Visible == false then
		GuildMenu.Parent.GuildPrompt.Visible = true
		local Timer = 10
		FS.spawn(function()
			while Timer > 0 and GuildMenu.Parent.GuildPrompt.Visible do
				GuildMenu.Parent.GuildPrompt.Title.Text = "You have been invited to join " .. GuildName .." Guild (" ..Timer..  ")"
				Timer = Timer - 1
				wait(1)
			end
			Socket:Emit("Guild", "IgnoreJoin")
			TweenService:Create(GuildMenu.Parent.GuildPrompt, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(-.2, -10, 0.5, 0)}):Play()
			wait(.5)
			GuildMenu.Parent.GuildPrompt.Visible = false
		end)
		TweenService:Create(GuildMenu.Parent.GuildPrompt, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(0, -10, 0.5, 0)}):Play()
	end
end)

GuildMenu.Parent.GuildPrompt.Yes.MouseButton1Down:Connect(function()
	Socket:Emit("Guild", "AcceptJoin")
	TweenService:Create(GuildMenu.Parent.GuildPrompt, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(-.2, -10, 0.5, 0)}):Play()
	wait(.5)
	GuildMenu.Parent.GuildPrompt.Visible = false
	FS.spawn(function()
		wait(1)
		if Camera.PlayerHPs:FindFirstChild(Player.Name) then
			Camera.PlayerHPs[Player.Name].Player.Namer.Text = Player.Name
		end
	end)
end)
GuildMenu.Parent.GuildPrompt.No.MouseButton1Down:Connect(function()
	Socket:Emit("Guild", "IgnoreJoin")
	TweenService:Create(GuildMenu.Parent.GuildPrompt, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(-.2, -10, 0.5, 0)}):Play()
	wait(.5)
	GuildMenu.Parent.GuildPrompt.Visible = false
end)

GuildMenu.Buttons.GuildInfo.MouseButton1Down:Connect(function()
	if not Transition then
		Transition = true
		local Gu = UpdateGuildInfo()
		if typeof(Gu) == "table" then
			GuildMenu.GuildInfo.Visible = true
			TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.9, 0, 0, 0)}):Play()
			if Gui.Main.AbsoluteSize.X <= 900 and Gui.Main.AbsoluteSize.Y <= 410 then
				TweenService:Create(GuildMenu.GuildInfo.GuildXP, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(0.1, 0, 0.2, -30)}):Play()
				GuildMenu.GuildInfo.GuildXP.UIScale.Scale = .6
				TweenService:Create(GuildMenu.GuildInfo, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(0, 0, 0, 0), Size = UDi(1, 0, 1, 0)}):Play()
			else
				TweenService:Create(GuildMenu.GuildInfo, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .1, 0), Size = UDi(.87, 0, .8, 0)}):Play()
			end
			wait(.5)
			GuildMenu.Buttons.Visible = false
			GuildMenu.Back.Visible = true
			if Gui.Main.AbsoluteSize.X <= 900 and Gui.Main.AbsoluteSize.Y <= 410 then
				TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.01, 0, .13, 0), Size = UDi(.08, 0, .05, 0)}):Play()
			else
				TweenService:Create(GuildMenu.Back, TIN(.25,Enum.EasingStyle.Quad), {Position = UDi(.09, 0, .13, 0), Size = UDi(.08, 0, .05, 0)}):Play()
			end
		end
		wait(.25)
		Transition = false
	end
end)

GuildMenu.Buttons.Leave.MouseButton1Down:Connect(function()
	if not Transition then
		Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
		Character.PrimaryPart.Anchored = false
		Transition = true
		TweenService:Create(GuildMenu.Buttons, TIN(.5,Enum.EasingStyle.Quad), {Position = UDi(.07, 0, .72, 0), Size = UDi(.9, 0, 0, 0)}):Play()
		wait(.5)
		GuildMenu.Visible = false
		GuildMenu.Buttons.Visible = false
		Transition = false
	end
end)