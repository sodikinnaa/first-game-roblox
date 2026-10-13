local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfettiController = require(script.Parent.ConfettiController)
local SummitConfig = require(ReplicatedStorage.Common.SummitConfig)
local SummitController = {}
local activeGui: ScreenGui? = nil
local cleanupToken: number = 0
local started = false
local finished = false
local state = "Ready"
local replayButton = nil
local payloadCache = nil
local connections = {}
local deathConnection = nil
local presentationConnections = {}
local timers = {}
local settings = nil
pcall(function() settings = UserSettings():GetService("UserGameSettings") end)

local function reducedMotion()
    return Players.LocalPlayer:GetAttribute("ReducedMotion") == true
        or (settings and settings.ReducedMotion == true) or false
end

local function cancelTimers()
    for timer in pairs(timers) do task.cancel(timer) end
    table.clear(timers)
end

local function schedule(seconds, callback)
    local timer
    timer = task.delay(seconds, function()
        timers[timer] = nil
        callback()
    end)
    timers[timer] = true
end

local function updateReplay()
    if replayButton then
        replayButton.Active = state == "Ready"
        replayButton.AutoButtonColor = state == "Ready"
        replayButton.Text = state == "Ready" and "Replay Selebrasi" or "Selebrasi sedang jeda"
    end
end

function SummitController.canReplay()
    return finished and activeGui ~= nil and state == "Ready" and payloadCache ~= nil
        and payloadCache.Replay ~= nil and payloadCache.Replay.Enabled == true
end

local function playEffects(payload)
    state = "Playing"
    updateReplay()
    ConfettiController.start(payload.Confetti, reducedMotion())
    local duration = payload.Confetti and payload.Confetti.DurationSeconds or payload.DurationSeconds
    schedule(duration, function()
        ConfettiController.stop()
        state = "Cooldown"
        updateReplay()
        schedule(payload.Replay and payload.Replay.CooldownSeconds or 10, function()
            state = "Ready"
            updateReplay()
        end)
    end)
end

local function cleanupBanner()
    cleanupToken += 1
    cancelTimers()
    ConfettiController.stop()
    state = "Ready"
    replayButton = nil
    for _, connection in ipairs(presentationConnections) do connection:Disconnect() end
    table.clear(presentationConnections)
    if activeGui then
        activeGui:Destroy()
        activeGui = nil
    end
end

local function showCelebrationBanner(payload: any)
    local player = Players.LocalPlayer
    if not player then return end

    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = player:WaitForChild("PlayerGui", 5)
    end
    if not playerGui then return end

    -- Clean up any existing celebration banner
    cleanupBanner()
    local currentToken = cleanupToken

    local titleText = (type(payload) == "table" and type(payload.Title) == "string")
        and payload.Title or "Puncak Tercapai!"
    local subtitleText = (type(payload) == "table" and type(payload.Subtitle) == "string")
        and payload.Subtitle or "Selamat! Kamu telah menaklukkan seluruh pulau langit."
    local duration = (type(payload) == "table" and type(payload.DurationSeconds) == "number")
        and math.clamp(payload.DurationSeconds, 1, 10) or 5

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SummitCelebrationGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10
    activeGui = screenGui

    -- Mobile-friendly responsive banner
    local bannerFrame = Instance.new("Frame")
    bannerFrame.Name = "BannerFrame"
    bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
    bannerFrame.Size = UDim2.new(0.9, 0, 0, 100)
    bannerFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
    bannerFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    bannerFrame.BackgroundTransparency = 0.15
    bannerFrame.BorderSizePixel = 0
    bannerFrame.Parent = screenGui

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(500, 120)
    sizeConstraint.MinSize = Vector2.new(280, 80)
    sizeConstraint.Parent = bannerFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = bannerFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = bannerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 0, 36)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Color3.fromRGB(255, 225, 80)
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = bannerFrame

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Size = UDim2.new(1, -20, 0, 42)
    subtitleLabel.Position = UDim2.new(0, 10, 0, 48)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Font = Enum.Font.GothamMedium
    subtitleLabel.Text = subtitleText
    subtitleLabel.TextColor3 = Color3.fromRGB(240, 245, 250)
    subtitleLabel.TextSize = 14
    subtitleLabel.TextWrapped = true
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.Parent = bannerFrame

    if payload.Replay and payload.Replay.Enabled then
        replayButton = Instance.new("TextButton")
        replayButton.Name = "ReplayButton"
        replayButton.Size = UDim2.new(0, 180, 0, 44)
        replayButton.AnchorPoint = Vector2.new(0.5, 0)
        replayButton.Position = UDim2.new(0.5, 0, 0.1, 105)
        replayButton.TextSize = 14
        replayButton.Parent = screenGui
        table.insert(presentationConnections, replayButton.Activated:Connect(function()
            if not SummitController.canReplay() then return end
            bannerFrame.Visible = true
            playEffects(payload)
            schedule(duration, function() bannerFrame.Visible = false end)
        end))
    end
    screenGui.Parent = playerGui
    playEffects(payload)
    schedule(duration, function()
        if cleanupToken ~= currentToken then return end
        if replayButton then bannerFrame.Visible = false else cleanupBanner() end
    end)
end

function SummitController.stop()
    started = false
    cleanupBanner()
    if deathConnection then deathConnection:Disconnect(); deathConnection = nil end
    finished = false
    payloadCache = nil
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end

function SummitController.start()
    if started then return end
    local player = Players.LocalPlayer
    if not player then return end
    local remote = ReplicatedStorage:WaitForChild("SummitFinished", 10)
    if not remote or not remote:IsA("RemoteEvent") then
        warn("[SummitController] SummitFinished RemoteEvent not found")
        return
    end
    started = true
    local function bindCharacter(char)
        if deathConnection then deathConnection:Disconnect(); deathConnection = nil end
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            deathConnection = humanoid.Died:Connect(cleanupBanner)
        end
    end
    if player.Character then bindCharacter(player.Character) end
    table.insert(connections, player.CharacterAdded:Connect(function(char)
        cleanupBanner()
        bindCharacter(char)
    end))
    table.insert(connections, player.CharacterRemoving:Connect(function()
        cleanupBanner()
        bindCharacter(nil)
    end))
    local function accessibilityChanged()
        if reducedMotion() then ConfettiController.stop() end
    end
    table.insert(connections, player:GetAttributeChangedSignal("ReducedMotion"):Connect(accessibilityChanged))
    if settings then
        table.insert(connections, settings:GetPropertyChangedSignal("ReducedMotion"):Connect(accessibilityChanged))
    end
    table.insert(connections, remote.OnClientEvent:Connect(function(payload)
        -- Only the server's first validated finish starts presentation. Duplicate events are ignored.
        if finished then return end
        finished = true
        payloadCache = SummitConfig.resolve(SummitConfig)
        if type(payload) == "table" then
            if type(payload.Title) == "string" then payloadCache.Title = string.sub(payload.Title, 1, 120) end
            if type(payload.Subtitle) == "string" then payloadCache.Subtitle = string.sub(payload.Subtitle, 1, 300) end
        end
        local ok, message = pcall(showCelebrationBanner, payloadCache)
        if not ok then cleanupBanner(); warn("[SummitController] Presentation skipped: " .. tostring(message)) end
    end))
end

SummitController.Start = SummitController.start
SummitController.Stop = SummitController.stop

return SummitController
