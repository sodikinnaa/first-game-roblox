local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local PlayerCollisionService = {}
local GROUP_NAME = "SkyIslandPlayers"
local started = false

local function applyCollisionGroup(character: Model)
    for _, desc in character:GetDescendants() do
        if desc:IsA("BasePart") then
            desc.CollisionGroup = GROUP_NAME
        end
    end
    character.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            desc.CollisionGroup = GROUP_NAME
        end
    end)
end

function PlayerCollisionService.start()
    if started then return end
    started = true

    if not PhysicsService:IsCollisionGroupRegistered(GROUP_NAME) then
        PhysicsService:RegisterCollisionGroup(GROUP_NAME)
    end
    PhysicsService:CollisionGroupSetCollidable(GROUP_NAME, GROUP_NAME, false)

    local function onPlayerAdded(player: Player)
        player.CharacterAdded:Connect(function(character)
            applyCollisionGroup(character)
        end)
        if player.Character then
            applyCollisionGroup(player.Character)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return PlayerCollisionService
