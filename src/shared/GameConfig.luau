local GameConfig = {}

GameConfig.GAME_TITLE = "AI Obby Adventure"
GameConfig.VERSION = "1.0.0"

GameConfig.DEFAULTS = {
    COINS = 0,
    STAGE = 1,
}

GameConfig.SETTINGS = {
    COIN_RESPAWN_TIME = 15,
    KILL_TOUCH_COOLDOWN = 1.0,
    LEADERBOARD_COINS_NAME = "Coins",
    LEADERBOARD_STAGE_NAME = "Stage",
}

GameConfig.REWARDS = {
    STAGE_CLEAR_COINS = 25,
    COIN_PICKUP_VALUE = 1,
}

return GameConfig
