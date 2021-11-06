local RS = game:GetService("ReplicatedStorage")

local Module = {}
Module.OriginalR6Joints = {
	["Left Shoulder"] = {
		Parent = "Torso" ,
		Part0 = "Torso" ,
		Part1 = "Left Arm" ,
		Name = "Left Shoulder" ,
		C0 = CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) ,
		C1 = CFrame.new(0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) ,
	},
	["Right Shoulder"] = {
		Parent = "Torso" ,
		Part0 = "Torso" ,
		Part1 = "Right Arm" ,
		Name = "Right Shoulder" ,
		C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0) ,
		C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0) ,
	},
	["Neck"] = {
		Parent = "Torso" ,
		Part0 = "Torso" ,
		Part1 = "Head" ,
		Name = "Neck" ,
		C0 = CFrame.new(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0) ,
		C1 = CFrame.new(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0) ,
	},
	["Right Hip"] = {
		Parent = "Torso" ,
		Part0 = "Torso" ,
		Part1 = "Right Leg" ,
		Name = "Right Hip" ,
		C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0) ,
		C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0) ,
	},
	["Left Hip"] = {
		Parent = "Torso" ,
		Part0 = "Torso" ,
		Part1 = "Left Leg" ,
		Name = "Left Hip" ,
		C0 = CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) ,
		C1 = CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) ,
	},
	["RootJoint"] = {
		Parent = "HumanoidRootPart" ,
		Part0 = "HumanoidRootPart" ,
		Part1 = "Torso" ,
		Name = "RootJoint" ,
		C0 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0) ,
		C1 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0) ,
	}
}
Module.OriginalR15Joints = {
	["Waist"] = {
		Parent = "UpperTorso" ,
		Part0 = "LowerTorso" ,
		Part1 = "UpperTorso" ,
		Name = "Waist" ,
		C0 = CFrame.new(0, 0.404105991, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftShoulder"] = {
		Parent = "LeftUpperArm" ,
		Part0 = "UpperTorso" ,
		Part1 = "LeftUpperArm" ,
		Name = "LeftShoulder" ,
		C0 = CFrame.new(-1.50177097, 0.924546003, 0, 1, 0, -0, 0, 0.999044001, 0.0437170006, 0, -0.0437170006, 0.999044001) ,
		C1 = CFrame.new(0, 0.336115986, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["Root"] = {
		Parent = "LowerTorso" ,
		Part0 = "HumanoidRootPart" ,
		Part1 = "LowerTorso" ,
		Name = "Root" ,
		C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["Neck"] = {
		Parent = "Head" ,
		Part0 = "UpperTorso" ,
		Part1 = "Head" ,
		Name = "Neck" ,
		C0 = CFrame.new(0, 1.26949596, 0.0428609997, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, -0.635110021, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightHip"] = {
		Parent = "RightUpperLeg" ,
		Part0 = "LowerTorso" ,
		Part1 = "RightUpperLeg" ,
		Name = "RightHip" ,
		C0 = CFrame.new(0.451141, -0.498115987, 0, 1, 0, -0, 0, 1, 0.000100999998, 0, -0.000100999998, 1) ,
		C1 = CFrame.new(0, 0.387418985, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightElbow"] = {
		Parent = "RightLowerArm" ,
		Part0 = "RightUpperArm" ,
		Part1 = "RightLowerArm" ,
		Name = "RightElbow" ,
		C0 = CFrame.new(0, -0.335705996, 0, 1, 0, 0, 0, 0.999041617, -0.0437709838, 0, 0.0437709838, 0.999041617) ,
		C1 = CFrame.new(0, 0.351512015, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightKnee"] = {
		Parent = "RightLowerLeg" ,
		Part0 = "RightUpperLeg" ,
		Part1 = "RightLowerLeg" ,
		Name = "RightKnee" ,
		C0 = CFrame.new(0, -0.387418985, 0, 1, 0, -0, 0, 0.995820105, 0.0913360119, 0, -0.0913360119, 0.995820105) ,
		C1 = CFrame.new(0, 0.414570987, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightWrist"] = {
		Parent = "RightHand" ,
		Part0 = "RightLowerArm" ,
		Part1 = "RightHand" ,
		Name = "RightWrist" ,
		C0 = CFrame.new(0, -0.351512015, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0.175756007, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftKnee"] = {
		Parent = "LeftLowerLeg" ,
		Part0 = "LeftUpperLeg" ,
		Part1 = "LeftLowerLeg" ,
		Name = "LeftKnee" ,
		C0 = CFrame.new(0, -0.387418985, 0, 1, 9.95820074e-007, 9.13360125e-008, -9.99999997e-007, 0.995820105, 0.0913360119, 0, -0.0913360119, 0.995820105) ,
		C1 = CFrame.new(0, 0.414570987, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightAnkle"] = {
		Parent = "RightFoot" ,
		Part0 = "RightLowerLeg" ,
		Part1 = "RightFoot" ,
		Name = "RightAnkle" ,
		C0 = CFrame.new(0, -0.414570987, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0.207286, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["RightShoulder"] = {
		Parent = "RightUpperArm" ,
		Part0 = "UpperTorso" ,
		Part1 = "RightUpperArm" ,
		Name = "RightShoulder" ,
		C0 = CFrame.new(1.50049305, 0.923726022, 0, 1, 0, -0, 0, 0.999041617, 0.0437709838, 0, -0.0437709838, 0.999041617) ,
		C1 = CFrame.new(0, 0.335705996, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftWrist"] = {
		Parent = "LeftHand" ,
		Part0 = "LeftLowerArm" ,
		Part1 = "LeftHand" ,
		Name = "LeftWrist" ,
		C0 = CFrame.new(0, -0.351512015, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0.175756007, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftElbow"] = {
		Parent = "LeftLowerArm" ,
		Part0 = "LeftUpperArm" ,
		Part1 = "LeftLowerArm" ,
		Name = "LeftElbow" ,
		C0 = CFrame.new(0, -0.336115986, 0, 1, 0, 0, 0, 0.999044001, -0.0437170006, 0, 0.0437170006, 0.999044001) ,
		C1 = CFrame.new(0, 0.351512015, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftHip"] = {
		Parent = "LeftUpperLeg" ,
		Part0 = "LowerTorso" ,
		Part1 = "LeftUpperLeg" ,
		Name = "LeftHip" ,
		C0 = CFrame.new(-0.457044005, -0.498115987, 0, 1, 0, -0, 0, 1, 0.000100999998, 0, -0.000100999998, 1) ,
		C1 = CFrame.new(0, 0.387418985, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
	["LeftAnkle"] = {
		Parent = "LeftFoot" ,
		Part0 = "LeftLowerLeg" ,
		Part1 = "LeftFoot" ,
		Name = "LeftAnkle" ,
		C0 = CFrame.new(0, -0.414570987, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
		C1 = CFrame.new(0, 0.207286, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) ,
	},
}
---------------------
-- \\ Math Utilities.
---------------------
function Module.getYawFromVector(lvec)
	local yaw = 0
	local a = lvec.X
	local o = lvec.Z
	yaw = math.atan2(o,a) + math.pi
	return yaw
end
----------------------
-- \\ Table Utilities.
----------------------
function Module.DeepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Module.DeepCopy(orig_key)] = Module.DeepCopy(orig_value)
		end
		setmetatable(copy, Module.DeepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
----------------------
-- \\ String Utilities.
----------------------
function Module.Comma(x)
	local a = x
	local k = 0
	while true do  
		a, k = string.gsub(a, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return a
end
----------------------
-- \\ Model Utilities.
----------------------
function Module:GetPartsInModel(Object, Tab)
	if Tab == nil then Tab = {} end
	for _,v in next, Object:GetChildren() do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
			Tab[#Tab+1]=v
		else
			Tab = Module:GetPartsInModel(v,Tab)
		end
	end
	return Tab
end

function Module.StraightenCFrame(CF)
	local _,_,_, R00, R01, R02, 
	             R10, R11, R12, 
	             R20, R21, R22 = CF:components()
	if R02 ~= 0 or R22 ~= 0 then
		local VZ = Vector3.new(R02,0,R22).unit
		local VX = Vector3.new(0,1,0):Cross(VZ)
		return CFrame.new(0,0,0, VX.X, 0, VZ.X, 0, 1, 0, VX.Z, 0, VZ.Z)
	else
		return CFrame.new()
	end
end
------------------------------
-- \\ Joint/Welding Utilities.
------------------------------
function Module:CreateJoint(Type, Name, p0, p1, c0, c1, Parent)
	if Name == nil then
		Name = "Weld"
	end
	local Weld = Instance.new(Type or "Weld")
	Weld.Name = Name
	Weld.Part0, Weld.Part1 = p0,p1
	local CJ = CFrame.new(p0.CFrame.p)
	local C0 = c0 or CFrame.new()
	local C1 = c1 or CFrame.new()
	Weld.C0, Weld.C1 = C0,C1
	Weld.Parent = Parent or p0
	p0.Anchored = false
	p1.Anchored = false
	return Weld
end

function Module:Weld(p0, p1, c0, c1, Name, Type, LeaveAnchored)
	local Weld = Instance.new(Type or "Weld",p0)
	Weld.Name = Name or "Weld"
	Weld.Part0, Weld.Part1 = p0,p1
	local CJ = CFrame.new(p0.CFrame.p)
	local C0 = c0 or CFrame.new()
	local C1 = c1 or CFrame.new()
	Weld.C0, Weld.C1 = C0,C1
	if LeaveAnchored ~= nil and not LeaveAnchored then else p1.Anchored = false end
	return Weld
end

function Module:AutoWeld(p0, p1, Type)
	local Weld = Instance.new(Type or "Weld",p0)
	Weld.Part0, Weld.Part1 = p0,p1
	local CJ = CFrame.new(p0.CFrame.p)
	local C0 = p0.CFrame:inverse()*CJ
	local C1 = p1.CFrame:inverse()*CJ
	Weld.C0, Weld.C1 = C0,C1
	p1.Anchored = false
	return Weld
end

function Module:WeldTool(Tool)
	if Tool:FindFirstChild("Handle") == nil then error("Error "..Tool.Name.." is missing its handle!") end
	for i,v in next, Module:GetPartsInModel(Tool) do
		if v.Name ~= "Handle" then
			Module:AutoWeld(Tool.Handle, v)
		end
	end
end
---------------------
-- \\ Misc Utilities.
---------------------
function Module:RenderPartBetweenPoints(A,B, KeepTime)
	local beam = Instance.new("Part")
	beam.BrickColor = BrickColor.new("Bright red")
	beam.Material = "Neon"
	beam.Transparency = 0.25
	beam.Anchored = true
	beam.Locked = true
	beam.CanCollide = false

	local distance = (A - B).magnitude
	beam.Size = Vector3.new(0.05, 0.05, distance)
	beam.CFrame = CFrame.new(A, B) * CFrame.new(0, 0, -distance / 2)
	
	beam.Parent = (workspace.Terrain or nil)
	
	delay(KeepTime or 1,function() beam:Destroy() end)
end

function Module.Cast_Quadratic_Curve(p1,p2)
	local segments = 10
	local pull = -5

	for i=1,segments do
		local x = 10*((i-1)/segments)
		local x2 = 10*(i/segments)
		Module.RenderPartBetweenPoints(
			p1+((p2-p1)/segments*(i-1))+Vector3.new(0,(-x^2+10*x)/25*-pull,0),
			p1+((p2-p1)/segments*i)+Vector3.new(0,(-x2^2+10*x2)/25*-pull,0)
		)
	end
end

function Module:IgnorePlayerCharacters(Ignorelist)
	if Ignorelist == nil then
		Ignorelist = {}
	end
	for Index, Player in next, game.Players:GetPlayers() do
		if Player.Character ~= nil then
			Ignorelist[#Ignorelist+1] = Player.Character
		end
	end
	return Ignorelist
end

function Module:IsWithinFieldOfView(ViewDirection, ViewAngle, SelfPosition, TargetedPosition, Showcone)
	-- cheeze said this would be better print(math.deg(math.acos(Vector3.new(0, 0, -1):Dot(Vector3.new(0, 0, -1)))))	
	local Diff = (TargetedPosition - SelfPosition.p).unit
	local Angle = math.deg( math.acos(ViewDirection:Dot(Diff)) )
	--
	if Showcone then
		local Hit, Position, Surface = Module:Raycast(SelfPosition.p, (SelfPosition * CFrame.Angles(0,-math.rad(ViewAngle),0)).lookVector * 100, {game.Workspace}, true, 0.1 , false, true)
		local Hit, Position, Surface = Module:Raycast(SelfPosition.p, (SelfPosition * CFrame.Angles(0,math.rad(ViewAngle),0)).lookVector * 100, {game.Workspace}, true, 0.1 , false, true)
	end		
	-- print(Angle <  ViewAngle, "|", Angle, "|", ViewAngle) 
	if Angle < ViewAngle then
		return true, Angle
	else
		return false
	end
end

function Module:GetAngle(ViewDirection, SelfPosition, TargetedPosition)
	local Diff = (TargetedPosition - SelfPosition).unit
	local Angle = math.deg( math.acos(ViewDirection:Dot(Diff)) )
	return Angle
end

function Module:FindHumanoidAncestor(ObjectToSearch)
	if ObjectToSearch.Parent == game.Workspace or ObjectToSearch.Parent == nil then return end
	local Humanoid
	if ObjectToSearch:IsA("BasePart") or ObjectToSearch:IsA("UnionOperation") then
		Humanoid = ObjectToSearch.Parent:FindFirstChild("Humanoid")
		if Humanoid ~= nil then
			return Humanoid
		else
			Humanoid = Module:FindHumanoidAncestor(ObjectToSearch.Parent)
		end
	else
		Humanoid = ObjectToSearch:FindFirstChild("Humanoid")
		if Humanoid ~= nil then
			return Humanoid
		else
			Humanoid = Module:FindHumanoidAncestor(ObjectToSearch.Parent)
		end
	end
	return Humanoid
end

function Module:GetPlayers()
	return game.Players:GetPlayers()
end

function Module:GetPlayerCharacters(CheckIfAlive)
	local Characters = {}
	for Index, Player in next, Module:GetPlayers() do
		if Player.Character ~= nil then
			if not CheckIfAlive then
				Characters[#Characters+1] = Player.Character
			elseif CheckIfAlive then
				if Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
					Characters[#Characters+1] = Player.Character	
				end
			end
		end
	end
	return Characters
end

function Module:GetPlayerHumanoidRootParts(CheckIfAlive)
	local Characters = Module:GetPlayerCharacters(CheckIfAlive)
	local Torsos = {}
	for Index, Character in next, Characters do
		if Character:FindFirstChild("HumanoidRootParts") ~= nil then
			Torsos[#Torsos+1] = Character.Torso
		end
	end
	return Torsos
end

function Module:FindClosestV3(Origin, V3s, DistanceLimit)
	if Origin == nil then warn("Warning Origin is nil, setting Origin to Vector3.new(0,0,0)") Origin = Vector3.new() end
	local Distance = DistanceLimit or math.huge
	local Index, ClosestVector3
	for i, V3 in next, V3s do
		Index = i
		local D = (Origin - V3).Magnitude 
		if D < Distance then
			Distance = D
			ClosestVector3 = V3
		end
	end
	return Index, ClosestVector3
end

function Module:FindClosestV2(Origin, V2s, DistanceLimit)
	if Origin == nil then warn("Warning Origin is nil, setting Origin to Vector2.new(0,0)") Origin = Vector2.new() end
	local Distance = DistanceLimit or math.huge
	local Index, ClosestVector2
	for i, V2 in next, V2s do
		Index = i
		local D = (Origin - V2).magnitude 
		if D < Distance then
			Distance = D
			ClosestVector2 = V2
		end
	end
	return Index, ClosestVector2
end
---------------------------
-- \\ Raycasting Utilities.
---------------------------
function Module:Raycast(Position, Direction, IgnoreList, Visualize, RenderTime, terrainCellsAreCubes, ignoreWater)
	if IgnoreList == nil then
		IgnoreList = {}
	end
	local Part, Point, Surface = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(Position, Direction),IgnoreList, terrainCellsAreCubes or false, ignoreWater or false)
	
	if Visualize then
		Module:RenderPartBetweenPoints(Position, Point, RenderTime)
	end	
	
	return Part, Point, Surface
end

function Module:RecursiveRaycast(Position, Direction, IgnoreList, MaxDistance) 
	if IgnoreList == nil then
		IgnoreList = {}
	end
	local Ray_Origin = Position
	local Origin = Ray_Origin
	local Hit, HitPosition, Surface
	local Distance = 0
	while Distance < MaxDistance do
		Hit, HitPosition, Surface = Module.Raycast(Origin, Direction, IgnoreList)
		if Hit ~= nil  then
			if (Hit.CanCollide == true or Hit.Transparency < 0.5) and Hit.Name ~= "HumanoidRootPart" then
				break
			end
			
			if Hit.Name ~= "HumanoidRootPart" and Hit.Parent ~= nil and Hit.Parent:FindFirstChild("Humanoid") ~= nil then
				break
			end
		end
		Distance = Distance + (Origin - HitPosition).Magnitude

		IgnoreList[#IgnoreList+1] = Hit
		Origin = HitPosition
	end
	return Ray_Origin, Hit, HitPosition, Surface
end
--------------------------
-- \\ Character Utilities.
--------------------------			
function Module:CreateRagdoll(Character)
	if Character:FindFirstChild("Humanoid") ~= nil then
		local RigType = Enum.HumanoidRigType.R6
		print(RigType)
		if RigType == Enum.HumanoidRigType.R6 then
			for Index, JointData in next, Module.OriginalR6Joints do
				if JointData.Name ~= "Neck" then
					if Character:FindFirstChild(JointData.Part0) then
						if Character:FindFirstChild(JointData.Part1) then
							-- Humanoid.Health = 100
							if Character.Torso:FindFirstChild(Index, true) ~= nil then
								Character.Torso[Index].Part1 = nil
							end
							if Character.Torso:FindFirstChild("RGD_"..Index, true) ~= nil then
								Character.Torso["RGD_"..Index].Part1 = Character[JointData.Part1]
							else
								Module:CreateJoint("Glue", "RGD_"..JointData.Name, Character[JointData.Part0], Character[JointData.Part1], JointData.C0, JointData.C1, Character[JointData.Parent])
							end	
							
							Character[JointData.Part0].Anchored = false
							Character[JointData.Part0].CanCollide = true
							Character[JointData.Part1].Anchored = false
							Character[JointData.Part1].CanCollide = true
						end
					end
				end
			end		
		elseif RigType == Enum.HumanoidRigType.R15 then
			for Index, JointData in next, Module.OriginalR15Joints do
				if JointData.Name ~= "Neck" then
				if Character:FindFirstChild(JointData.Part0) then
						if Character:FindFirstChild(JointData.Part1) then
							-- Humanoid.Health = 100
							--[[
							if Character.Torso:FindFirstChild(Index) ~= nil then
								Character.Torso[Index].Part1 = nil
							end
							--]]
							local obj = Character:FindFirstChild(Index, true) ; print(obj)
							if obj ~= nil then
								obj.Part1 = nil
							end
							
							--[[
							if Character.Torso:FindFirstChild("RGD_"..Index) ~= nil then
								Character.Torso["RGD_"..Index].C1 = Character[JointData.Part1]
							else
								Module:CreateJoint("Glue", "RGD_"..JointData.Name, Character[JointData.Part0], Character[JointData.Part1], JointData.C0, JointData.C1)
							end		
							--]]
							local obj = Character:FindFirstChild("RGD_"..Index, true)
							if obj ~= nil then
								obj.Part1 = Character[JointData.Part1]
							else
								Module:CreateJoint("Glue", "RGD_"..JointData.Name, Character[JointData.Part0], Character[JointData.Part1], JointData.C0, JointData.C1, Character[JointData.Parent])
							end	
						end
					end
				end
			end			
		end
		Character.Humanoid.PlatformStand = true
	end
end

function Module:DeRagdoll(Character)
	if Character:FindFirstChild("Humanoid") ~= nil then
		local RigType = Character.Humanoid.RigType
		print(RigType)
		if RigType == Enum.HumanoidRigType.R6 then
			for Index, JointData in next, Module.OriginalR6Joints do
				if JointData.Name ~= "Neck" then
					if Character:FindFirstChild(JointData.Part0) then
						if Character:FindFirstChild(JointData.Part1) then
							-- Humanoid.Health = 100
							if Character.Torso:FindFirstChild(Index, true) ~= nil then
								Character.Torso[Index].Part1 = Character[JointData.Part1]
							end
							
							if Character.Torso:FindFirstChild("RGD_"..Index, true) ~= nil then
								Character.Torso["RGD_"..Index].Part1 = nil
							end
						end
					end
				end
			end		
		elseif RigType == Enum.HumanoidRigType.R15 then
			for Index, JointData in next, Module.OriginalR15Joints do
				if JointData.Name ~= "Neck" then
					if Character:FindFirstChild(JointData.Part0) then
						if Character:FindFirstChild(JointData.Part1) then
							-- Humanoid.Health = 100
							--[[
							if Character.Torso:FindFirstChild(Index) ~= nil then
								Character.Torso[Index].Part1 = Character[JointData.Part1]
							end
							--]]
							local obj = Character:FindFirstChild(Index, true)
							if obj ~= nil then
								obj.Part1 = Character[JointData.Part1]
							end
							--[[
							if Character.Torso:FindFirstChild("RGD_"..Index) ~= nil then
								Character.Torso["RGD_"..Index].Part1 = nil
							end
							--]]
							local obj = Character:FindFirstChild("RGD_"..Index, true)
							if obj ~= nil then
								obj.Part1 = nil
							end
						end
					end				
				end
			end			
		end
		Character.Humanoid.PlatformStand = false
	end
end

return Module