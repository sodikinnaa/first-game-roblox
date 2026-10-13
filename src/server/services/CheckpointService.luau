local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardService = require(script.Parent.LeaderboardService)
local GameConfig = require(ReplicatedStorage.Common.GameConfig)

local CheckpointService = {}
local history: { [Player]: { [number]: boolean } } = {}
local started = false

local function getCheckpointCFrame(stageNum: number): CFrame?
    local checkpointsFolder = Workspace:FindFirstChild("Checkpoints")
    if checkpointsFolder then
        local cp = checkpointsFolder:FindFirstChild("Checkpoint_" .. tostring(stageNum))
        if cp and cp:IsA("BasePart") then
            local pos = cp.Position + Vector3.new(0, 3.5, 0)
            -- Facing +Z toward next islands along the journey
            return CFrame.lookAt(pos, pos + Vector3.new(0, 0, 1))
        end
    end
    return nil
end

function CheckpointService.hasReached(player: Player, stageNum: number): boolean
    local playerHistory = history[player]
    if not playerHistory then return false end
    for stage = 1, stageNum do
        if playerHistory[stage] ~= true then return false end
    end
    return true
end

function CheckpointService.teleportToCheckpoint(player: Player, character: Model)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root or not root:IsA("BasePart") or player.Parent ~= Players or player.Character ~= character then return end

    local currentStage = LeaderboardService.getStage(player)
    local targetCF = getCheckpointCFrame(currentStage)
    if targetCF then
        root.CFrame = targetCF
    end
end

function CheckpointService.onCheckpointTouched(part: BasePart, stageNum: number)
    -- Stage 10 is the summit plaza, validated by SummitService
    if stageNum >= 10 then return end

    part.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then return end

        local player = Players:GetPlayerFromCharacter(character)
        if not player or player.Parent ~= Players or player.Character ~= character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
            return
        end

        -- Server position validation
        local position = part.CFrame:PointToObjectSpace(root.Position)
        local size = part.Size
        if math.abs(position.X) > size.X / 2 + 4 or math.abs(position.Y) > size.Y / 2 + 6 or math.abs(position.Z) > size.Z / 2 + 4 then
            return
        end

        local currentStage = LeaderboardService.getStage(player)
        if stageNum == currentStage + 1 then
            local playerHistory = history[player]
            if not playerHistory then
                playerHistory = { [1] = true }
                history[player] = playerHistory
            end
            playerHistory[stageNum] = true
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
    if started then return end
    started = true

    local function onCharacterAdded(player: Player, character: Model)
        task.wait(0.1)
        CheckpointService.teleportToCheckpoint(player, character)
    end

    local function onPlayerAdded(player: Player)
        if not history[player] then
            history[player] = { [1] = true }
        end
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(player, character)
        end)
        if player.Character then
            task.spawn(onCharacterAdded, player, player.Character)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end

    Players.PlayerRemoving:Connect(function(player)
        history[player] = nil
    end)

    CheckpointService.bindCheckpoints()
end

return CheckpointService
