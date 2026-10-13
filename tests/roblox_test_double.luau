local modules = {}
local sent = {}
local stage = 1
local coinCalls = 0

local vector
local vecMeta = { __add = function(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end }
vector = function(x, y, z)
    return setmetatable({
        X = x, Y = y, Z = z,
        sub = function(self, other) return vector(self.X - other.X, self.Y - other.Y, self.Z - other.Z) end,
        add = function(self, other) return vector(self.X + other.X, self.Y + other.Y, self.Z + other.Z) end,
    }, vecMeta)
end
local Vector3 = { new = vector }

local function newSignal()
    local sig = { listeners = {} }
    function sig:Connect(fn)
        table.insert(self.listeners, fn)
        return { Disconnect = function() end }
    end
    function sig:Fire(...)
        for _, fn in ipairs(self.listeners) do
            fn(...)
        end
    end
    return sig
end

local CFrame = {
    new = function(pos, look)
        local p = type(pos) == "table" and pos or vector(pos or 0, look or 0, 0)
        local l = type(look) == "table" and (look:sub(p)) or vector(0, 0, -1)
        return {
            Position = p,
            LookVector = l,
            PointToObjectSpace = function(self, pt) return pt:sub(self.Position) end,
        }
    end,
    lookAt = function(at, target)
        local dir = target:sub(at)
        return {
            Position = at,
            LookVector = dir,
            PointToObjectSpace = function(self, pt) return pt:sub(self.Position) end,
        }
    end,
}

local function newPart(name, size)
    local pos = vector(0, 0, 0)
    return {
        Name = name or "Part",
        Size = size or vector(1, 1, 1),
        Position = pos,
        CFrame = CFrame.new(pos),
        Touched = newSignal(),
        IsA = function(self, className) return className == "BasePart" or className == "Part" end,
        FindFirstChild = function(self, childName) return nil end,
    }
end

local players
local function newPlayer(id)
    local attrs = {}
    return {
        UserId = id or 1,
        Name = "Player_" .. tostring(id or 1),
        Parent = players,
        SetAttribute = function(self, k, v) attrs[k] = v end,
        GetAttribute = function(self, k) return attrs[k] end,
    }
end

players = {
    PlayerAdded = newSignal(),
    PlayerRemoving = newSignal(),
    GetPlayers = function() return {} end,
    GetPlayerFromCharacter = function(self, char)
        return char and char._player or nil
    end,
}

local replicatedStorage = {
    Common = {},
    FindFirstChild = function(self, name) return self[name] end,
}

local workspace = {
    FindFirstChild = function(self, name) return self[name] end,
}

local services = {PhysicsService={}}
local game = {
    GetService = function(self, name)
        if services[name] then return services[name] end
        if name == "Players" then return players end
        if name == "ReplicatedStorage" then return replicatedStorage end
        if name == "Workspace" then return workspace end
        return {}
    end
}

local script = {
    Parent = {
        Services = {},
        CheckpointService = "CheckpointService",
        LeaderboardService = "LeaderboardService",
    }
}

local Instance = {
    new = function(className)
        if className == "RemoteEvent" then
            return {
                Name = "RemoteEvent",
                OnServerEvent = newSignal(),
                OnClientEvent = newSignal(),
                FireClient = function(self, player, ...)
                    table.insert(sent, {player, ...})
                end,
                FireAllClients = function(self, ...) end,
            }
        end
        return {
            Name = className,
            Parent = nil,
        }
    end
}

local task = {
    wait = function() end,
    spawn = function(fn, ...) fn(...) end,
}

local function require(target)
    if type(target) == "string" then return modules[target] end
    if type(target) == "table" and target.Name and modules[target.Name] then
        return modules[target.Name]
    end
    for k, v in pairs(modules) do
        if target == v then return v end
    end
    return target
end

modules.CheckpointService = {
    hasReached = function(self, p, s) return true end,
    REQUIRED_STAGE_FOR_FINISH = 9,
}
modules.LeaderboardService = {
    getStage = function(p) return stage end,
    setStage = function(p, s) stage = s end,
    addCoins = function(p, c) coinCalls = coinCalls + 1 end,
}
replicatedStorage.Common.GameConfig = {
    SETTINGS = { LEADERBOARD_STAGE_NAME = "Stage", LEADERBOARD_COINS_NAME = "Coins" },
    DEFAULTS = { STAGE = 1, COINS = 0 },
    REWARDS = { STAGE_CLEAR_COINS = 25, COIN_PICKUP_VALUE = 1 },
}
