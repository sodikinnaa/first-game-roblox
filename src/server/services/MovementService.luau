local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MovementConfig = require(ReplicatedStorage.Common.MovementConfig)

local MovementService = {}

local function applyScales(humanoid)
    if not humanoid then return end
    for name, value in pairs(MovementConfig.Scales) do
        local scaleObj = humanoid:FindFirstChild(name)
        if scaleObj and scaleObj.Value ~= nil then
            scaleObj.Value = value
        end
    end
end

local function applyHumanoid(humanoid)
    if not humanoid then return end
    humanoid.WalkSpeed = MovementConfig.WalkSpeed
    humanoid.UseJumpPower = MovementConfig.UseJumpPower
    humanoid.JumpPower = MovementConfig.JumpPower
    applyScales(humanoid)
end

function MovementService.onCharacter(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid or player.Character ~= character then return end

    if Enum and Enum.HumanoidRigType and humanoid.RigType == Enum.HumanoidRigType.R6 and Players.CreateHumanoidModelFromDescriptionAsync then
        local success, newModel = pcall(function()
            local desc = humanoid:GetAppliedDescription()
            return Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
        end)
        if success and newModel and player.Character == character then
            newModel.Name = player.Name
            player.Character = newModel
            newModel.Parent = Workspace
            character:Destroy()
            character = newModel
            humanoid = newModel:FindFirstChildOfClass("Humanoid")
        end
    end

    applyHumanoid(humanoid)
end

function MovementService.start()
    Workspace.Gravity = MovementConfig.Gravity

    local function setupPlayer(player)
        player.CharacterAdded:Connect(function(char)
            MovementService.onCharacter(player, char)
        end)
        if player.CharacterAppearanceLoaded then
            player.CharacterAppearanceLoaded:Connect(function(char)
                local hum = char:FindFirstChildOfClass("Humanoid")
                applyScales(hum)
            end)
        end
        if player.Character then
            MovementService.onCharacter(player, player.Character)
        end
    end

    Players.PlayerAdded:Connect(setupPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end
end

return MovementService
