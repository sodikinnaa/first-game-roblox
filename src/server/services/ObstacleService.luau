local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ObstacleService = {}

function ObstacleService.bindKillBricks()
    local killFolder = Workspace:FindFirstChild("Obstacles")
    if not killFolder then return end

    for _, desc in killFolder:GetDescendants() do
        if desc:IsA("BasePart") and desc.Name == "KillBrick" then
            desc.Touched:Connect(function(hit)
                local char = hit.Parent
                if not char then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = 0
                end
            end)
        end
    end
end

function ObstacleService.start()
    ObstacleService.bindKillBricks()
end

return ObstacleService
