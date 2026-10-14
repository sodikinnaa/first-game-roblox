local DecorAssetService = require(script.Parent.Services.DecorAssetService)
local MovementService = require(script.Parent.Services.MovementService)
local PlayerCollisionService = require(script.Parent.Services.PlayerCollisionService)
local MapBuilderService = require(script.Parent.Services.MapBuilderService)
local LeaderboardService = require(script.Parent.Services.LeaderboardService)
local CheckpointService = require(script.Parent.Services.CheckpointService)
local SummitService = require(script.Parent.Services.SummitService)
local ObstacleService = require(script.Parent.Services.ObstacleService)

print("[Server] Starting Sky Island Adventure backend...")

-- Geometry must exist before touch handlers and respawn binding.
MapBuilderService.start()
MovementService.start()
PlayerCollisionService.start()
LeaderboardService.start()
CheckpointService.start()
SummitService.start()
ObstacleService.start()
DecorAssetService.start()

print("[Server] Sky Island Adventure backend initialized successfully!")
