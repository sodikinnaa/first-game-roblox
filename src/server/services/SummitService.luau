local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CheckpointService = require(script.Parent.CheckpointService)
local LeaderboardService = require(script.Parent.LeaderboardService)
local SummitConfig = require(ReplicatedStorage.Common.SummitConfig)

local SummitService = {}
local completed: { [Player]: boolean } = {}
local finishZone: BasePart? = nil
local remote: RemoteEvent? = nil
local started = false

function SummitService.isCompleted(player: Player): boolean
    return completed[player] == true
end

function SummitService.tryFinish(player: Player): boolean
    if not finishZone or not remote or completed[player] then return false end
    if player.Parent ~= Players then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        return false
    end
    if not CheckpointService.hasReached(player, 9) then return false end
    local position = finishZone.CFrame:PointToObjectSpace(root.Position)
    local size = finishZone.Size
    if math.abs(position.X) > size.X / 2 or math.abs(position.Y) > size.Y / 2
        or math.abs(position.Z) > size.Z / 2 then
        return false
    end

    -- No yields between validation and recording: all limbs/retries share this identity.
    completed[player] = true
    player:SetAttribute("Completed", true)
    LeaderboardService.setStage(player, 10)
    -- No new summit currency/reward or persistence policy.
    remote:FireClient(player, SummitConfig.resolve(SummitConfig))
    return true
end

function SummitService.start(zone: BasePart?)
    if started then return end
    started = true
    local map = Workspace:FindFirstChild("SkyIslandsMap")
    finishZone = zone or (map and map:FindFirstChild("SummitFinishZone"))
    assert(finishZone and finishZone:IsA("BasePart"), "SummitFinishZone missing from generated map")
    remote = ReplicatedStorage:FindFirstChild("SummitFinished")
    if remote then
        assert(remote:IsA("RemoteEvent"), "SummitFinished must be a RemoteEvent")
    else
        remote = Instance.new("RemoteEvent")
        remote.Name = "SummitFinished"
        remote.Parent = ReplicatedStorage
    end
    finishZone.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then SummitService.tryFinish(player) end
    end)
    Players.PlayerRemoving:Connect(function(player)
        completed[player] = nil
        player:SetAttribute("Completed", nil)
    end)
end

return SummitService
