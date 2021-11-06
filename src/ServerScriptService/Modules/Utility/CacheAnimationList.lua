local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tbi = table.insert
local tbr = table.remove

function module:Cache()
	local ListOfDodges					= {}
	local ListOfBlocks 					= {}
	local ListOfUlts					= {}
	local ListOfLight					= {}
	local ListOfHeavy					= {}
	local ListOfKnockBacks				= {}
	local ListOfKnockUps				= {}
	local ListOfKnockDowns				= {}
	local BlacklistAnimations			= {}
	
	for _,AnimScripts in ipairs(ReplicatedStorage.Scripts.ClassAnimateScripts:GetChildren()) do
		for _,StringVal in ipairs(AnimScripts:GetChildren()) do
			if StringVal.Name == "attackY" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfHeavy,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackX" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfLight,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackZ" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfUlts,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackblock" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfBlocks,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackdodge" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfDodges,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackW" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfKnockBacks,Anim.AnimationId)
					end
				end
			elseif StringVal.Name == "attackV" then
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(ListOfKnockUps,Anim.AnimationId)
					end
				end
			else
				for _,Anim in ipairs(StringVal:GetChildren()) do
					if Anim:IsA("Animation") then
						tbi(BlacklistAnimations,Anim.AnimationId)
					end
				end
			end
		end
	end
	
	return ListOfDodges, ListOfBlocks, ListOfUlts, ListOfLight, ListOfHeavy, ListOfKnockBacks, ListOfKnockUps, ListOfKnockDowns, BlacklistAnimations
end

return module
