return function(image, reverse, numSpritesX, numSpritesY, framerate, startrowX, startrowY, MaxFrames, StartColor, EndColor)
	local sizeX = image.ImageRectSize.X
	local sizeY = image.ImageRectSize.Y
	--
	local startrowX = startrowX and type(startrowX) == "number" and startrowX or 0
	local startrowY = startrowY and type(startrowY) == "number" and startrowY or 0
	local canReverse = reverse or false
	local MFrames = MaxFrames or -1
	local SColor = StartColor or nil
	local EColor = EndColor or nil
	local Colors = {0,0,0}
	if SColor ~= nil then
		Colors = {SColor[1], SColor[2], SColor[3]}
	end
	
	if canReverse then
		for i = numSpritesY-1, 0, -1 do
			if MFrames == 0 or image == nil then break end
			for i2 = numSpritesX-1, 0, -1 do
				if MFrames == 0 or image == nil then break end
				if MFrames > 0 then
					MFrames = MFrames - 1
				end
				if SColor ~= nil then
					Colors[1] = Colors[1] + ((EColor[1]-SColor[1])/(numSpritesX*numSpritesY))
					Colors[2] = Colors[2] + ((EColor[2]-SColor[2])/(numSpritesX*numSpritesY))
					Colors[3] = Colors[3] + ((EColor[3]-SColor[3])/(numSpritesX*numSpritesY))
					image.ImageColor3 = Color3.new(Colors[1]/255, Colors[2]/255, Colors[3]/255)
				end
				image.ImageRectOffset = Vector2.new(sizeX*i2, sizeY*i)
				wait(type(framerate) == "number" and framerate > 0 and 1/framerate or 1/15)
			end
		end
	else
		for i = startrowY, numSpritesY-1 do
			if MFrames == 0 or image == nil then break end
			for i2 = startrowX, numSpritesX-1 do
				if MFrames == 0 or image == nil then break end
				if MFrames > 0 then
					MFrames = MFrames - 1
				end
				if SColor ~= nil then
					Colors[1] = Colors[1] + ((EColor[1]-SColor[1])/(numSpritesX*numSpritesY))
					Colors[2] = Colors[2] + ((EColor[2]-SColor[2])/(numSpritesX*numSpritesY))
					Colors[3] = Colors[3] + ((EColor[3]-SColor[3])/(numSpritesX*numSpritesY))
					image.ImageColor3 = Color3.new(Colors[1]/255, Colors[2]/255, Colors[3]/255)
				end
				image.ImageRectOffset = Vector2.new(sizeX*i2, sizeY*i)
				wait(type(framerate) == "number" and framerate > 0 and 1/framerate or 1/15)
			end
		end
	end
	wait()
end
