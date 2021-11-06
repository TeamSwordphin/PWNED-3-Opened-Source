local RunService = game:GetService("RunService")

local CLIENT = script.Parent.Parent
local DataValues = require(CLIENT.DataValues)
local Options = DataValues.Options
local WatchedIntro = DataValues.WatchedIntro

function lerp( v0, v1, t )
    return v0 + t * (v1 - v0)
end

return function( target, oldvalue, value, durat, fps )
	if Options.NumberAnim or WatchedIntro == false then
	    if value == 0 then
	        return
	    end
		local newScore 	= oldvalue
	    local passes 	= durat / fps
	    local increment = lerp( 0, value-oldvalue, 1/passes )
		local event 	= nil
	 	local count 	= 0
	    local function updateText()
			if target then
		        if count < passes then
		            newScore 	= newScore + increment
					target.Text = math.floor(newScore+.5)
		            count 		= count + 1
		        else
					target.Text = value
		            event:Disconnect()
					event = nil
		        end
			else
				event:Disconnect()
				event = nil
			end
	    end
	    event = RunService.Heartbeat:connect(updateText)
	else
		target.Text = value
	end
end
