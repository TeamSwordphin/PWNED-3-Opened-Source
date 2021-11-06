--[[ PLUGIN USERS README HERE:

If you clicked the question mark and this script popped up, then read here. The numbers in the editor symbolizes the "ID" of the vestiges defined below.
You can add/remove the specific IDs according to what you like to use below. 





]]---


local module = {}


local AchievementsChart = {
	{
		ID = 1,
		Name = "Vestige of Lithe",
		Description = "Can dodge while attacking."
	},
	{
		ID = 2,
		Name = "Vestige of Gesture",
		Description = "Run 10% faster in lobbies. Stacks with items of the same effect."
	},
	{
		ID = 3,
		Name = "Vestige of Gesture II",
		Description = "Run 10% faster in lobbies. Stacks with items of the same effect."
	},
	{
		ID = 4,
		Name = "Vestige of Gesture III",
		Description = "Run 10% faster in lobbies. Stacks with items of the same effect."
	},
	{
		ID = 5,
		Name = "Vestige of Movement",
		Description = "Run 5% faster during combat. Stacks with items of the same effect."
	},
	{
		ID = 6,
		Name = "Vestige of Movement II",
		Description = "Run 5% faster during combat. Stacks with items of the same effect."
	},
	{
		ID = 7,
		Name = "Vestige of Movement III",
		Description = "Run 5% faster during combat. Stacks with items of the same effect."
	},
	{
		ID = 8,
		Name = "Vestige of Maintenance",
		Description = "Weapon enchant costs are reduced by 5%. Stacks with items of the same effect."
	},
	{
		ID = 9,
		Name = "Vestige of Enchanting",
		Description = "Weapon enchants costs are reduced by 5%. Stacks with items of the same effect."
	},
	{
		ID = 10,
		Name = "Vestige of Reform",
		Description = "First weapon upgrade will automatically upgrade it by 5 might. Stacks with items of the same effect."
	},
	{
		ID = 11,
		Name = "Vestige of Reform II",
		Description = "First weapon upgrade will automatically upgrade it by 5 might. Stacks with items of the same effect."
	},
	{
		ID = 12,
		Name = "Vestige of Reform III",
		Description = "First weapon upgrade will automatically upgrade it by 5 might. Stacks with items of the same effect."
	},
	{
		ID = 13,
		Name = "Vestige of Protection",
		Description = "While above 90% HP, any attack that will normally incapacitate you will instead leave you at 5% HP."
	},
	{
		ID = 14,
		Name = "Vestige of Darwin",
		Description = "Reaching below 100 Life Force will increase your attack damage by 20%."
	},
	{
		ID = 15,
		Name = "Vestige of Red",
		Description = "As Red, gain the ability to find the True Reaper. Must have unlocked map Heart of Atlas."
	},
	{
		ID = 16,
		Name = "Vestige of Valeri",
		Description = "Increases your damage by 20% against targets that have at least 95% HP."
	},
	{
		ID = 17,
		Name = "Vestige of Gaze",
		Description = "Allows you to spectate active players while in the dungeon lobby."
	},
	{
		ID = 18,
		Name = "Vestige of Bribery",
		Description = "Shop gold prices are discounted by 10%."
	}
}

function module:GetVestigeList()
	return AchievementsChart
end

function module:GetVestige(Name)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.Name == Name then
			return Achievement
		end
	end
end

function module:GetVestigeFromID(ID)
	for i = 1, #AchievementsChart do
		local Achievement = AchievementsChart[i]
		if Achievement.ID == ID then
			return Achievement
		end
	end
end

return module
