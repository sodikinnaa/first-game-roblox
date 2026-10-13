local LeaderboardService = require(script.Parent.Services.LeaderboardService)
local CheckpointService = require(script.Parent.Services.CheckpointService)
local ObstacleService = require(script.Parent.Services.ObstacleService)

print("[Server] Starting AI Obby Adventure backend...")

LeaderboardService.start()
CheckpointService.start()
ObstacleService.start()

print("[Server] AI Obby Adventure backend initialized successfully!")
