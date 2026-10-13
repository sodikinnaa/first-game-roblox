local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardService = require(script.Parent.LeaderboardService)
local GameConfig = require(ReplicatedStorage.Common.GameConfig)

local CheckpointService = {}
local playerCheckpoints: { [Player]: number } = {}

local function getCheckpointCFrame(stageNum: number): CFrame?
    local checkpointsFolder = Workspace:FindFirstChild("Checkpoints")
    if checkpointsFolder then
        local cp = checkpointsFolder:FindFirstChild("Checkpoint_" .. tostring(stageNum))
        if cp and cp:IsA("BasePart") then
            return cp.CFrame + Vector3.new(0, 3.5, 0)
        end
    end
    return nil
end

function CheckpointService.teleportToCheckpoint(player: Player, character: Model)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    local currentStage = LeaderboardService.getStage(player)
    local targetCF = getCheckpointCFrame(currentStage)
    if targetCF then
        root.CFrame = targetCF
    end
end

function CheckpointService.onCheckpointTouched(part: BasePart, stageNum: number)
    part.Touched:Connect(function(hit)
        local character = hit.Parent
        if not character then return end

        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        local currentStage = LeaderboardService.getStage(player)
        if stageNum == currentStage + 1 then
            LeaderboardService.setStage(player, stageNum)
            LeaderboardService.addCoins(player, GameConfig.REWARDS.STAGE_CLEAR_COINS)
        end
    end)
end

function CheckpointService.bindCheckpoints()
    local checkpointsFolder = Workspace:FindFirstChild("Checkpoints")
    if not checkpointsFolder then return end

    for _, child in checkpointsFolder:GetChildren() do
        if child:IsA("BasePart") then
            local stageNum = tonumber(string.match(child.Name, "%d+"))
            if stageNum then
                CheckpointService.onCheckpointTouched(child, stageNum)
            end
        end
    end
end

function CheckpointService.start()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            CheckpointService.teleportToCheckpoint(player, character)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        playerCheckpoints[player] = nil
    end)

    CheckpointService.bindCheckpoints()
end

return CheckpointService
