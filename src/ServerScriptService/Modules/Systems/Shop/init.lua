local module = {}
local DataStoreService 	= game:GetService("DataStoreService")
local canPurchaseTears = true

--[[ On Char Switching
	
	Character bound things will not carry over between characters. These include:
	-Level, EXP, Faith Points
	-Costumes
	-Gemstones and Weapons
--]]


local Stock = { --- Some are predetermined by script. To create new stocks, use this script's children and make a new module.
	Items = {
		Gemstone = {
			---Done by script
		}
	},
	GamePass = {
		GamePasses = {
			--Done by script
		},
		TopContributors = {
			--Done by script
		}
	},
	BuyTears = {
		Tears = {
			--Done by script
		},
		TopContributors = {
			--Done by script
		}
	}
}

local MarketplaceService = game:GetService("MarketplaceService")

local LootModule = require(script.Parent.Parent.CharacterManagement["LootInfo"])
local Gems, GemImages = LootModule:ReturnGems()


-----

local stock = script:FindFirstChild("Stock")

if stock then
	for _, category in ipairs(script.Stock:GetChildren()) do
		if not Stock[category.Name] then
			Stock[category.Name] = {}
		end

		for _, subCategory in ipairs(category:GetChildren()) do
			if not Stock[category.Name][subCategory.Name] then
				Stock[category.Name][subCategory.Name] = {}
			end

			for _, merchandise in ipairs(subCategory:GetChildren()) do
				local result, module = pcall(function()
					return require(merchandise)
				end)
				if result then
					table.insert(Stock[category.Name][subCategory.Name], module)
				else
					warn(string.format("%s merchandise module has experienced an error while loading", merchandise.Name))
				end
			end
		end
	end
end

for _, Gem in ipairs(Gems) do
	if Gem.Ranks[1] ~= nil then
		local NewStock = {
			Name = Gem.Name,
			Type = "Gemstone",
			Thumb = GemImages[1].Image,
			BorderColor = GemImages[1].Color,
			PreviewModel = nil,
			Available = true,
			Reveal = true,
			GoldPrice = 1000,
			TearsPrice = 0,
			OnSale = 0, 
			Everyone = {}, 
			Description = Gem.Description.. "" ..Gem.Ranks[1].. "" ..Gem.Prefix.. "\n\n\nNote: This item will become bounded to your current playing character (meaning your other characters will not get it). Please select the appropriate character prior to purchasing."
		}
		table.insert(Stock.Items.Gemstone, NewStock)
	end
end

local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(2057535, Enum.InfoType.GamePass)
	local NewStock = {
		Name = Product.Name,
		Type = "GamePass",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = true,
		Reveal = true,
		GoldPrice = 2057535,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = Product.Description
	}
	table.insert(Stock.GamePass.GamePasses, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(2059326, Enum.InfoType.GamePass)
	local NewStock = {
		Name = Product.Name,
		Type = "GamePass",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = true,
		Reveal = true,
		GoldPrice = 2059326,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = Product.Description
	}
	table.insert(Stock.GamePass.GamePasses, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(2229858, Enum.InfoType.GamePass)
	local NewStock = {
		Name = Product.Name,
		Type = "GamePass",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = true,
		Reveal = true,
		GoldPrice = 2229858,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = Product.Description
	}
	table.insert(Stock.GamePass.GamePasses, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(6845594, Enum.InfoType.GamePass)
	local NewStock = {
		Name = Product.Name,
		Type = "GamePass",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = true,
		Reveal = true,
		GoldPrice = 6845594,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = Product.Description
	}
	table.insert(Stock.GamePass.GamePasses, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(7052268, Enum.InfoType.GamePass)
	local NewStock = {
		Name = Product.Name,
		Type = "GamePass",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = true,
		Reveal = true,
		GoldPrice = 7052268,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = Product.Description
	}
	table.insert(Stock.GamePass.GamePasses, NewStock)
end)

--Developer Products
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(81178418, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 81178418,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289603, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289603,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289647, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289647,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289672, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289672,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289710, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289710,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289778, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289778,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)
local success, msg = pcall(function()
	local Product = MarketplaceService:GetProductInfo(53289820, Enum.InfoType.Product)
	local NewStock = {
		Name = Product.Name,
		Type = "Tears",
		Thumb = "rbxassetid://"..Product.IconImageAssetId,
		BorderColor = Color3.fromRGB(),
		PreviewModel = nil,
		Available = canPurchaseTears,
		Reveal = true,
		GoldPrice = 53289820,
		TearsPrice = 0,
		RobuxPrice = Product.PriceInRobux,
		OnSale = 0, 
		Everyone = {}, 
		Description = "Tears can be used to purchase cosmetics, premium items, and a lot of other stuff!"
	}
	table.insert(Stock.BuyTears.Tears, NewStock)
end)

function module:ChangeSales()
	local OldThings = {}
	
end

function module:GetShop()
	return Stock
end

function module:GetCategory(tbl)
	local Name = tbl[1]
	local SubCategory = tbl[2]
	if Stock[Name] ~= nil and Stock[Name][SubCategory] ~= nil then
		return Stock[Name][SubCategory]
	end
	return nil
end

function module:GetItemInfo(Name)
	for i,Category in next, Stock do
		for v,SubCategories in next, Category do
			for b,Item in next, SubCategories do
				if Item.Name == Name then
					return Item
				end
			end
		end
	end
	return nil
end

return module
