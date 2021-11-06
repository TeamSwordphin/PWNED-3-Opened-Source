local module = {}

---Can Delete variable allows if the player can delete the message from their mailbox

local Items = {
	{
		Name = "Thanks for playing!",
		Description = "Thank you for supporting our game early before its release! Currently the game is incomplete and there are much things to do. There will be one last data reset in the near future but don't be discouraged from playing the game; this is a great time to give us some feedback on progression, bugs, and much more! You can let us know on our social media page!\n\nQ: Will I lose my early access benefits or game pass items if I redeem it?\nA: Definitely not! They will be back when the reset comes so feel free to redeem them now! \n\nThanks again from all of us at Team Swordphin!",
		From = "Team Swordphin",
		CanDelete = true,
		Redeemable = false
	},
	{
		Name = "Shipment Received: Whetstones",
		Description = "We have too much whetstones in our warehouses, so I reckon you guys can make better use of it than we can.",
		From = "Unknown Sender",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Early Access Banner",
		Description = "Thank you for supporting our game early before its release! An animated banner that you can find in your Banner inventory.\n\nAccount bounded.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Early Access Costumes",
		Description = "Thank you for supporting our game early before its release! Redeeming this shipment will reward 4 costumes to your current playing character. Can be also redeemed once per character and any new character you make from now on.\n\nNote: Will not disappear upon activation, but cannot be activated again on the same character.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Early Access Headstart Tome",
		Description = "Thank you for supporting our game early before its release! Upon redeeming this tome, instantly gain 476,600 EXP (approx. 50 Levels from 1) to the current playing character. This tome cannot be used when the character is over Level 30, or if you have over 100,000 EXP in reserve.\n\nNote: This item will become bounded to your current playing character (meaning your other characters will not get it). Please select the appropriate character prior to redeeming.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Starter Kit Learning Tome",
		Description = "Upon redeeming this tome, instantly gain 476,600 EXP (approx. 50 Levels from 1) to the current playing character. This tome cannot be used when the character is over Level 30, or if you have over 100,000 EXP in reserve.\n\nNote: This item will become bounded to your current playing character (meaning your other characters will not get it). Please select the appropriate character prior to redeeming.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Early Access Chat Title",
		Description = "A stylish green flair that you can equip in your chat title inventory.\n\nAccount bounded.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Early Access Money Bags",
		Description = "Thank you for supporting our game early before its release! Upon redeeming this money bag, instantly gain 3,500 Tears and 100,000 Gold.\n\nAccount bounded.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Starter Kit Tear Bag",
		Description = "Thank you for supporting our game! Upon redeeming this money bag, instantly gain 1,500 Tears.\n\nAccount bounded.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Unlock Characters Tear Bag",
		Description = "Thank you for supporting our game! Upon redeeming this money bag, instantly gain 13,000 Tears.\n\nAccount bounded.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Unlock Characters Advanced Tome",
		Description = "Upon redeeming this tome, instantly gain 1,572,000 EXP (approx. 80 Levels from 1) to the current playing character. This tome cannot be used when the character is over Level 60, or if you have over 450,000 EXP in reserve.\n\nNote: This item will become bounded to your current playing character (meaning your other characters will not get it). Please select the appropriate character prior to redeeming.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Character Stat Reset Scroll",
		Description = "Upon redeeming this item, Character Level, EXP, stats, and skills will be reset and you will be refunded all spent EXP and Skill Points. Gold and any other non-stat related value will not be affected. Allows you to try out new builds. This item cannot be used on characters under level 10. \n\nNote: This item will become bounded to your current playing character (meaning your other characters will not get it). Please select the appropriate character prior to redeeming.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Shipment Received: Strongback Perk",
		Description = "Gained from purchasing the Extra Special Loot Drops gamepass.\n\nUpon redeeming this item, all current and future characters will have +50 permanent increased Inventory Space. Larger Inventory spaces allows you to gain more Gemstones, Weapon and Trophy loots. Max Inventory Space cap is also increased by an additional 50.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	},
	{
		Name = "Costume Transfer Token",
		Description = "Unequips and removes your current wearable costume from your inventory and sends it to the mailbox. Can then be redeemed on any other characters of your choice. \n\nNote: Only Transferable costumes may be used. Gender specific costumes can be transferred to any character of your choice without limitation.",
		From = "SYSTEM ADMIN",
		CanDelete = false,
		Redeemable = true
	}
}

function module:GiveItem(Name)
	for _, Item in ipairs(Items) do
		if Item.Name == Name then
			local date = os.date("*t")
			local NewItem = {
				Name = Item.Name,
				Seen = false,
				Date = {
					m = date.month,
					d = date.day,
					y = date.year
				}
			}
			return NewItem
		end
	end
end

function module:GetDescription(Name)
	for i = 1, #Items do
		local Item = Items[i]
		if Item.Name == Name then
			return Item
		end
	end
end

return module
