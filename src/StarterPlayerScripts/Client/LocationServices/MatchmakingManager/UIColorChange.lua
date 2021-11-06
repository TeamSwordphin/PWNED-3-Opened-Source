local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService") 
local FS                = require(ReplicatedStorage.Scripts.Modules.FastSpawn)

return function(TargetColor3, UIGradient)
    local ColorValue = Instance.new("Color3Value")
    local tweening = true

    ColorValue.Value = UIGradient.Color.Keypoints[1].Value

    local newTween = TweenService:Create(ColorValue, TweenInfo.new(1), {Value = TargetColor3})
    newTween:Play()

    newTween.Completed:Connect(function()
        tweening = false
        newTween:Destroy()
    end)

    FS.spawn(function()
        while tweening do
            UIGradient.Color = ColorSequence.new(ColorValue.Value)
            wait()
        end
    end)
    ColorValue:Destroy()
end