local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Common.GameConfig)

local LeaderboardService = {}

function LeaderboardService.initPlayer(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local stage = Instance.new("IntValue")
    stage.Name = GameConfig.SETTINGS.LEADERBOARD_STAGE_NAME
    stage.Value = GameConfig.DEFAULTS.STAGE
    stage.Parent = leaderstats

    local coins = Instance.new("IntValue")
    coins.Name = GameConfig.SETTINGS.LEADERBOARD_COINS_NAME
    coins.Value = GameConfig.DEFAULTS.COINS
    coins.Parent = leaderstats
end

function LeaderboardService.getStage(player: Player): number
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stage = leaderstats:FindFirstChild(GameConfig.SETTINGS.LEADERBOARD_STAGE_NAME)
        if stage then
            return stage.Value
        end
    end
    return GameConfig.DEFAULTS.STAGE
end

function LeaderboardService.setStage(player: Player, newStage: number)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stage = leaderstats:FindFirstChild(GameConfig.SETTINGS.LEADERBOARD_STAGE_NAME)
        if stage and newStage > stage.Value then
            stage.Value = newStage
        end
    end
end

function LeaderboardService.addCoins(player: Player, amount: number)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild(GameConfig.SETTINGS.LEADERBOARD_COINS_NAME)
        if coins then
            coins.Value += amount
        end
    end
end

function LeaderboardService.start()
    Players.PlayerAdded:Connect(function(player)
        LeaderboardService.initPlayer(player)
    end)

    for _, player in Players:GetPlayers() do
        LeaderboardService.initPlayer(player)
    end
end

return LeaderboardService
