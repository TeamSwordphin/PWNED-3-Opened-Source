local RunService = game:GetService("RunService")

local CLIENT = script.Parent.Parent
local DataValues = require(CLIENT.DataValues)
local bools = DataValues.bools

return function(ResetText, text_obj, newTextFields, yield)
	if text_obj and text_obj:IsA("TextLabel") or text_obj:IsA("TextButton") or text_obj:IsA("TextBox") then
		if newTextFields ~= "" or bools.InDialogue then
			text_obj.TextTransparency 	= 0
			if ResetText then 
				text_obj.Text = "" 
			end
			local TextFields = text_obj.Text..""..newTextFields.. "" ..""
			for i = string.len(text_obj.Text), string.len(TextFields), 1 do
				if bools.Skip and bools.InDialogue then
					bools.Skip = false
					text_obj.Text = TextFields
					break
				else
					text_obj.Text = string.sub(TextFields, 0, i)

					if yield then
						wait(yield)
					else
						RunService.RenderStepped:Wait()
					end
				end
			end
		elseif bools.InDialogue == false then
			for i = 0,1,.1 do
				text_obj.TextTransparency = i
				
				if yield then
					wait(yield)
				else
					RunService.RenderStepped:Wait()
				end
			end
		end
	end
end
