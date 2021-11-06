local EnemyInformation = {}
local ModuleFunction = {}

for _, module in ipairs(script:GetDescendants()) do
    if module:IsA("ModuleScript") then
        local newEnemy = require(module)
        newEnemy.ModelName = module.Name
        table.insert(EnemyInformation, newEnemy)
    end
end

------
function ModuleFunction:GetEnemy(Name)
    for _, Enemy in ipairs(EnemyInformation) do
        if Enemy.ModelName == Name or string.format("%s (Hero)", Enemy.ModelName) == Name then
            return Enemy
        end
    end
end

return ModuleFunction