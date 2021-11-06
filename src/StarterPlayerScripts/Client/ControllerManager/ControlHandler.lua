-- << Services >> --
local UserInputService 	= game:GetService("UserInputService")
local GuiService		= game:GetService("GuiService")
local Players 			= game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local Debris			= game:GetService("Debris")
local Teams				= game:GetService("Teams")
local CAS				= game:GetService("ContextActionService")
local RunService		= game:GetService("RunService")


-- << Constants >> --
local CAMERA	= workspace.Camera
local CLIENT 	= script.Parent.Parent
local BINDABLES = CLIENT.Bindables
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask


-- << Modules >> --
local Socket 			= require(MODULES.socket)
local RainAPI			= require(MODULES.Rain)
local Effects			= require(MODULES.Effects)
local DataValues 		= require(CLIENT.DataValues)
local AnimManage		= require(CLIENT.CharacterManager.AnimationManager)
local BattleModeON 		= require(CLIENT.CharacterManager.RebuildBattleMode)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local format_int 		= require(CLIENT.UIEffects.FormatInteger)
local CreateTutorial	= require(CLIENT.UIEffects.TutorialPlatformButtons)
local execute_Dialogue	= require(CLIENT.DialogueSystem.MainExecutorDialogue)
local FS 		  		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local OpenMenu			= require(script.Parent.TabMenuHandler)
local controls 			= require(PLAYER.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

-- << Variables >> --
local Ticks				= DataValues.Ticks
local Objs 				= DataValues.Objs
local Numbers 			= DataValues.Numbers
local bools 			= DataValues.bools
local KeyboardMapping 	= DataValues.KeyboardMapping
local ControllerMapping = DataValues.ControllerMapping
local Stickdir			= "None"
local HeartBeat			= nil
local gamePadInputs 	= {}
local PlayerUI			= GUI.Main.GameGUI.PlayerUI
local Character			= PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid			= Character:WaitForChild("Humanoid")
local Values			= ReplicatedStorage.PlayerValues:WaitForChild(PLAYER.Name, 30)
local IsPrivateServer	= ReplicatedStorage.SERVER_STATS:WaitForChild("IsPrivateServer").Value

local rad = math.rad

local constrainedCameraPlaces = {785484984, 6092300236, 563493615, 6092293455}


---- << Functions >> --
function CheckForNewPlayerValue()
	local search = ReplicatedStorage.PlayerValues:FindFirstChild(PLAYER.Name)
	if search then
		Values = search
	end
end

function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

function FloatOrNot(addedTime)
	local additionalT = addedTime or 0
	if DataValues.state ~= "Landed" and DataValues.state ~= "Running" and DataValues.state ~= "RunningNoPhysics" then
		Character.AlignPosition.Enabled = false
		Ticks.FloatTime = tick()+additionalT
	end
end

function convert(angle, delta)
	if angle > 135 or angle < -135 and delta.Y <= 0 then
		return "Down"
	elseif angle <= 135 and angle >= 45 and delta.X >= 0 then
		return "Right"
	elseif angle >= -135 and angle <= -45 and delta.X <= 0 then
		return "Left"
	elseif angle < 45 and angle > -45 and delta.Y >= 0 then
		return "Up"
	end
	return "None"
end

function constrain(val, min, max)
	return val < min and min or val > max and max or val
end

function MobileControls(AN, UIS, IO)
	IO.KeyCode = DataValues.CurrentController[AN]
	if UIS == Enum.UserInputState.Begin then
		OnKeyDown(IO)
	elseif UIS == Enum.UserInputState.End then
		OnKeyUp(IO)
	end
end

function OnKeyDown(InputObject, GameProcessedEvent)
	if not bools.ded and DataValues.CameraEnabled then
		local KeyCode 		= InputObject.KeyCode
		local UserInputType = InputObject.UserInputType
		if DataValues.ControllerType ~= "Keyboard" then
			if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.MouseButton2 or UserInputType == Enum.UserInputType.MouseButton3 or UserInputType == Enum.UserInputType.Keyboard then
				UserInputService.MouseIconEnabled = false		
				DataValues.ControllerType 		= "Keyboard"
				DataValues.CurrentController 	= KeyboardMapping
			end
		elseif DataValues.ControllerType ~= "Controller" then
			if UserInputType == Enum.UserInputType.Gamepad1 then
				UserInputService.MouseIconEnabled = false
				DataValues.ControllerType 		= "Controller"
				DataValues.CurrentController 	= ControllerMapping
				if DataValues.WatchedIntro == false then
					GuiService.SelectedObject = GUI.MainMenu.Intro.NEWGAME
				end
			end
		end
		
		if (UserInputType == DataValues.CurrentController.MouseButton2 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton2)) then
			local FocusPoint = Character.HumanoidRootPart.Position
			local NearestNPC,Proximity = nil, 7
			local NPCs = workspace.Interactables:GetChildren()
			for i,NPC in ipairs(NPCs) do
				if NPC.PrimaryPart then
					local Distance = (NPC.PrimaryPart.Position - FocusPoint).magnitude
					if Distance < Proximity then
						NearestNPC = NPC
						Proximity = Distance
					end
				end
			end
			if NearestNPC then
				if NearestNPC:FindFirstChild("Surface") then
					NearestNPC.Parent = workspace
					CLIENT.Bindables.ContinueStory:Fire()
				else
					ReplicatedStorage.Sounds.SFX.FlipPaper:Play()
					if NearestNPC:FindFirstChild("Message") then
						if (NearestNPC.Message.Value == "Darwin" or NearestNPC.Message.Value == "Red" or NearestNPC.Message.Value == "Valeri") then
							workspace.Interactables.Lootbox1.Parent = workspace
							workspace.Interactables.Lootbox2.Parent = workspace
							workspace.Interactables.Lootbox3.Parent = workspace
							local Chosen = NearestNPC.Message.Value == "Darwin" and "A" or NearestNPC.Message.Value == "Red" and "C" or "B"
							Character.PrimaryPart.Anchored = true
							Character:SetPrimaryPartCFrame(Chosen == "A" and workspace.DarwinSelect.PrimaryPart.CFrame or Chosen == "B" and workspace.ValeriSelect.PrimaryPart.CFrame or workspace.RedSelect.PrimaryPart.CFrame)
							local NewAnim = Humanoid:LoadAnimation(workspace.DarwinSelect.Animation)
							NewAnim.KeyframeReached:Connect(function(KF)
								if KF == "Electric1" then
									local E = MODULES["Effects"].Particles.Sparks.Intro1Electric.E1:Clone()
									E.Parent = Character.UpperTorso
									Debris:AddItem(E, 30)
								elseif KF == "Electric2" then
									local E = MODULES["Effects"].Particles.Sparks.Intro2Electric.E2:Clone()
									E.Parent = Character.UpperTorso
									Debris:AddItem(E, 30)
								elseif KF == "Electric3" then
									TweenService:Create(workspace.Door.Main,TweenInfo.new(5,Enum.EasingStyle.Sine),{CFrame = workspace.Door.Main.CFrame*CFrame.new(0, -8.65, 0)}):Play()
									local E = MODULES["Effects"].Particles.Sparks.Intro3Electric.E3:Clone()
									E.Parent = Character.UpperTorso
									Debris:AddItem(E, 30)
									Socket:Emit("RequestNewGame", Chosen)
									wait(.5)
									Socket:Emit("ForceMorph")
									Socket:Emit("ForceHitbox")
								elseif KF == "AnimationEnd" then
									Character.PrimaryPart.Anchored = false
									for _,Particles in ipairs(Character.UpperTorso:GetDescendants()) do
										if Particles:IsA("ParticleEmitter") or Particles:IsA("PointLight") then
											Particles.Enabled = false
										end
									end
									if Character:FindFirstChild("Animate") then
										Character.Animate:Destroy()
									end
									Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
									PlayerUI.Left.EnemiesAlive.Visible = false
									GUI.Main.GameGUI.Size = UDim2.new(3, 0, 1, 0)
									GUI.Main.GameGUI.Position = UDim2.new(-1, 0, -1, 0)
									GUI.Main.GameGUI.Vignette.ImageTransparency = 1
									if not UserInputService.GamepadEnabled then
										GUI:WaitForChild("Chat").Enabled = false
									end
									GUI.Main.Enabled = true
									TweenService:Create(GUI.Main.GameGUI,TweenInfo.new(3,Enum.EasingStyle.Sine),{Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0)}):Play()
									FS.spawn(function()
										wait(3)
										TweenService:Create(GUI.Main.GameGUI.Vignette,TweenInfo.new(1,Enum.EasingStyle.Sine),{ImageTransparency = 0.6}):Play()
									end)
									BattleModeON()
									NewAnim:Stop()
									NewAnim:Destroy()
								end
							end)
							NewAnim:Play()
						elseif NearestNPC.Message.Value == "DarwinCreation" then
							Hint("A warrior shrouded in betrayal,") wait(3)
							Hint("Who grasped for retribution in life unto death.") wait(4)
							Hint("Take up his sword and shoulder his burden.")
						elseif NearestNPC.Message.Value == "RedCreation" then
							Hint("A girl who grew up under a strict regime,") wait(3)
							Hint("Who became an assassin and inventor to seek escape.") wait(4)
							Hint("Wield her rifle and take up her creed.")
						elseif NearestNPC.Message.Value == "ValeriCreation" then
							Hint("A mad magician sacrificing many for research,") wait(5)
							Hint("Who was doomed by the flame of her own zeal.") wait(4)
							Hint("Gather her cards and extend her legacy.")
						else
							Hint(NearestNPC.Message.Value)
						end
					elseif NearestNPC:FindFirstChild("Tutorial1") then
						CreateTutorial({Keyboard = "C", Controller = "ButtonB", Touch = "CC"}, NearestNPC.Tutorial1.Value)
					elseif NearestNPC:FindFirstChild("Tutorial2") then
						CreateTutorial({Keyboard = "ButtonX", Controller = "ButtonX", Touch = "MouseButton1"}, NearestNPC.Tutorial2.Value)
					elseif NearestNPC:FindFirstChild("Tutorial3") then
						CreateTutorial({Keyboard = "ButtonX", Controller = "ButtonX", Touch = "MouseButton1"}, NearestNPC.Tutorial2.Value)
					elseif NearestNPC:FindFirstChild("DungeonEntrance") then
						if DataValues.ControllerType == "Touch" then
							NEWMENU.Parent.DungeonChoose.CreateRoom.NameOfRoom.Title.Text = "[ Room Name ]"
						end
						NEWMENU.Parent.DungeonChoose.Visible = true
						DataValues.CharInfo = Socket:Request("getCharacterInfo")
						DataValues.AccInfo = Socket:Request("getAccountInfo")
					end
				end
			end
		end
		if KeyCode == DataValues.CurrentController.T and DataValues.WatchedIntro then
			--[[
			local EmotesMenu = GUI.Main.Emotes
			if EmotesMenu.Visible then
				EmotesMenu.Visible = false
				local LeftOverMotes = EmotesMenu.Motes:GetChildren()
				for i = 1, #LeftOverMotes do
					local Motes = LeftOverMotes[i]
					if Motes:IsA("ImageButton") then
						Motes:Destroy()
					end
				end
			elseif not GUI.Main.Guilds.Visible then
				local NewMotes = ReplicatedStorage.GUI.Emotes:GetChildren()
				for i = 1, #NewMotes do
					local Mote = NewMotes[i]:Clone()
					Mote.MouseButton1Down:Connect(function()
						if Character.PrimaryPart:FindFirstChild("Emote") == nil and tick()-Ticks.MoteTimer >= 1.5 then
							Ticks.MoteTimer = tick()
							Socket:Fire("Emote", Mote.Name)
						end
					end)
					Mote.Parent = EmotesMenu.Motes
				end
				EmotesMenu.Visible = true
			end
			--]]
		end
		if KeyCode == DataValues.CurrentController.N then ---only supplied for controllers, mouse users can click the close
			BINDABLES.ControllerClose:Fire()
		end
		if KeyCode == DataValues.CurrentController.Tab then
			if PLAYER.TeamColor == Teams.Lobby.TeamColor and DataValues.WatchedIntro then
				if bools.PlayingTutorial then
					TweenService:Create(GUI.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Description.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.OuterFrame.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Skills.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs.Visible = false
					bools.PlayingTutorial = false
				else
					if not bools.OpeningMenu then
						bools.OpeningMenu = true
						--NEWMENU.Parent.DungeonChoose.Visible = false
						TweenService:Create(GUI.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,1,0)}):Play()
						OpenMenu()
						bools.OpeningMenu = false
					end
				end
			elseif DataValues.WatchedIntro then
				GUI.Main.Tutorial.Visible = true
				TweenService:Create(GUI.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,0.6,0)}):Play()
				for _,word in next, GUI.Main.Tutorial.Combat:GetChildren() do
					if word:IsA("TextLabel") then
						word.TextTransparency = 0
						word.TextStrokeTransparency = 0
					end
				end
				TweenService:Create(GUI.Main.Tutorial.Combat, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 0}):Play()
				bools.HoldingDownTab = true
				local Inspect = nil
				while bools.HoldingDownTab do
					if Inspect then
						Inspect.Enabled = false
					end
					local FocusPoint = Character.HumanoidRootPart.Position
					local NearestTorso,Proximity = nil,100
					for _,enemies in ipairs(DataValues.Enemies) do
						if enemies.HRP then
							local Distance = (enemies.HRP.Position - FocusPoint).magnitude
							if Distance < Proximity then
								NearestTorso = enemies.HRP
								Proximity = Distance
							end
						end
					end
					if NearestTorso then
						if NearestTorso:FindFirstChild("Inspect") == nil then
							Inspect = ReplicatedStorage.GUI.BillboardGui.Inspect:Clone()
							Inspect.Parent = NearestTorso
						else
							Inspect = NearestTorso.Inspect
						end
						Inspect.Enabled = true
						if NearestTorso:FindFirstChild("Stats") then
							Inspect.Menu.Stats.ATK.Valu.Text = math.floor(NearestTorso.Stats.Atk.Value)
							Inspect.Menu.Stats.CRIT.Valu.Text = math.floor(NearestTorso.Stats.Crit.Value).. "%"
							Inspect.Menu.Stats.DEF.Valu.Text = math.floor(NearestTorso.Stats.Def.Value)
							Inspect.Menu.Stats.HP.Valu.Text = math.floor(NearestTorso.Stats.Hp.Value)
							Inspect.Menu.Stats.Level.Valu.Text = math.floor(NearestTorso.Stats.Lvl.Value)
						else
							Inspect.Menu.Stats.ATK.Valu.Text = "???"
							Inspect.Menu.Stats.CRIT.Valu.Text = "???%"
							Inspect.Menu.Stats.DEF.Valu.Text = "???"
							Inspect.Menu.Stats.HP.Valu.Text = "???"
							Inspect.Menu.Stats.Level.Valu.Text = "???"
						end
					end
					wait(.4)
				end
				if Inspect then
					Inspect.Enabled = false
				end
			end
		end
		if PLAYER.TeamColor == Teams.Lobby.TeamColor then
			if UserInputType == DataValues.CurrentController.MouseButton1 or (DataValues.ControllerType == "Controller" and KeyCode == DataValues.CurrentController.MouseButton1) or DataValues.ControllerType == "Touch" then
				if bools.InDialogue then
					bools.Skip = true
				end
			end
			if UserInputType == DataValues.CurrentController.MouseButton2 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton2) then					
				if not bools.InDialogue then
					local FocusPoint = Character.HumanoidRootPart.Position
					local NearestNPC,Proximity = nil,10
					local NPCs = workspace.Cutscene:GetChildren()
					for i=1, #NPCs do
						local NPC = NPCs[i]
						if NPC.PrimaryPart and NPC:FindFirstChild("Humanoid") then
							local Distance = (NPC.PrimaryPart.Position - FocusPoint).magnitude
							if Distance < Proximity then
								NearestNPC = NPC
								Proximity = Distance
							end
						end
					end
					if NearestNPC then
						local Scripts = MODULES.StoryTeller.StoryScripts:GetChildren()
						for i = 1, #Scripts do
							local Script = Scripts[i]
							if Script:FindFirstChild("Char") then
								if Script.Char.Value == NearestNPC then
									local Expressions = Script.Expressions:GetChildren()
									for v = 1, #Expressions do
										Expressions[v]:Clone().Parent = GUI.MainDialogue.DialoguePortraits.Frame.Expressions
									end
									Character.PrimaryPart.Anchored = true
									local Dial = Script.Function:Invoke()
									if Dial ~= nil then
										execute_Dialogue(Dial, true)
										Script.Event:Fire("Finished")
										DataValues.AccInfo = Socket:Request("getAccountInfo")
										if bools.NewPlayer then
											GUI.Main.Tutorial.Visible = true
											TweenService:Create(GUI.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,0.6,0)}):Play()
											wait(2)
											for _,word in next, GUI.Main.Tutorial.Front:GetChildren() do
												if word:IsA("TextLabel") then
													TweenService:Create(word, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
												end
											end
											TweenService:Create(GUI.Main.Tutorial.Front, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 0}):Play()
										end
									end
									Character.PrimaryPart.Anchored = false
									break
								end
							end
						end
					end
				end
			end

		
		--[[ In Dungeon ]]--
		elseif PLAYER.TeamColor ~= Teams.Lobby.TeamColor and not bools.Stunned and not bools.ChatEnabled and not bools.ded then
			if (UserInputType == DataValues.CurrentController.MouseButton1 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton1)) then
				DataValues.Last_Y = Character.PrimaryPart.Position.Y
				if not bools.IsDodging then
					bools.RightMouseButtonDown = false
					bools.LeftMouseButtonDown = true
					while not bools.ded and bools.LeftMouseButtonDown and not bools.IsDodging do
						if not bools.Debounce and (Numbers.Combo == 1 or tick()-Ticks.Last_Combo <= Numbers.ComboWindow) then
							local currentCombo = string.format("X%s", Numbers.Combo)
							Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attackX[currentCombo])
							bools.Debounce 	= true
							AnimManage:StopAllAnimations()
							FloatOrNot(Objs.AnimTrack.Length*0.7)
							local SpeedUp = {"rbxassetid://3226792660"}
							Humanoid.WalkSpeed = 3
							Numbers.SkillCounter = 1
							if table.find(SpeedUp, Character.Animate.attackX[currentCombo].AnimationId) then
								Humanoid.WalkSpeed = 40
							end
							if Objs.LockOn then
								Humanoid.AutoRotate = false
								Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Vector3.new(Objs.LockOn.Position.X, Character.HumanoidRootPart.Position.Y, Objs.LockOn.Position.Z))
							end
							local Bindables = Character.Animate.Bindables:GetChildren()
							for i = 1, #Bindables do
								Objs.AnimTrack:GetMarkerReachedSignal(Bindables[i].Name):Connect(function()
									Bindables[i]:Fire(Objs.AnimTrack)
								end)
							end

							local function onAnimationEnd()
								Ticks.Last_Combo = tick()
								Numbers.Combo = Numbers.Combo + 1
								if Character.Animate.attackY:FindFirstChild("Y"..Numbers.Combo) then
									GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = true
					--				GUI.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y"..Numbers.Combo].img.Value
								else
									GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = false
								end
								if Numbers.Combo > 5 then
									if DataValues.state == "Landed" or DataValues.state == "Running" or DataValues.state == "RunningNoPhysics" then
										print("On ground")
									else
										wait(.5)
									end
									AnimManage:RestoreAnimations()
									if Character.Animate.attackY:FindFirstChild("Y1") then
										GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = true
				--						GUI.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y1"].img.Value
									end
								else
									local lc = Ticks.Last_Combo
									AnimManage:RestoreAnimations(true)
									FS.spawn(function()
										wait(Numbers.ComboWindow)
										if not bools.Debounce and Numbers.Combo ~= 1 and lc == Ticks.Last_Combo then
											Numbers.Combo = 1
											Numbers.SkillCounter = 1
											Ticks.Last_Combo = tick() + 1
											if Character.Animate.attackY:FindFirstChild("Y1") then
												GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = true
								--				GUI.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y1"].img.Value
											end
										end
									end)
								end

								bools.Debounce = false
								Character.PrimaryPart.Anchored = false
								DataValues.CAMERAOFFSET = Vector3.new(0,2,15)
								if Humanoid.WalkSpeed == 3 or Humanoid.WalkSpeed == 40 then
									Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
								end
							end

							Objs.AnimTrack.KeyframeReached:connect(function(KeyFrame)
								if KeyFrame == "SlashEnd" or KeyFrame == "AnimationEnd" then
									Objs.AnimTrack:Stop()
								end
							end)

							Objs.AnimTrack:Play()
							Objs.AnimTrack:AdjustSpeed(Numbers.Att)
							Objs.AnimTrack.Stopped:Wait()
							onAnimationEnd()
						end
						wait(0.1)
					end
				end
			end
			if (UserInputType == DataValues.CurrentController.MouseButton2 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton2)) then
				bools.LeftMouseButtonDown = false
				DataValues.Last_Y = Character.PrimaryPart.Position.Y
				if not bools.IsDodging then
					if Ticks.FloatTime - tick() < -.3 and bools.IsBlocking then
						if bools.Debounce and (Character.Animate.attackV:FindFirstChild("V1")) then
							bools.Debounce 	= false
							Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attackV["V1"])
							AnimManage:StopAllAnimations()
							CanJump = false
							if Humanoid.WalkSpeed == 0 then
								Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
							end
							if Objs.LockOn then
								Humanoid.AutoRotate = false
								Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Vector3.new(Objs.LockOn.Position.X, Character.HumanoidRootPart.Position.Y, Objs.LockOn.Position.Z))
							end
							Objs.AnimTrack.KeyframeReached:connect(function(KeyFrame)
								if KeyFrame == "SlashEnd" or KeyFrame == "AnimationEnd" then
									AnimManage:RestoreAnimations()
									bools.IsBlocking 	= false
									Character.PrimaryPart.Anchored = false
								end
							end)
							Objs.AnimTrack:Play()
							--[[if bools.IsCryForm then
								Objs.AnimTrack:AdjustSpeed(1.25)
							end--]]
							Objs.AnimTrack:AdjustSpeed(Numbers.Att)
							Ticks.Last_Combo = tick()+Objs.AnimTrack.Length
						end
					elseif bools.IsDodging and Character.Animate:FindFirstChild("attackWhileDodge") then
						Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attackWhileDodge["X1"])
						GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = false
						AnimManage:StopAllAnimations()
						Objs.AnimTrack.KeyframeReached:Connect(function(KF)
							if KF == "CounterAnimation" then
								if Character.PrimaryPart:FindFirstChild("CounterAnimation") == nil then
									local Time = Objs.AnimTrack:GetTimeOfKeyframe("NonCountered")
									Objs.AnimTrack.TimePosition = Time
								end
							end
						end)
						Objs.AnimTrack:Play()
					else
						if not bools.Debounce and (Numbers.Combo == 1 or tick()-Ticks.Last_Combo <= Numbers.ComboWindow) then
							local Skill = string.format("Y%s-%s", Numbers.Combo, Numbers.SkillCounter)
							if (Character.Animate.attackY:FindFirstChild(Skill)) then
								local C = Numbers.ChainCooldowns[string.format("C%s", Numbers.Combo)]
								local CD = Numbers.ChainCooldowns[string.format("CD%s", Numbers.Combo)]
								local Left = PlayerUI.Left
								
								if C > 0 and Numbers.SkillCounter <= 1 then
									if tick() - CD >= C then
										Numbers.ChainCooldowns[string.format("CD%s", Numbers.Combo)] = tick()
										local Chain = Left.Template.Chain:Clone()
										Chain.Message.Text = string.format("Chain Combo %s Disabled", Numbers.Combo)
										Chain.Visible = true
										Chain.Parent = Left.StatusEffects
										Debris:AddItem(Chain, C)
										TweenService:Create(Chain.warning, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
										TweenService:Create(Chain.warning2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
										TweenService:Create(Chain.Message, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {TextTransparency = 0.3}):Play()
										TweenService:Create(Chain.Message.Bar, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.3}):Play()
										TweenService:Create(Chain.Message.Bar, TweenInfo.new(C, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
									else
										return
									end
								end

								if Values.Stamina.Value < 1 then
									local Left = PlayerUI.Left
									local Chain = Left.Template.Chain:Clone()
									Chain.Message.Text = string.format("Out of stamina!", Numbers.Combo)
									Chain.Visible = true
									Chain.Parent = Left.StatusEffects
									Debris:AddItem(Chain, 2.5)
									TweenService:Create(Chain.warning, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
									TweenService:Create(Chain.warning2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
									TweenService:Create(Chain.Message, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {TextTransparency = 0.3}):Play()
									TweenService:Create(Chain.Message.Bar, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.3}):Play()
									TweenService:Create(Chain.Message.Bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
									return
								end
								
								Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attackY[Skill])
								bools.Debounce 	= true
								bools.RightMouseButtonDown = true
								GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = false
								AnimManage:StopAllAnimations()
								local NoSlow = {"rbxassetid://3087280788", "rbxassetid://3917046117"}
								local BiggerCam = {"rbxassetid://3115648751"}
								Humanoid.WalkSpeed = 3
								if table.find(NoSlow, Character.Animate.attackY[Skill].AnimationId) then
									Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
								end
								if table.find(BiggerCam, Character.Animate.attackY[Skill].AnimationId) then
									DataValues.CAMERAOFFSET = Vector3.new(0, 2, 25)
								end
								if Objs.LockOn then
									Humanoid.AutoRotate = false
									Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Vector3.new(Objs.LockOn.Position.X, Character.HumanoidRootPart.Position.Y, Objs.LockOn.Position.Z))
								end
								Numbers.SkillCounter += 1
								local Bindables = Character.Animate.Bindables:GetChildren()
								Objs.AnimTrack.KeyframeReached:Connect(function(KeyFrame)
									for i = 1, #Bindables do
										if Bindables[i]:IsA("BindableEvent") and KeyFrame == Bindables[i].Name then
											Bindables[i]:Fire(Objs.AnimTrack)
										end
									end
									if KeyFrame == "CounterAnimation" then
										if Character.PrimaryPart:FindFirstChild("CounterAnimation") == nil then
											local Time = Objs.AnimTrack:GetTimeOfKeyframe("NonCountered")
											Objs.AnimTrack.TimePosition = Time
										end
									end
									if KeyFrame == "ParryStance" then
										Socket:Emit("Blocking")
									end
									if KeyFrame == "Hold" then
										Objs.AnimTrack:AdjustSpeed(0)
										bools.TPS = true
										GUI.Main.GameGUI.Crosshair.Visible = true
									elseif KeyFrame == "HoldInput" and bools.RightMouseButtonDown then
										Objs.AnimTrack:AdjustSpeed(0)
									elseif KeyFrame == "Shoot" then
										Socket:Emit("A", CAMERA.CFrame)
									elseif KeyFrame == "Dash" or KeyFrame == "DashLong" then
										local y = Instance.new("BodyVelocity")
										y.Name = "BV"
										y.maxForce = Vector3.new(49999, 3, 49999)
										y.velocity = Character.PrimaryPart.CFrame.LookVector * 100
										y.Parent = Character.PrimaryPart
										Debris:AddItem(y, KeyFrame == "DashLong" and 1 or 0.1)
									end
									local Ended = false
									if KeyFrame == "AnimationEndHold" then
										if not bools.RightMouseButtonDown then
											Ended = true
										end
									end
									if KeyFrame == "SlashEnd" or KeyFrame == "AnimationEnd" or Ended then
										Ticks.Last_Combo = tick()
										if Numbers.SkillCounter > 3 or Character.Animate.attackY:FindFirstChild(string.format("Y%s-%s", Numbers.Combo, Numbers.SkillCounter)) == nil then
											AnimManage:RestoreAnimations()
										else
											local lc = Ticks.Last_Combo
											AnimManage:RestoreAnimations(true)
											FS.spawn(function()
												wait(Numbers.ComboWindow)
												if not bools.Debounce and (Numbers.Combo ~= 1 or Numbers.SkillCounter ~= 1) and lc == Ticks.Last_Combo then
													Numbers.Combo = 1
													Numbers.SkillCounter = 1
													Ticks.Last_Combo = tick() + 1
												end 
											end)
										end
										bools.Debounce = false
										Character.PrimaryPart.Anchored = false
										DataValues.CAMERAOFFSET = Vector3.new(0,2,15)
										if Humanoid.WalkSpeed == 3 then
											Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
										end
										if Character.Animate.attackY:FindFirstChild("Y1") then
											GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = true
									--		GUI.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y1"].img.Value
										end
									end
								end)
								Objs.AnimTrack:Play()
								--[[if bools.IsCryForm then
									Objs.AnimTrack:AdjustSpeed(1.25)
								end--]]
								Objs.AnimTrack:AdjustSpeed(Numbers.Att)
								Ticks.Last_Combo = tick()+Objs.AnimTrack.Length
							else
								AnimManage:RestoreAnimations()
							end
						end
					end
				end
			end
			if KeyCode == DataValues.CurrentController.Q then
				--[[DataValues.Last_Y = Character.PrimaryPart.Position.Y
				if not bools.Debounce and Numbers.UltimateBar >= 100 and (Character.Animate.attackZ:FindFirstChild("Z1")) then
					Numbers.UltimateBar = Numbers.UltimateBar - 100
					bools.IsUltimate = true
					FS.spawn(function()
						wait(10)
						if bools.IsUltimate then
							bools.IsUltimate = false
						end
					end)
					bools.Debounce 	= true
					Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attackZ["Z1"])
					AnimManage:StopAllAnimations()
					Humanoid.WalkSpeed = 0
					if Objs.LockOn then
						Humanoid.AutoRotate = false
						Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Objs.LockOn.Position)
					end
					DataValues.CAMERAOFFSET 			= Vector3.new(0,2,35)
					Character.Animate.Bindables.Cancel:Fire()
					Objs.AnimTrack.KeyframeReached:connect(function(KeyFrame)
						if KeyFrame == "SlashEnd" or KeyFrame == "AnimationEnd" then
							Character.PrimaryPart.Anchored = false
							if Humanoid.WalkSpeed == 0 then
								Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
								DataValues.CAMERAOFFSET 			= Vector3.new(0,2,15)
							end
							AnimManage:RestoreAnimations()
							bools.Debounce = false
							bools.IsUltimate = false
						end
					end)
					Objs.AnimTrack:Play()
					Objs.AnimTrack:AdjustSpeed(Numbers.Att)
				elseif bools.Debounce and bools.IsBlocking and Numbers.UltimateBar >= 400 then
					Numbers.UltimateBar = Numbers.UltimateBar - 400
					AnimManage:StopAllAnimations()
					bools.Debounce = false
					bools.IsBlocking = false
					Socket:Emit("Ultimate")
				end--]]
			end
			if KeyCode == DataValues.CurrentController.Z then
				--if not bools.IsCryForm then
					--Socket:Emit("CryMorph")
					
					--local ex = Effects.CastExplosion(Character.UpperTorso.Position)
					--ex.Parent = Character
				--end
			end
			if KeyCode == DataValues.CurrentController.CC then
				DataValues.Last_Y = Character.PrimaryPart.Position.Y
				if (DataValues.state == "Freefall" or DataValues.state == "Jumping") then
					local OldResponsive = Character.AlignPosition.Responsiveness
					local MoveVector = controls:GetMoveVector()
					
					if MoveVector.Magnitude > 0 then
						if not bools.IsDodging and Numbers.MaxCC < 3  then
							Numbers.MaxCC = Numbers.MaxCC + 1
							Ticks.FloatTime = -10
							bools.IsDodging = true
							Character.AlignPosition.Responsiveness = 10
							local RollDir = CAMERA.CFrame:VectorToWorldSpace(MoveVector)
							local LookAt = Character.PrimaryPart.Position + RollDir
							local OptionalDist = 0
							if Objs.LockOn then
								if (MoveVector.X == 0 and MoveVector.Y == 0 and MoveVector.Z == -1) or (DataValues.ControllerType == "Touch" and MoveVector.Z < -0.95) then
									OptionalDist = (Objs.LockOn.Position - LookAt).Magnitude
									if OptionalDist <= 40 then
										Character.AlignPosition.Responsiveness = 40
										LookAt = Objs.LockOn.Position
									end
								end
							end
							Character.PrimaryPart.CFrame = CFrame.new(Character.PrimaryPart.Position, LookAt)
							Effects.MagicCircleEffect(Character.HumanoidRootPart.CFrame * CFrame.Angles(rad(-90),0,0))
							
							local Position = Character.PrimaryPart.Position + Character.PrimaryPart.CFrame.LookVector * (OptionalDist > 0 and (OptionalDist >= 40 and 40 or OptionalDist) or 30)
							DataValues.AlignPositionAttachment.Position = Position
							
							Character.AlignPosition.Enabled = true
							wait(0.25)
							Character.AlignPosition.Enabled = false
							Character.AlignPosition.Responsiveness = OldResponsive
							bools.IsDodging = false
						end
					else
						bools.IsDodging = true
						Ticks.FloatTime = -10
						Effects.MagicCircleEffect(Character.HumanoidRootPart.CFrame * CFrame.Angles(rad(180),0,0))
						local ray = Ray.new(Character.PrimaryPart.Position, Character.PrimaryPart.CFrame.UpVector * -40)
						local obj, pos = workspace:FindPartOnRayWithIgnoreList(ray, {workspace.Terrain, Character}, false, true)
						
						DataValues.AlignPositionAttachment.Position = obj and pos + Vector3.new(0, 10, 0) or pos
						Character.AlignPosition.Responsiveness = 35
						Character.AlignPosition.Enabled = true
						wait(0.05)
						Character.AlignPosition.Enabled = false
						Character.AlignPosition.Responsiveness = OldResponsive
						bools.IsDodging = false
					end
				
				elseif (not bools.Debounce or (DataValues.AccInfo.Vestiges and table.find(DataValues.AccInfo.Vestiges, 1)) or DataValues.AccInfo.CurrentClass == "DarwinB") and not bools.IsDodging and not bools.IsUltimate and not bools.IsBlocking  then
					--bools.Debounce 			= true
			--[[		if Character.Animate.attackY:FindFirstChild("Y1") then
						GUI.Main.GameGUI.PlayerCommands.Left.RMB.Visible = true
						GUI.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y1"].img.Value
					end--]]

					if Values.Stamina.Value < 1 then
						local Left = PlayerUI.Left
						local Chain = Left.Template.Chain:Clone()
						Chain.Message.Text = string.format("Out of stamina!", Numbers.Combo)
						Chain.Visible = true
						Chain.Parent = Left.StatusEffects
						Debris:AddItem(Chain, 2.5)
						TweenService:Create(Chain.warning, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
						TweenService:Create(Chain.warning2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {ImageTransparency = 0.3}):Play()
						TweenService:Create(Chain.Message, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {TextTransparency = 0.3}):Play()
						TweenService:Create(Chain.Message.Bar, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.3}):Play()
						TweenService:Create(Chain.Message.Bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
						return
					end
					
					if Character.Animate:FindFirstChild("attackdodge") then
						bools.LeftMouseButtonDown = false
						bools.IsDodging 		= true
						bools.TPS				= false
						GUI.Main.GameGUI.Crosshair.Visible = false
						AnimManage:RestoreAnimations()
						Objs.AnimTrack 			= Humanoid:LoadAnimation(Character.Animate.attackdodge["Dodge"])
				--		Humanoid.WalkSpeed 	= Humanoid.WalkSpeed + 40
				--		AnimManage:StopAllAnimations()
						Humanoid.AutoRotate = false
						Character.Animate.Bindables.Cancel:Fire()
						Objs.AnimTrack			:Play()
						Objs.AnimTrack.KeyframeReached:Connect(function(KeyFrame)
							if KeyFrame == "Dodge" then
								local MoveVector = controls:GetMoveVector()
								if MoveVector.Magnitude > 0 then
									local RollDir = CAMERA.CFrame:VectorToWorldSpace(MoveVector)
									Character.PrimaryPart.CFrame = CFrame.new(Character.PrimaryPart.Position, Character.PrimaryPart.Position + RollDir)
								end
								local y = Instance.new("BodyVelocity")
								y.Name = "BV"
								y.maxForce = Vector3.new(49999, 3, 49999)
								y.velocity = Character.PrimaryPart.CFrame.LookVector*40
								y.Parent = Character.PrimaryPart
								Debris:AddItem(y,.4)	
							end
							if KeyFrame == "Dodging" or KeyFrame == "AnimationEnd" then
								Humanoid.AutoRotate = true
								if Humanoid.WalkSpeed >= Numbers.CombatWalkSpeed or Humanoid.WalkSpeed == 3 or Humanoid.WalkSpeed == 40 then
									Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
								end
								Objs.AnimTrack:Stop()
						--		AnimManage:RestoreAnimations(false)
								bools.Debounce = false
								bools.IsBlocking = false
								bools.IsDodging = false
							end
						end)
						Objs.AnimTrack.Stopped:Connect(function()
							if Humanoid.WalkSpeed >= Numbers.CombatWalkSpeed then
								Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
							end
						end)--[[
						wait(Objs.AnimTrack.Length)
						if bools.IsDodging then
							bools.IsDodging = false
						end--]]
					end
				end
			end
			if KeyCode == DataValues.CurrentController.LShift then
				DataValues.Last_Y = Character.PrimaryPart.Position.Y
				if not bools.IsBlocking and not bools.IsUltimate then
					if Character.Animate:FindFirstChild("attackblock") then
						local conn, BlockPart, blocked = false
						local function resetBlock()
							if not blocked then
								FS.spawn(function()
									if BlockPart then
										TweenService:Create(BlockPart, TweenInfo.new(.1), {Transparency = 1}):Play()
										wait(.1)
										BlockPart:Destroy()
									end
								end)
								conn:Disconnect()
								if Humanoid.WalkSpeed == 0 then
									Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
								end
								bools.Debounce 	= false
								AnimManage:RestoreAnimations()
								bools.IsBlocking = false
							end
						end
						AnimManage:StopAllAnimations()
						bools.Debounce = true
						bools.IsBlocking = true
						bools.IsDodging = false
						bools.TPS = false
						Humanoid.WalkSpeed 	= 0
						Character.Animate.Bindables.Cancel:Fire()
						Objs.AnimTrack = Humanoid:LoadAnimation(Character.Animate.attackblock["Block"])
						Objs.AnimTrack:Play()
						Objs.AnimTrack.KeyframeReached:Connect(function(KeyFrame)
							if KeyFrame == "ParryStance" then
								Socket:Emit("Blocking")
								BlockPart = ReplicatedStorage.Models.Misc.Shield:Clone()
								local Weld = Instance.new("Weld")
								BlockPart.CFrame = Character.PrimaryPart.CFrame
								Weld.Part0 = Character.PrimaryPart
								Weld.Part1 = BlockPart
								Weld.Parent = BlockPart
								BlockPart.Parent = Character
								Debris:AddItem(BlockPart, 20)
								TweenService:Create(BlockPart, TweenInfo.new(.1), {Transparency = 0}):Play()
								wait(1.9)
								TweenService:Create(BlockPart, TweenInfo.new(.1), {Transparency = 1}):Play()
							elseif KeyFrame == "BlockEnd" then
								resetBlock()
								blocked = true
							end
						end)
						conn = Character.PrimaryPart.ChildAdded:Connect(function(Object)
							if Object.Name == "BVKnockback" then
								resetBlock()
								blocked = true
							elseif Object.Name == "TargetBlock" or Object.Name == "TargetParry" then
								local Center = BlockPart[Object.Name == "TargetBlock" and "BlockFX" or "ParryFX"]
								local Sound = ReplicatedStorage.Sounds.SFX[Object.Name == "TargetBlock" and "Block" or "PerfectBlock"]
								Sound.PitchShiftSoundEffect.Octave = Random.new():NextNumber(0.75, 1)
								Center.Parent = workspace.Terrain
								Debris:AddItem(Center, 3)
								Center.WorldCFrame = CFrame.new(Character.PrimaryPart.Position, Object.Value) * CFrame.Angles(math.rad(-90), 0, 0)
								Sound:Play()
								for _, effect in ipairs(Center:GetChildren()) do
									FS.spawn(function()
										effect.Enabled = true
										wait(.15)
										effect.Enabled = false
									end)
								end
							end
						end)
					end
				end
			end
			--[[if KeyCode == DataValues.CurrentController.F then
				if not bools.IsDodging and not bools.IsUltimate and not bools.Debounce then
					AnimManage:StopAllAnimations()
					bools.Debounce 	= true
					Humanoid.WalkSpeed = 0
					Objs.AnimTrack 	= Humanoid:LoadAnimation(Character.Animate.attacked["X3"])
					Objs.AnimTrack:Play()
					Objs.AnimTrack.Stopped:connect(function()
						if Humanoid.WalkSpeed < 20 then
							Humanoid.WalkSpeed = 20
						end
						AnimManage:RestoreAnimations(false)
						bools.Debounce = false
					end)
				end
			end--]]
			if KeyCode == DataValues.CurrentController.X then
				if Objs.LockOn == nil then
					local FocusPoint = Character.HumanoidRootPart.Position
					local NearestTorso,Proximity = nil,100
					for _, enemies in ipairs(DataValues.Enemies) do
						if enemies.HRP then
							local Distance = (enemies.HRP.Position - FocusPoint).Magnitude
							if Distance < Proximity then
								NearestTorso = enemies.HRP
								Proximity = Distance
							end
						end
					end
					Objs.LockOn = NearestTorso
					local LockonGui = ReplicatedStorage.GUI.BillboardGui.LockOn:Clone()
					LockonGui.Adornee = NearestTorso
					LockonGui.Parent = NearestTorso
				else
					if Objs.LockOn:FindFirstChild("LockOn") then
						Objs.LockOn.LockOn:Destroy()
					end
					Objs.LockOn = nil
				end
			end
			if KeyCode == DataValues.CurrentController.ItemUse1 then
				Socket:Emit("ItemUse", "Potion")
			elseif KeyCode == DataValues.CurrentController.ItemUse2 then
				Socket:Emit("ItemUse", "PotionStamina")
			end
		end
	end
end

function OnKeyUp(InputObject, GameProcessedEvent)
	if not bools.ded and DataValues.CameraEnabled then
		local KeyCode 		= InputObject.KeyCode
		local UserInputType = InputObject.UserInputType
		if DataValues.WatchedIntro then
			if KeyCode == DataValues.CurrentController.Tab then
				bools.HoldingDownTab = false
				TweenService:Create(GUI.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,1,0)}):Play()
				for _,word in next, GUI.Main.Tutorial.Combat:GetChildren() do
					if word:IsA("TextLabel") then
						word.TextTransparency = 1
						word.TextStrokeTransparency = 1
					end
				end
				TweenService:Create(GUI.Main.Tutorial.Combat, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
			end
			if PLAYER.TeamColor ~= Teams.Lobby.TeamColor and bools.Stunned == false and not bools.ChatEnabled then --In Dungeons
				if UserInputType == DataValues.CurrentController.MouseButton1 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton1) then
					bools.LeftMouseButtonDown = false
					bools.RightMouseButtonDown = false
				end
				if UserInputType == DataValues.CurrentController.MouseButton2 or ((DataValues.ControllerType == "Controller" or DataValues.ControllerType == "Touch") and KeyCode == DataValues.CurrentController.MouseButton2) then
					bools.LeftMouseButtonDown = false
					if bools.RightMouseButtonDown and Objs.AnimTrack ~= nil then
						bools.RightMouseButtonDown = false
						Objs.AnimTrack:AdjustSpeed(1)
					end
					if bools.TPS and bools.Debounce then
						Socket:Emit("A", CAMERA.CFrame)
						GUI.Main.GameGUI.Crosshair.Visible = false
						bools.Debounce = false
						bools.TPS = false
						Character.UpperTorso.Waist.C0 = Character.backup.C0
						if Humanoid.WalkSpeed == 3 then
							Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
						end
						Objs.AnimTrack:AdjustSpeed(1)
					end
				end
				if KeyCode == DataValues.CurrentController.Q then
					--
				end
				if KeyCode == DataValues.CurrentController.Z then
					--
				end
				if KeyCode == DataValues.CurrentController.LShift then
					if bools.Debounce and bools.IsBlocking then
						if Objs.AnimTrack then
							Socket:Emit("StopBlocking")
							Objs.AnimTrack.TimePosition = 0.98 * Objs.AnimTrack.Length
						end
					end
				end
			end
		end
	end
end

function InputChanged(object)
	if DataValues.CameraEnabled then
		local CanRotateCamera = true
		if object.UserInputType == Enum.UserInputType.MouseMovement or object.UserInputType == Enum.UserInputType.Touch then
			if object.UserInputType == Enum.UserInputType.Touch then

				if object.Position.X < GUI.Main.AbsoluteSize.X*.5 or GUI.PlayerCardInspect.Enabled then
					CanRotateCamera = false
				end

				if DataValues.ControllerType ~= "Touch" then
					RainAPI:StopRain()
					DataValues.ControllerType = "Touch"
					DataValues.CurrentController = ControllerMapping
					local JumpButton = GUI:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
					CAS:BindAction("MouseButton1", MobileControls, true)
					CAS:SetPosition("MouseButton1", UDim2.new(0, JumpButton.AbsolutePosition.X - ((JumpButton.AbsoluteSize.X/4) * 1.8), 0, JumpButton.AbsolutePosition.Y - ((JumpButton.AbsoluteSize.Y/2)*1.1)))
					CAS:SetTitle("MouseButton1", "LB")
					local MouseButton1 = CAS:GetButton("MouseButton1")
					MouseButton1.Size = UDim2.new(0, (JumpButton.Size.X.Offset / 4) * 2.5, 0, (JumpButton.Size.Y.Offset / 4) * 2.5) 
					CAS:BindAction("MouseButton2", MobileControls, true)
					CAS:SetPosition("MouseButton2", UDim2.new(0, JumpButton.AbsolutePosition.X - ((JumpButton.AbsoluteSize.X/2)*-.7), 0, (JumpButton.AbsolutePosition.Y - ((JumpButton.AbsoluteSize.Y/4) * 3))))
					CAS:SetTitle("MouseButton2", "RB")
					local MouseButton2 = CAS:GetButton("MouseButton2")
					MouseButton2.Size = UDim2.new(0, (JumpButton.Size.X.Offset / 4) * 2.5, 0, (JumpButton.Size.Y.Offset / 4) * 2.5) 
					CAS:BindAction("CC", MobileControls, true)
					CAS:SetPosition("CC", UDim2.new(0, JumpButton.AbsolutePosition.X - ((JumpButton.AbsoluteSize.X/4) * 3), 0, JumpButton.AbsolutePosition.Y - ((JumpButton.AbsoluteSize.Y/2)*-.5)))
					CAS:SetTitle("CC", "Dodge")
					local CC = CAS:GetButton("CC")
					CC.Size = UDim2.new(0, (JumpButton.Size.X.Offset / 4) * 2.5, 0, (JumpButton.Size.Y.Offset / 4) * 2.5) 
					CAS:BindAction("LShift", MobileControls, true)
					CAS:SetTitle("LShift", "Block")
					CAS:BindAction("Tab", MobileControls, true)
					CAS:SetTitle("Tab", "Tab")
					local TB = CAS:GetButton("Tab")
					TB.Parent = GUI.Main.MobileControls.Tab
					CAS:SetPosition("Tab", UDim2.new(0,0,0,0))
					TB.Size = UDim2.new(0, (JumpButton.Size.X.Offset / 4) * 2.5, 0, (JumpButton.Size.Y.Offset / 4) * 2.5) 
					local BL = CAS:GetButton("LShift")
					BL.Parent = GUI.Main.MobileControls.Block
					CAS:SetPosition("LShift", UDim2.new(0,0,0,0))
					BL.Size = UDim2.new(0, (JumpButton.Size.X.Offset / 4) * 2.5, 0, (JumpButton.Size.Y.Offset / 4) * 2.5) 
					Numbers.SENSITIVITY = .3
					local Frame = MouseButton1.Parent
					Frame.Position = UDim2.new(0,0,0,0)
					Frame.Size = UDim2.new(1,0,1,0)
					
					NEWMENU.EditWindow.Skills.Buttons.Passives.Size = UDim2.new(0.3, 0, 1, 0)
					NEWMENU.EditWindow.Skills.Buttons.Actives.Size = UDim2.new(0.3, 0, 1, 0)
					NEWMENU.EditWindow.Skills.Inventory.UIGridLayout.CellSize = UDim2.new(1, 0, 0, 200)
					NEWMENU.OuterFrame.Outlines.LineBottomNav.Size = UDim2.new(0.37, 0, 0, 1)
					NEWMENU.OuterFrame.Outlines.LineBottomNav.Position = UDim2.new(0.15, 0, 0.14, 0)
					NEWMENU.OuterFrame.Texter.NavButtonSelection.Size = UDim2.new(0.18, 0, 0, 30)
					NEWMENU.OuterFrame.Texter.NavButtonSelection.Position = UDim2.new(0.15, 0, 0.05, 0)
					NEWMENU.OuterFrame.Texter.SubSelection.Size = UDim2.new(0.35, 0, 0, 25)
					NEWMENU.OuterFrame.Texter.SubSelection.Position = UDim2.new(0.15, 0, 0.14, 0)
					NEWMENU.OuterFrame.Buttons.Position = UDim2.new(0.05, 0, 0.05, 0)
					NEWMENU.OuterFrame.Buttons.Size = UDim2.new(0.065, 0, 0.8, 0)
					NEWMENU.OuterFrame.ContentWindow.Position = UDim2.new(0.1, 0, 0.15, 25)
					NEWMENU.OuterFrame.ContentWindow.Size = UDim2.new(0.9, 0, 0.65, 0)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Position = UDim2.new(0.2, 0, 0, 0)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Size = UDim2.new(0.6, 0, 1, 0)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Position = UDim2.new(0, 0, 0.4, 0)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Size = UDim2.new(0.4, 0, 0.2, 0)
					NEWMENU.OuterFrame.ContentWindow.Achievements.Position = UDim2.new(0.05, 0, 0, 0)
					NEWMENU.OuterFrame.ContentWindow.Achievements.Size = UDim2.new(0.9, 0, 1, 0)
					for _, Objects in ipairs(NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats:GetChildren()) do
						Objects.Parent = NEWMENU.OuterFrame.ContentWindow.Character.Info.StatsSCROLL
						if Objects:IsA("UIListLayout") then
							Objects.Padding = UDim.new(0, 7)
						end
					end
					NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.Name = "Old"
					NEWMENU.OuterFrame.ContentWindow.Character.Info.StatsSCROLL.Visible = true
					NEWMENU.OuterFrame.ContentWindow.Character.Info.StatsSCROLL.Name = "Stats"
				end
			else
				if HeartBeat ~= nil and DataValues.ControllerType == "Keyboard" then
					HeartBeat:Disconnect()
					HeartBeat = nil
					print("Removed Polling for existing Controller")
					GUI:WaitForChild("Chat").Enabled = true
				end
			end
			if CanRotateCamera then
				object.Delta 	= object.Delta * Numbers.SENSITIVITY 
				local newY 		= 0
				local newX 		= 0

				if table.find(constrainedCameraPlaces, game.PlaceId) and PLAYER.TeamColor == Teams.Lobby.TeamColor  then
					newX = constrain(DataValues.cameraAngles.X - rad(object.Delta.X), Numbers.MAX_LEFT, Numbers.MAX_RIGHT)
					newY = constrain(DataValues.cameraAngles.Y - rad(object.Delta.Y), Numbers.MAX_DOWN/4, Numbers.MAX_UP/4)
				else
					local MaxDown, MaxUp = rad(0), rad(0)
					newX = DataValues.cameraAngles.X - rad(object.Delta.X)
					
					if bools.TPS or DataValues.CurrentController == "Keyboard" then
						MaxDown = Numbers.MAX_DOWN
						MaxUp = Numbers.MAX_UP
					else
						MaxDown = Numbers.MAX_DOWN/5
						MaxUp = Numbers.MAX_UP/5
					end

					newY = constrain(DataValues.cameraAngles.Y - rad(object.Delta.Y), MaxDown, MaxUp)
				end

				DataValues.cameraAngles 	= Vector2.new(newX, newY)
			end
		end
	end
	if object.UserInputType == Enum.UserInputType.Gamepad1 then
		if object.KeyCode == Enum.KeyCode.Thumbstick2 then
			if HeartBeat == nil and DataValues.ControllerType == "Controller" then
				for _, input in pairs(UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)) do
					gamePadInputs[input.KeyCode] = input
				end
				HeartBeat = RunService.Heartbeat:Connect(function()
					Numbers.MovementThumbstick 	= gamePadInputs[Enum.KeyCode.Thumbstick1].Position
					Numbers.CameraThumbstick 		= gamePadInputs[Enum.KeyCode.Thumbstick2].Position
					local angle = math.deg(math.atan2(Numbers.MovementThumbstick.X, Numbers.MovementThumbstick.Y))
					if Numbers.MovementThumbstick.X > .3 or Numbers.MovementThumbstick.X < -.3 or Numbers.MovementThumbstick.Y > .3 or Numbers.MovementThumbstick.Y < -.3 then
						Stickdir = convert(angle, gamePadInputs[Enum.KeyCode.Thumbstick1].Delta)
					end
					local delta			= Numbers.CameraThumbstick*(Numbers.SENSITIVITY*Numbers.CSENSITIVITY)
					local newY 			= 0
					local newX 			= 0
					if convert(math.deg(math.atan2(Numbers.CameraThumbstick.X, Numbers.CameraThumbstick.Y)), gamePadInputs[Enum.KeyCode.Thumbstick2].Delta) ~= "None" then
						if PLAYER.TeamColor ~= Teams.Lobby.TeamColor then
							newX = DataValues.cameraAngles.X - rad(delta.X)
							newY = constrain(DataValues.cameraAngles.Y - rad(-delta.Y), Numbers.MAX_DOWN, Numbers.MAX_UP+rad(40))
						else
							newX = constrain(DataValues.cameraAngles.X - rad(delta.X), Numbers.MAX_LEFT, Numbers.MAX_RIGHT)
							newY = constrain(DataValues.cameraAngles.Y - rad(-delta.Y), Numbers.MAX_DOWN/4, Numbers.MAX_UP/4)
						end
						DataValues.cameraAngles 		= Vector2.new(newX, newY)
					end
				end)
				print("Created Polling for new controller")
			end
		end
	end
end

UserInputService.InputBegan:Connect(OnKeyDown)
UserInputService.InputEnded:Connect(OnKeyUp)
UserInputService.InputChanged:Connect(InputChanged)
PLAYER.CharacterAdded:Connect(OnRespawn)
ReplicatedStorage.PlayerValues.ChildAdded:Connect(CheckForNewPlayerValue)

return nil