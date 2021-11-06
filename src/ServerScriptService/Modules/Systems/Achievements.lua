--[[ PLUGIN USERS README HERE:

If you clicked the question mark and this script popped up, then read here. The correct syntax for achievements is:

{"V":0,"C":0,"I":27}

V stands for value, or the current progress.
C stands for completed. 0 = incomplete, 1 = completed.
I stands for the achievement ID (as defined below).

How it works is the script checks for the achievement using the I to see if it matches with any ID below. If it does, then it
it will check if V is over or equal to the achievement's MaxValue. If it is, mark the achievement as completed, and erase the V variable to save space.

If you want to force complete an achievement, it is recommended to only set the V value to equal the MaxValue instead of writing C to 1 manually. This way, 
the game can clean up the data properly the next time you log into the game.


]]---

local module = {}

local AchievementsChart = {
	{
		ID = 1,
		Name = "Own 2 Characters",
		MaxValue = 1,
		Reward = {
			Tears = 100
		}
	},
	{
		ID = 2,
		Name = "Own 3 Characters",
		MaxValue = 1,
		Reward = {
			Tears = 100
		}
	},
	{
		ID = 3,
		Name = "Own 5 Characters",
		MaxValue = 1,
		Reward = {
			Tears = 100
		}
	},
	{
		ID = 4,
		Name = "Own 10 Characters",
		MaxValue = 1,
		Reward = {
			Tears = 100
		}
	},
	{
		ID = 5,
		Name = "Upgrade a Weapon",
		MaxValue = 1,
		Reward = {
			Gold = 5000
		}
	},
	{
		ID = 6,
		Name = "Use the Upgrade Weapon system 10 times",
		MaxValue = 10,
		Reward = {
			Gold = 10000,
			Vestiges = 8,
			Tears = 75
		},
		Attributes = {"Daily"}
	},
	{
		ID = 7,
		Name = "Infuse an enchantment on your Weapon",
		MaxValue = 1,
		Reward = {
			Infusions = 4,
			Tears = 75
		},
		Attributes = {"Daily"}
	},
	{
		ID = 8,
		Name = "Infuse an enchantment on any Weapon 5 times",
		MaxValue = 5,
		Reward = {
			Infusions = 10,
			Vestiges = 9
		}
	},
	{
		ID = 9,
		Name = "Infuse at least 5 enchantments on a single Weapon",
		MaxValue = 1,
		Reward = {
			Infusions = 15
		}
	},
	{
		ID = 10,
		Name = "Upgrade your Servare once",
		MaxValue = 1,
		Reward = {
			Infusions = 16
		}
	},
	{
		ID = 11,
		Name = "Upgrade your Servare to Gale System Level 5",
		MaxValue = 1,
		Reward = {
			Infusions = 17
		}
	},
	{
		ID = 12,
		Name = "Upgrade your Servare to Gale System Level 10",
		MaxValue = 1,
		Reward = {
			Infusions = 20
		}
	},
	{
		ID = 13,
		Name = "Upgrade your Servare to max Gale System Level 15",
		MaxValue = 1,
		Reward = {
			Infusions = 23,
			Gold = 200000,
			Tears = 2500
		}
	},
	{
		ID = 14,
		Name = "Get a character to Level 25",
		MaxValue = 1,
		Reward = {
			Gold = 5000,
			Tears = 125
		}
	},
	{
		ID = 15,
		Name = "Get a character to Level 50",
		MaxValue = 1,
		Reward = {
			Gold = 10000,
			Tears = 125
		}
	},
	{
		ID = 16,
		Name = "Get a character to Level 75",
		MaxValue = 1,
		Reward = {
			Gold = 15000,
			Tears = 125
		}
	},
	{
		ID = 17,
		Name = "Get a character to Level 100",
		MaxValue = 1,
		Reward = {
			Gold = 30000,
			Tears = 125
		}
	},
	{
		ID = 18,
		Name = "Get a character to Level 125",
		MaxValue = 1,
		Reward = {
			Gold = 50000,
			Tears = 125
		}
	},
	{
		ID = 19,
		Name = "Get a character to Level 150",
		MaxValue = 1,
		Reward = {
			Gold = 60000,
			Tears = 125
		}
	},
	{
		ID = 20,
		Name = "Get a character to Level 175",
		MaxValue = 1,
		Reward = {
			Gold = 70000,
			Tears = 125
		}
	},
	{
		ID = 21,
		Name = "Get a character to Level 200",
		MaxValue = 1,
		Reward = {
			Gold = 100000,
			Tears = 125
		}
	},
	{
		ID = 22,
		Name = "Use the Upgrade Weapon system 100 times",
		MaxValue = 100,
		Reward = {
			Gold = 100000,
			Tears = 250,
			Vestiges = 10
		},
		Attributes = {"Weekly"}
	},
	{
		ID = 23,
		Name = "Use the Upgrade Weapon system 1,000 times",
		MaxValue = 1000,
		Reward = {
			Gold = 1000000,
			Infusions = 1,
			Vestiges = 11
		}
	},
	{
		ID = 24,
		Name = "Use the Upgrade Weapon system 2,000 times",
		MaxValue = 2000,
		Reward = {
			Gold = 1500000,
			Infusions = 13,
			Vestiges = 12
		}
	},
	{
		ID = 25,
		Name = "Successfully Complete a Dungeon",
		MaxValue = 1,
		Reward = {
			Gold = 5000,
			Vestiges = 17,
			Tears = 50,
		},
		Attributes = {"Daily"}
	},
	{
		ID = 26,
		Name = "Get Darwin to at least Level 50",
		MaxValue = 1,
		Reward = {
			Titles = "DarwinBanner",
			Tears = 200
		}
	},
	{
		ID = 27,
		Name = "Get Red to at least Level 50",
		MaxValue = 1,
		Reward = {
			Titles = "RedBanner",
			Tears = 200,
			
		}
	},
	{
		ID = 28,
		Name = "Get Valeri to at least Level 50",
		MaxValue = 1,
		Reward = {
			Titles = "ValeriBanner",
			Tears = 200
		}
	},
	{
		ID = 29,
		Name = "Defeat a boss",
		MaxValue = 1,
		Reward = {
			Gold = 2500,
			Tears = 25
		}
	},
	{
		ID = 30,
		Name = "Defeat 10 bosses",
		MaxValue = 10,
		Reward = {
			Gold = 5000,
			Tears = 100
		},
		Attributes = {"Daily"}
	},
	{
		ID = 31,
		Name = "Defeat 30 bosses",
		MaxValue = 30,
		Reward = {
			Gold = 20000,
			Tears = 250
		},
		Attributes = {"Weekly"}
	},
	{
		ID = 32,
		Name = "Defeat 50 bosses",
		MaxValue = 50,
		Reward = {
			Gold = 30000,
			Tears = 450
		},
		Attributes = {"Weekly"}
	},
	{
		ID = 33,
		Name = "Defeat 300 bosses",
		MaxValue = 300,
		Reward = {
			Gold = 100000,
			Tears = 500
		}
	},
	{
		ID = 34,
		Name = "Defeat 1,000 bosses",
		MaxValue = 1000,
		Reward = {
			Gold = 750000,
			Tears = 600
		}
	},
	{
		ID = 35,
		Name = "Defeat 2,000 bosses",
		MaxValue = 2000,
		Reward = {
			Gold = 1500000,
			Tears = 700
		}
	},
	{
		ID = 36,
		Name = "Defeat 4,000 bosses",
		MaxValue = 4000,
		Reward = {
			Gold = 2000000,
			Tears = 1000
		}
	},
	{
		ID = 37,
		Name = "Defeat 10,000 bosses",
		MaxValue = 10000,
		Reward = {
			Gold = 5000000,
			Tears = 2000
		}
	},
	{
		ID = 38,
		Name = "Parry a boss",
		MaxValue = 1,
		Reward = {
			Gold = 1500,
			Tears = 50
		},
		Attributes = {"Daily"}
	},
	{
		ID = 39,
		Name = "Obtain 50 Triangle Gemstones",
		MaxValue = 50,
		Reward = {
			Gold = 25000,
			Tears = 500
		},
		Attributes = {"Weekly"}
	},
	{
		ID = 40,
		Name = "Obtain 40 Quad Gemstones",
		MaxValue = 40,
		Reward = {
			Gold = 75000,
			Tears = 300
		}
	},
	{
		ID = 41,
		Name = "Obtain 35 Penta Gemstones",
		MaxValue = 35,
		Reward = {
			Gold = 100000,
			Tears = 300
		}
	},
	{
		ID = 42,
		Name = "Obtain 30 Hexa Gemstones",
		MaxValue = 30,
		Reward = {
			Gold = 150000,
			Tears = 400
		}
	},
	{
		ID = 43,
		Name = "Obtain 25 Hepta Gemstones",
		MaxValue = 25,
		Reward = {
			Gold = 250000,
			Tears = 500
		}
	},
	{
		ID = 44,
		Name = "Obtain 15 Octa Gemstones",
		MaxValue = 15,
		Reward = {
			Gold = 400000,
			Tears = 600
		}
	},
	{
		ID = 45,
		Name = "Use the Reforge System 10 times",
		MaxValue = 10,
		Reward = {
			Gold = 50000,
			Tears = 125
		},
		Attributes = {"Daily"}
	},
	{
		ID = 46,
		Name = "Use the Reforge System 50 times",
		MaxValue = 50,
		Reward = {
			Gold = 50000,
			Tears = 400
		},
		Attributes = {"Weekly"}
	},
	{
		ID = 47,
		Name = "Use the Reforge System 100 times",
		MaxValue = 100,
		Reward = {
			Gold = 100000,
			Tears = 400
		}
	},
	{
		ID = 48,
		Name = "Use the Reforge System 500 times",
		MaxValue = 500,
		Reward = {
			Gold = 500000,
			Tears = 400
		}
	},
	{
		ID = 49,
		Name = "Use the Reforge System 1,000 times",
		MaxValue = 1000,
		Reward = {
			Gold = 1000000,
			Tears = 600
		}
	},
	{
		ID = 50,
		Name = "Use the Reforge System 2,000 times",
		MaxValue = 2000,
		Reward = {
			Gold = 1500000,
			Tears = 800
		}
	},
	{
		ID = 51,
		Name = "Use the Reforge System 4,000 times",
		MaxValue = 4000,
		Reward = {
			Gold = 2500000,
			Tears = 1000
		}
	},
	{
		ID = 52,
		Name = "Obtain 10 one-star Weapons",
		MaxValue = 10,
		Reward = {
			Gold = 200,
			Tears = 100
		}
	},
	{
		ID = 53,
		Name = "Obtain 20 two-star Weapons",
		MaxValue = 20,
		Reward = {
			Gold = 300,
			Tears = 150
		}
	},
	{
		ID = 54,
		Name = "Obtain 30 three-star Weapons",
		MaxValue = 30,
		Reward = {
			Gold = 500,
			Tears = 200
		}
	},
	{
		ID = 55,
		Name = "Obtain 40 four-star Weapons",
		MaxValue = 40,
		Reward = {
			Gold = 1000,
			Tears = 250
		}
	},
	{
		ID = 56,
		Name = "Obtain 50 five-star Weapons",
		MaxValue = 50,
		Reward = {
			Gold = 3000,
			Tears = 300
		}
	},
	{
		ID = 57,
		Name = "Obtain 60 six-star Weapons",
		MaxValue = 60,
		Reward = {
			Gold = 7000,
			Tears = 300
		}
	},
	{
		ID = 58,
		Name = "Obtain 70 seven-star Weapons",
		MaxValue = 70,
		Reward = {
			Gold = 20000,
			Tears = 300
		}
	},
	{
		ID = 59,
		Name = "Upgrade a Skill",
		MaxValue = 1,
		Reward = {
			Gold = 150,
			Tears = 50
		}
	},
	{
		ID = 60,
		Name = "Upgrade a Skill to Rank SSS",
		MaxValue = 1,
		Reward = {
			Gold = 300,
			Tears = 100
		}
	},
	{
		ID = 61,
		Name = "Upgrade a Skill to Exceed 6",
		MaxValue = 1,
		Reward = {
			Gold = 1000,
			Tears = 200
		}
	},
	{
		ID = 62,
		Name = "Upgrade a Skill to Exceed 15",
		MaxValue = 1,
		Reward = {
			Gold = 2500,
			Tears = 400
		}
	},
	{
		ID = 63,
		Name = "Be part of a guild with minimum three members (including yourself)",
		MaxValue = 1,
		Reward = {
			Gold = 500,
			Tears = 200
		}
	},
	{
		ID = 64,
		Name = "Contribute at least 1,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 1000,
			Tears = 200
		}
	},
	{
		ID = 65,
		Name = "Contribute at least 2,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 1500,
			Tears = 300
		}
	},
	{
		ID = 66,
		Name = "Contribute at least 5,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 3000,
			Tears = 300
		}
	},
	{
		ID = 67,
		Name = "Contribute at least 10,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 20000,
			Tears = 400
		}
	},
	{
		ID = 68,
		Name = "Contribute at least 20,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 50000,
			Tears = 400
		}
	},
	{
		ID = 69,
		Name = "Contribute at least 100,000 EXP to your Guild",
		MaxValue = 1,
		Reward = {
			Gold = 200000,
			Tears = 800
		}
	},
	{
		ID = 70,
		Name = "Complete HMD Difficulty without losing a life",
		MaxValue = 1,
		Reward = {
			Gold = 35000,
			Tears = 500,
			ChatTitles = 6
		}
	},
	{
		ID = 71,
		Name = "Complete a Simulated Battle 4 times",
		MaxValue = 4,
		Reward = {
			Gold = 10000,
			Tears = 75
		},
		Attributes = {"Daily"}
	},
	{
		ID = 72,
		Name = "Complete a Simulated Battle 10 times",
		MaxValue = 10,
		Reward = {
			Gold = 10000,
			Tears = 250
		},
		Attributes = {"Weekly"}
	},
}


function module:UpdateAchievements(PlayerAchievements, tblOfIndexes, dontIncrement, value)
	local PlayerAchievementlist = PlayerAchievements or nil
	local List = module:GetAchievementList()
	local Rewards = {}
	local NameOfAchievements = {}
	if PlayerAchievementlist then
		for _, Ach in ipairs(PlayerAchievementlist) do
			if table.find(tblOfIndexes, Ach.I) or dontIncrement then
				for _, AchDict in ipairs(List) do
					if Ach.I == AchDict.ID and Ach.C == 0 then
						if not dontIncrement then
							Ach.V += (value and value or 1)
						end
						if Ach.V >= AchDict.MaxValue then
							Ach.C = 1
							Ach.V = nil
							table.insert(Rewards, AchDict)
						end
					end
				end
			end
		end
	end
	return Rewards, PlayerAchievementlist
end

function module:GetAchievementList()
	return AchievementsChart
end

function module:GetGoldCount()
	local List = module:GetAchievementList()
	local Tears = 0
	for i = 1, #List do
		local Li = List[i]
		for i,v in pairs(Li.Reward) do
			if i == "Gold" then
				Tears = Tears + v
			end
		end
	end
	return Tears
end


function module:GetTearCount()
	local List = module:GetAchievementList()
	local Tears = 0
	for i = 1, #List do
		local Li = List[i]
		for i,v in pairs(Li.Reward) do
			if i == "Tears" then
				Tears = Tears + v
			end
		end
	end
	return Tears
end

--print(module:GetTearCount())

function module:GetAchievement(Name)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.Name == Name then
			return Achievement
		end
	end
end

function module:GetAchievementFromID(ID)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.ID == ID then
			return Achievement
		end
	end
end

function module:CreateAchievement(ID)
	local Ach = {}
	Ach.I = ID
	Ach.C = 0	---Completed? (0 - No, 1 - Yes)
	Ach.V = 0   ---Value, turn this to nil once Completed reaches 1
	return Ach
end

return module
