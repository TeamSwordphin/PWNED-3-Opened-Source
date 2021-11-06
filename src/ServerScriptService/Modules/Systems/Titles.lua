--[[ PLUGIN USERS README HERE:

If you clicked the question mark and this script popped up, then read here. You can add any ChatTitle with the same name below. Do not use the IDs for this section.





]]---

local module = {}

local AchievementsChart = {
	{
		ID = 1,
		Name = "VIP",
		Description = "Obtained from purchasing the VIP Game Pass.",
		Color = Color3.fromRGB()
	},
	{
		ID = 2,
		Name = "Trailblazer",
		Description = "Obtained from purchasing Early Access.",
		Color = Color3.fromRGB(0, 255, 0)
	},
	{
		ID = 3,
		Name = "Robot Destroyer",
		Description = "Obtained from defeating BossMan for the first time.",
		Color = Color3.fromRGB()
	},
	{
		ID = 4,
		Name = "Alilu of Triumph",
		Description = "Obtained from completing City Roads.",
		Color = Color3.fromRGB()
	},
	{
		ID = 5,
		Name = "Developer",
		Description = "Obtained from being a cool kid.",
		Color = Color3.fromRGB(255, 0, 0)
	},
	{
		ID = 6,
		Name = "Heroes Never Die",
		Description = "Obtained from surviving Heroes Must Die.",
		Color = Color3.fromRGB(255, 0, 0)
	},
}


function module:GetTitlesChart()
	return AchievementsChart
end

function module:GetTitle(Name)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.Name == Name then
			return Achievement
		end
	end
end

function module:GetTitleFromID(ID)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.ID == ID then
			return Achievement
		end
	end
end

return module
