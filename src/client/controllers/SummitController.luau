local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SummitController = {}
local activeGui: ScreenGui? = nil
local cleanupToken: number = 0

local function cleanupBanner()
    cleanupToken += 1
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

    screenGui.Parent = playerGui

    -- Auto dismiss after configured duration
    task.delay(duration, function()
        if cleanupToken == currentToken and screenGui.Parent then
            cleanupBanner()
        end
    end)
end

function SummitController.start()
    local player = Players.LocalPlayer
    if player then
        player.CharacterAdded:Connect(function()
            cleanupBanner()
        end)
    end

    local remote = ReplicatedStorage:WaitForChild("SummitFinished", 10)
    if not remote or not remote:IsA("RemoteEvent") then
        warn("[SummitController] SummitFinished RemoteEvent not found")
        return
    end

    remote.OnClientEvent:Connect(function(payload)
        showCelebrationBanner(payload)
    end)
end

return SummitController
