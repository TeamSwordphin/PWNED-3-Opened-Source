local module = {}

local NormalHitboxes = {"rbxassetid://1510497071", "rbxassetid://869475269", "rbxassetid://872845419", "rbxassetid://872846241", "rbxassetid://872846564", "rbxassetid://939624189", }

function module:CreateBox(AnimPlayed, Model, KF)
	local id = AnimPlayed.Animation.AnimationId
	
	if id == "rbxassetid://939624897" then ---Darwin's Green Blizzard
		return Model.PrimaryPart.CFrame.lookVector*400, Vector3.new(4,6,1), 3
	elseif id == "rbxassetid://1159799887" then --Darwin's ultimate
		return CFrame.new(0,0,0), Vector3.new(20,20,20), nil
		
	elseif id == "rbxassetid://3226791353" then --Darwin"B"'s X4
		if KF == "SlashBegin" then
			return CFrame.new(0,0,0), Vector3.new(20,20,20), nil
		end
	elseif id == "rbxassetid://3226792660" then --Darwin"B"'s X5
		if KF == "SlashBegin" then
			return CFrame.new(0,0,0), Vector3.new(7,7,7), nil
		end
		
	elseif id == "rbxassetid://2640173394" then		--Red's ult
		return CFrame.new(0,3,-200), Vector3.new(15,15, 431)
		
	elseif id == "rbxassetid://3307099762" then		-- Valeri's X4
		return CFrame.new(0,0,-7), Vector3.new(35,20,20)
	elseif id == "rbxassetid://3307099762" then		-- Valeri's X5
		return CFrame.new(0,5,-10), Vector3.new(25,30,25)
	elseif id == "rbxassetid://3399035928" then		-- Valeri's Y3
		if KF == "SlashBegin" then
			return CFrame.new(0,2,0), Vector3.new(8,8,8)
		elseif KF == "SlashBeginBig" then
			return CFrame.new(0,2,0), Vector3.new(16,16,16)
		end
	
	elseif id == "rbxassetid://3619234538" then --LF's Y1
		return CFrame.new(0,-10,0), Vector3.new(25,35,25), nil
	elseif id == "rbxassetid://3115648751" then --LF's Y2
		return CFrame.new(0,-10,0), Vector3.new(25,35,25), nil
		
	
	elseif id == "rbxassetid://3759212501" then --Alburn X3
		return CFrame.new(0,0,-5), Vector3.new(10,10,12), nil
	elseif id == "rbxassetid://3759215060" then --Alburn X4
		return CFrame.new(0,0,-7), Vector3.new(7,10,15), nil
	
	
	end
	
	--[[
	if id == "rbxassetid://872845803" then --Darwin's X3
		return CFrame.new(0,0,0), Vector3.new(15,5,15)
	elseif id == "rbxassetid://877493956" or id == "rbxassetid://1176751478" then --Darwin's dodge and knockup
		return CFrame.new(0,-30,0), Vector3.new(8,80,15)
	elseif id == "rbxassetid://939624897" then ---Darwin's Green Blizzard
		return Model.PrimaryPart.CFrame.lookVector*400, Vector3.new(4,6,1), 3
	elseif id == "rbxassetid://939630783" then --Darwin's Withering
		return CFrame.new(0,0,0), Vector3.new(22,22,22)
	elseif id == "rbxassetid://1185835742" or id == "rbxassetid://1186204792" then --Red's X1 and 2
		return CFrame.new(0,0,-3), Vector3.new(6,6,7)
	elseif id == "rbxassetid://1190470961" then --Red's scythe
		return CFrame.new(0,0,-4), Vector3.new(8,6,9)
	elseif id == "rbxassetid://1190472225" then --Red's stabbies
		return CFrame.new(0,0,-7), Vector3.new(4,6,15)
	elseif id == "rbxassetid://1539765958" then --Red's Y2
		return CFrame.new(0,3,-6), Vector3.new(13,11,13)
	end
	for i = 1, #NormalHitboxes do
		if NormalHitboxes[i] == id then
			return nil, nil --defaults to normal 
		end
	end--]]
	return nil, nil
end

local V3 = Vector3.new
local R = Random.new

function module:CommitPhysics(AnimPlayed, Model, Targ, KF)
	local id = AnimPlayed.Animation.AnimationId
	
	if id == "rbxassetid://1159799887" then --Darwin's ultimate
		if KF == "SlashBegin" then
			return .2, ((Model.PrimaryPart.Position+Model.PrimaryPart.CFrame.LookVector*10)-Targ.PrimaryPart.Position).unit*2.5 + V3(0,4,0), V3(0, R():NextNumber(-10, 10), R():NextNumber(-30, 30))
		elseif KF == "SlashPhysics" then
			return .75, (Targ.PrimaryPart.Position-(Model.PrimaryPart.Position+Model.PrimaryPart.CFrame.LookVector*10)).unit*50 + V3(0,50,0), V3(0, R():NextNumber(-25, 25), R():NextNumber(-160, 160))
		end
		
	elseif id == "rbxassetid://2640173394" then --Red's ultimate
		if KF == "SlashBegin" then
			return .2, ((Model.PrimaryPart.Position+Model.PrimaryPart.CFrame.LookVector*250)-Targ.PrimaryPart.Position).unit*2.5 + V3(0,1,0), V3(0, R():NextNumber(-10, 10), R():NextNumber(-30, 30))
		elseif KF == "SlashPhysics" then
			return .75, (Model.PrimaryPart.CFrame.LookVector)*100 + V3(0,75,0), V3(0, R():NextNumber(-25, 25), R():NextNumber(-160, 160))
		end
		
	elseif id == "rbxassetid://3115648751" then --LF's Y2
		if KF == "SlashBegin" then
			return .2, ((Model.PrimaryPart.Position+Model.PrimaryPart.CFrame.LookVector*10)-Targ.PrimaryPart.Position).unit*2.5 + V3(0,4,0), V3(0, R():NextNumber(-10, 10), R():NextNumber(-30, 30))
		end
	
	end
end

return module
