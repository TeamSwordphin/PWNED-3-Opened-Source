-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- << Main Variables >> --
local CLIENT 	= script.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PartCache	= require(ReplicatedStorage.Scripts.Modules.PartCache)
local IsPrivateServer = ReplicatedStorage.SERVER_STATS:WaitForChild("IsPrivateServer").Value

if game.PlaceId == 785484984 or game.PlaceId == 563493615 then
	IsPrivateServer = true
end

-- << Valeri Part >> --
local ValeriLaser = MODULES.Effects.MiscEffects.ValeriBeam:Clone()

local GUID =  Instance.new("StringValue")
	GUID.Name = "StringValue"
	GUID.Value = ""
	GUID.Parent = ValeriLaser

--------------------------

local data = {
	
	-- << Non-changing Values >> --
	CAMERAOFFSET = Vector3.new(0,2,25),
	CameraEnabled = true,
	SpectatingLastUpdatePosition = nil,
	SpectatingTarget = nil, ---- player object
	
	-- << Hotkeys >> --
	LastSelected = nil, --- Controller SelectedObject
	CurrentController = nil,
	ControllerType = "Keyboard",
	KeyboardMapping = {
		ItemUse1		= Enum.KeyCode.One,
		ItemUse2		= Enum.KeyCode.Two,
		E 				= Enum.KeyCode.E, 		--Confirm
		N 				= Enum.KeyCode.N, 		--Selection
		Q 				= Enum.KeyCode.Q, 		--Ultimate
		Y 				= Enum.KeyCode.Y, 		--Selection
		Z 				= Enum.KeyCode.Z, 		--Cry Form
		X				= Enum.KeyCode.X,		--LockOn
		F				= Enum.KeyCode.F,		--Grab
		T				= Enum.KeyCode.T,		--Emote (Nitro only)
		Space 			= Enum.KeyCode.Space, 	--Jump
		LShift 			= Enum.KeyCode.LeftShift,--Block/Parry
		CC 				= Enum.KeyCode.C,		-- Dodge
		MouseButton1 	= Enum.UserInputType.MouseButton1,
		MouseButton2 	= Enum.UserInputType.MouseButton2,
		Tab				= Enum.KeyCode.Tab
	},
	ControllerMapping 	= {
		ItemUse1		= Enum.KeyCode.DPadUp,
		ItemUse2		= Enum.KeyCode.DPadRight,
		E 				= Enum.KeyCode.ButtonA,
		N 				= Enum.KeyCode.ButtonB,
		Q 				= Enum.KeyCode.ButtonR1,
		Y 				= Enum.KeyCode.ButtonA,
		Z 				= Enum.KeyCode.ButtonL1,
		X				= Enum.KeyCode.ButtonR3,
		F				= Enum.KeyCode.ButtonR2,
		T				= Enum.KeyCode.T,		--Emote (Nitro only)
		Space 			= nil, --unused
		LShift 			= Enum.KeyCode.ButtonL2,
		CC 				= Enum.KeyCode.ButtonB,	--dodge
		MouseButton1 	= Enum.KeyCode.ButtonX,
		MouseButton2 	= Enum.KeyCode.ButtonY,
		Tab				= Enum.KeyCode.ButtonSelect
	},
	
	-- << Option >> --
	Options = {
		RainEffects		= true, 
		NumberAnim		= true, 
		CumulativeNum	= true, 
		DamageIndicator = true,
		ParticleEffects	= true, 
		PlayMusic		= true,
		PopperCam		= true,
		CameraSmoothing = 1,
		LobbyFov 		= 70,
		CombatFov		= 70,
		LobbyShadowSmall	= true,
		LobbyShadowMedium 	= true,
		LobbyShadowLarge 	= true,
	},
	
	-- << Helper Variables >> --
	Objs = {
		CurrentClass			= nil,
		CurrentLevel			= nil,
		CurrentStaminaRate		= nil,
		AnimTrack				= nil,
		ComboTextSize			= nil,
		LockOn					= nil,
		TextObj					= nil,
		Crosshair				= Vector3.new(),
		ShopObj					= nil,
		Wall = nil,
		WallNormal = nil,
		WallPos = nil,
		Dir = nil,
		W = nil
	},
	bools = {
		InSoloPlace				= false,
		LowHPWarning			= false,
		Skip					= false,
		InDialogue				= false,
		ded						= false,
		HealthDebounce			= false,
		Debounce				= false,
		IsBlocking				= false,
		IsDodging				= false,
		IsUltimate				= false,
		IsCryForm				= false,
		IsSpecial				= false,
		Stunned					= false,
		NewPlayer				= false,
		JustCameIn				= true,
		TPS						= false,
		HoldingDownTab			= false,
		ShowText				= 0,
		LeftMouseButtonDown 	= false,
		RightMouseButtonDown 	= false,
		InConfirm 				= false,
		CanConfirm				= false,
		ChatEnabled				= false,
		OpenShop				= false,
		PlayingUltimate			= false,
		PlayingTutorial			= false,
		Reserved				= false,
		CanWallRun				= false,
		SellMode				= false,
		CanLoad					= false,
		JumpRequest 			= false,
		OpeningMenu				= false
	},
	Ticks = {
		Last_Flashing			= tick(),
		StaminaRate				= tick(),
		Combo_Time				= tick(),
		Last_Combo				= tick(),
		HPHurt					= tick(),
		updatePlayerStatus		= tick(),
		FloatTime				= tick(),
		Flickertick				= tick(),
		LightingTick			= tick(),
		TrainTick				= tick(),
		Notification			= tick(),
		MoteTimer				= 0,
		UnderbarTimer			= 0,
		TurnEmit				= os.time(),
		BuyCooldown				= os.time(),
		SlideTimer = 0,
		WallCooldown = 0
	},
	Numbers = {
		TrainNum 				= 0,
		duration 				= 500,
		fps 					= 30,
		MAXV3 					= Vector3.new(1,1,1)*math.huge,
		OFFSET 					= Vector3.new(0,3.5,-20),
		LobbyFov				= 70,
		CombatFov				= 70,
		UltimateBar				= 0,
		SpecialBar				= 0,
		Combo					= 1,
		ComboWindow				= 0.95,
		BlockSpeed				= 3.5,
		MaxCC					= 0,
		CritWounds				= 0,
		OriginalMaxHP			= 100,
		ShieldHP				= 0,
		ShieldMaxHP				= 0,
		Att						= 1,
		Fatigued				= 0,
		oldScale				= 0.96,
		SENSITIVITY 			= 0.2,				-- mouse only
		CSENSITIVITY			= 14,
		MovementThumbstick		= Vector3.new(),
		CameraThumbstick 		= Vector3.new(),
		TutorialRad				= 0,
		MAX_UP 					= math.rad(290),  ---- default 80
		MAX_DOWN 				= math.rad(-270),
		MAX_LEFT				= math.rad(175), --155
		MAX_RIGHT				= math.rad(185), --205
		RaycastDistance 		= 3.25,
		SkillCounter			= 1,
		LobbyWalkSpeed			= 16,
		CombatWalkSpeed			= 20,
		ChainCooldowns			= nil
	},
	
	-- << Cache >> --
	AccInfo = nil,
	CharInfo = nil,
	Inputs = nil,
	WatchedIntro = false,
	MenuOpening = false,
	state = "",
	Last_Y = 0,
	Enemies = {},
	Bullets = {},
	cameraAngles = Vector2.new(),
	AnimationsPreloaded = {},
	
	-- << Input Handlers >> --
	StatInputs = {},
	SkillInputs = {},
	Norm = {},
	InventoryInputs = {},
	SellObjs = {},
	CurrentSelectedSkill = nil,
	CurrentSelectedCostume = nil,
	ReforgeMode = false,
	ReforgeQueue = {},
	CurrentObj = nil,
	CurrentButt = nil,
	ReforgeButt = {},
	LearnInputs = {},
	SettingInputs = {},
	LastChatTime = 0,
	
	-- << Instance Pooling >> --
	AlignPositionAttachment = Instance.new("Attachment", workspace.Terrain),
	BulletPool = IsPrivateServer and PartCache.new(ReplicatedStorage.Models.Misc.BulletBall, 500),
	DeflectPool = IsPrivateServer and PartCache.new(MODULES["Effects"].HitEffects.Slash.Deflect, 50),
	SlashPool = IsPrivateServer and PartCache.new(MODULES["Effects"].HitEffects.Slash.Slash, 50),
	SlashArcPool = IsPrivateServer and PartCache.new(MODULES["Effects"].HitEffects.Slash.SlashArc, 50),
	ValeriBeamsPool = IsPrivateServer and PartCache.new(ValeriLaser, 150),
	ActiveValeriBeams = {}
}

data.CurrentController = data.KeyboardMapping

return data
