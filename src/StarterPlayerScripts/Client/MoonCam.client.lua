-- xSIXx, MoonCam

	local autoPlay = false -- Automatically plays the first animation in the Animations Folder when script is ran.
	
--[[
	FOR NON-SCRIPTERS
	
	If you just want you play your Camera Animation...
		1) Put Exported Animation in the "Animations" folder in this Script.
		2) Put this Script inside the Rig you made the Camera Animation in. (does not have to be the original Rig or have any Save Files in it, can be a clone.)
		3) When this Script runs, the Camera Animation in the Animations folder will play.
	
	If you want to control playing...
		1) Turn "autoPlay" to "false". (optional)
		
		-- USE THESE COMMAND LINE SCRIPTS --
		Play with  : workspace["Rig Name Here"].MoonCam.Play:Fire(animation name if you have multiple animations in the folder)
		Pause with : workspace["Rig Name Here"].MoonCam.Pause:Fire()
		Stop with  : workspace["Rig Name Here"].MoonCam.Stop:Fire()
--]]

--[[
	FOR SCRIPTERS
	
	Change this Script into a LocalScript if you are planning on using this in any
	game (obviously). Change whatever you like below.
--]]

--[[ 
	Please don't ask me how to implement this Script in your games. This Script is just meant as
	a reference for developers to code their own system for playing the Camera Animation Files.
--]]

-------------------- DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU ARE DOING --------------------
------------------------------------------------------------------------------------------------
-- debug
if not script:FindFirstChild("Animations") then return end


-- variables
	local animations = {}
		local aniLabels = {}
	local aniSettings = {}
	
	local fps = 60
	
	for _,ani in pairs(script.Animations:GetChildren()) do
		if ani.className == "Folder" and ani:FindFirstChild("Frames") and ani:FindFirstChild("Settings") then
			
	--		if ani.Settings.Reference.Has.Value and ani.Settings.Reference.Value == nil and script.Parent.className == "Model" and script.Parent.PrimaryPart then
	--			ani.Settings.Reference.Value = script.Parent.PrimaryPart 
	--		end

			animations[ani.Name] = {}
			for _,kf in pairs(ani.Frames:GetChildren()) do
				local ind = tonumber(kf.Name)
				if ind then
					animations[ani.Name][ind] = kf.Value
					if kf:FindFirstChild("Nm") then
						if aniLabels[ani.Name] == nil then
							aniLabels[ani.Name] = {}
						end
						aniLabels[ani.Name][ind] = kf.Nm.Value
					end
				else
					animations[ani.Name] = nil
					warn("could not load "..ani.Name.."...")
					break
				end
			end	
				
			aniSettings[ani.Name] = {}
			for _,setting in pairs(ani.Settings:GetChildren()) do
				aniSettings[ani.Name][setting.Name] = setting
			end	

		end
	end
-------------------------------------------------------------
-- playing
do
	local pause = false
	local looped = false
	
	local curAni = nil
	local curRef = nil
	local pos = 0
	local lastPos = 0
	local maxLength = 0
	
	function Play(aniName)
		if aniName == nil and not pause and script.Animations:GetChildren()[1] then
			aniName = script.Animations:GetChildren()[1].Name
		end
		if aniName and animations[aniName] then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			
			lastPos = 0
			pos = 0
			maxLength = #animations[aniName] - 1
			curAni = animations[aniName]
			
			script.AniPlaying.Value = aniName
			
			pause = false
			script.Playing.Value = true
			
			looped = aniSettings[aniName].Loop.Value
			curRef = aniSettings[aniName].Reference.Value
		elseif pause and curAni then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			
			pause = false
			script.Playing.Value = true
		end
	end
	script.Play.Event:connect(Play)
	
	function Pause()
		pause = true
		script.Playing.Value = false
	end
	script.Pause.Event:connect(Pause)
	
	function Stop()
		curAni = nil
		curRef = nil

		script.AniPlaying.Value = ""
		script.Playing.Value = false
		
		workspace.CurrentCamera.CameraType = game.Players.LocalPlayer and Enum.CameraType.Custom or Enum.CameraType.Fixed
	end
	script.Stop.Event:connect(Stop)
	
	game:GetService("RunService").RenderStepped:connect(function(step)
		if curAni == nil or pause then return end
		
		pos = pos + math.floor(step * fps + 0.5)
		
		local lbls = aniLabels[script.AniPlaying.Value]
		if lbls then
			if lastPos > pos then
				for i = lastPos + 1, maxLength do
					if lbls[i + 1] then
						script.KeyframeReached:Fire(lbls[i + 1])
					end
				end
				for i = 0, pos do
					if lbls[i + 1] then
						script.KeyframeReached:Fire(lbls[i + 1])
					end
				end
			else
				for i = lastPos + 1, pos do
					if lbls[i + 1] then
						script.KeyframeReached:Fire(lbls[i + 1])
					end
				end
			end
		end
		
		workspace.CurrentCamera.CFrame = (curRef and curRef.Parent) and curRef.CFrame:ToWorldSpace(curAni[pos + 1]) or curAni[pos + 1]
		lastPos = pos
		
		if pos >= maxLength then
			if looped then
				pos = pos - maxLength
			else
				Stop()
			end
		end
	end)
	
	if autoPlay and #script.Animations:GetChildren() > 0 then
		Play(script.Animations:GetChildren()[1].Name)
	end
end
	
