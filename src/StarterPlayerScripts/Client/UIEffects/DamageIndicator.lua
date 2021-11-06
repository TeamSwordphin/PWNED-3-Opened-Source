-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")
local TweenService		= game:GetService("TweenService")
local Debris			= game:GetService("Debris")
local RunService		= game:GetService("RunService")


-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")


-- << Modules >> --
local DataValues 	= require(CLIENT.DataValues)
local round			= require(CLIENT.UIEffects.RoundNumbers)
local showS 		= require(CLIENT.UIEffects.NumbersFlair)
local FS 		  	= require(ReplicatedStorage.Scripts.Modules.FastSpawn)


-- << Variables >> --
local bools 	= DataValues.bools
local Ticks		= DataValues.Ticks
local Objs 		= DataValues.Objs
local Numbers 	= DataValues.Numbers
local Options	= DataValues.Options
local PlayerUI 	= GUI.Main.GameGUI.PlayerUI
local Character	= PLAYER.Character or PLAYER.CharacterAdded:Wait()


-- << Lua Functions >> --
local Rand 	= Random.new
local Insta	= Instance.new
local TIN 	= TweenInfo.new
local UDi	= UDim2.new
local CFNew	= CFrame.new
local CFAng	= CFrame.Angles
local rad	= math.rad
local tbi	= table.insert
local Vec3	= Vector3.new
local Floor	= math.floor
local RGB	= Color3.fromRGB

----------------------
function OnRespawn(character)
	Character = character
end

PLAYER.CharacterAdded:Connect(OnRespawn)

return function(strings, damageValue, Target, ComboCount, crit)
	local Damager 				= ReplicatedStorage.GUI.BillboardGui.Damager:Clone()
	local mx 					= Rand():NextNumber(-30,30)*.01
	local my 					= Rand():NextNumber(25,45)*-.01
	local p						= Insta("Attachment")
	p.Position					= Target.Position
	Damager.TextLabel.Position 	= UDi(mx,0,my,0)
	Damager.Parent 				= p
	Damager.Adornee				= p
	p.Parent					= game.Workspace.Terrain
	Debris:AddItem(p, 3.5)
	local Slash = nil
	local SlashArcs = {}
	if not strings then
		if Target ~= Character.HumanoidRootPart then
			Slash = DataValues.SlashPool:GetPart()
			if Slash ~= nil then
				local CF = Target.CFrame * CFNew(Rand():NextNumber(-2,2), Rand():NextNumber(-.5,1.5), Rand():NextNumber(-3,0)) * CFAng(rad(Rand():NextNumber(-30,10)),rad(Rand():NextNumber(-20,20)), rad(Rand():NextNumber(-20,21)))
				Slash.CFrame = CF
				Slash.Transparency = 0.35
				TweenService:Create(Slash, TIN(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CFrame = CF, Size = Vec3(0,0,0), Transparency = 1}):Play()	
			end
			if DataValues.ControllerType ~= "Touch" then
				FS.spawn(function()
					for i = 1, Rand():NextInteger(2,3) do
						local SlashArc = DataValues.SlashArcPool:GetPart()
						if SlashArc then
							local CF = CFNew(Target.Position, Character.PrimaryPart.Position) * CFAng(rad(Rand():NextNumber(-40,20)),rad(Rand():NextNumber(-40,40)),rad(Rand():NextNumber(-90,90)))
							SlashArc.CFrame = CF
							local RandomInitialSize = Rand():NextNumber(5,12)
							SlashArc.Size = Vector3.new(RandomInitialSize,.05,RandomInitialSize)
							local Size = Rand():NextNumber(5,25)
							local SizeX = Rand():NextNumber(12,25)
							local SizeZ = Rand():NextNumber(20,35)
							local Timer = Rand():NextNumber(.25,.35)
							TweenService:Create(SlashArc, TIN(Timer,Enum.EasingStyle.Quart), {CFrame = SlashArc.CFrame*CFNew(0,0,Size*(1+Timer)), Size=Vec3(SizeX,.05,SizeZ)}):Play()
							FS.spawn(function()
								local TimerWait = Timer*.6
								wait(TimerWait)
								TweenService:Create(SlashArc, TIN(Timer-TimerWait,Enum.EasingStyle.Linear), {Transparency = 1}):Play()
							end)
							tbi(SlashArcs, SlashArc)
							wait(.05)
						end
					end
				end)
			end
		end
		
		local Sound = ReplicatedStorage.Sounds.SFX.SwordSlash
		local Copy = Sound:Clone()
		local RNG2 = Rand():NextNumber(1, 1.35)
		Copy.PlaybackSpeed = RNG2
		local RNG = Rand():NextNumber(.7, 1.4)
		Copy.PitchShiftSoundEffect.Octave = RNG
		Copy.Parent = Target
		Copy:Play()
		Debris:AddItem(Copy, Copy.TimeLength)
		
		Ticks.Combo_Time = tick()
		local val = math.min(1.75, 1+(ComboCount * 0.002))
		PlayerUI.Left.ComboCounter.NumberValue.Value = Floor(ComboCount)
		PlayerUI.Left.ComboCounter.Counter.Text = Floor(ComboCount)
		PlayerUI.Left.ComboCounter.DamageIncrease.Text = string.format("ATKx%s", round(val, 2))
		if Objs.ComboTextSize == nil then
			Objs.ComboTextSize = PlayerUI.Left.ComboCounter.NumberValue.Changed:connect(function()
				for i = 1,5,1 do RunService.RenderStepped:wait()
					PlayerUI.Left.ComboCounter.Counter.TextSize 	= 100-(6*i)
				end
				PlayerUI.Left.ComboCounter.Counter.TextSize 		= 60
			end)
		end
		if crit then
			Damager.TextLabel.TextColor3 = RGB(255, 247, 124)
		end
	else
		if Objs.ComboTextSize then
			Objs.ComboTextSize:Disconnect()
		end
	end
	if Options.DamageIndicator then
		if strings then
			Damager.TextLabel.Text = damageValue
			wait(1)
		else
			showS( Damager.TextLabel, 0, damageValue, Numbers.duration, Numbers.fps )
			if Options.CumulativeNum then
				if not Target:FindFirstChild("Damager") then
					local MaxDamager				= Damager:clone()
					local Num						= Insta("NumberValue")
					MaxDamager.AlwaysOnTop			= true
					MaxDamager.TextLabel.Position 	= UDi(0,0,-0.6,0) -- -.45
					MaxDamager.TextLabel.ZIndex 	= 10
					MaxDamager.TextLabel.TextColor3 = RGB(255, 249, 158)
					MaxDamager.TextLabel.TextSize 	= 76
					Num.Name 						= "NumberValue"
					Num.Value						= damageValue
					Num.Parent 						= MaxDamager
					MaxDamager.Adornee				= Target
					MaxDamager.Parent 				= Target
					Debris:AddItem(MaxDamager, 2.5)
					showS( MaxDamager.TextLabel, 0, damageValue, Numbers.duration, Numbers.fps )
					wait(1)
					if MaxDamager and MaxDamager:findFirstChild("TextLabel")  then
						TweenService:Create(MaxDamager.TextLabel, TIN(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0, 0, -0.55, 0), TextTransparency = 1, TextStrokeTransparency = 1}):Play()
					end
				else
					if Target.Damager:FindFirstChildOfClass("NumberValue") then
						local MaxDamager								= Target.Damager:clone()
						local Num										= MaxDamager.NumberValue
						local oldDamage 								= Num.Value
						Num.Value 										= Num.Value + damageValue
						MaxDamager.TextLabel.TextTransparency 			= 0
						MaxDamager.TextLabel.TextStrokeTransparency 	= 0
						MaxDamager.Adornee								= Target
						MaxDamager.Parent 								= Target
						Target.Damager									:Destroy()
						Debris											:AddItem(MaxDamager, 2.5)
						showS( Target.Damager.TextLabel, oldDamage, oldDamage+damageValue, Numbers.duration*.5, Numbers.fps )
						wait(1)
						if MaxDamager and MaxDamager:findFirstChild("TextLabel") then
							TweenService:Create(MaxDamager.TextLabel, TIN(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0, 0, -0.55, 0), TextTransparency = 1, TextStrokeTransparency = 1}):Play()
						end
					end
				end
			else
				wait(2)
			end
		end
		if Damager and Damager:FindFirstChild("TextLabel")  then
			TweenService:Create(Damager.TextLabel, TIN(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDi(mx, 0, my-.1, 0), TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		end
	else
		Damager = nil
	end
	if Slash ~= nil then
		DataValues.SlashPool:ReturnPart(Slash)
		Slash.Size = Vec3(46.647, 0.388, 0.305)
		Slash.Transparency = 0.2
	end
	if #SlashArcs >= 1 then
		for _,SlashArc in ipairs(SlashArcs) do
			if SlashArc then
				DataValues.SlashArcPool:ReturnPart(SlashArc)
				SlashArc.Size = Vec3(12, 0.05, 12)
				SlashArc.Transparency = 0.4
			end
		end
	end
end
