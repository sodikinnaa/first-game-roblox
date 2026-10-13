local Players = game:GetService("Players")
local player = Players.LocalPlayer

local HUDController = {}

function HUDController.start()
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ObbyHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 70)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stageLabel = Instance.new("TextLabel")
    stageLabel.Name = "StageLabel"
    stageLabel.Size = UDim2.new(1, -20, 0, 25)
    stageLabel.Position = UDim2.new(0, 10, 0, 8)
    stageLabel.BackgroundTransparency = 1
    stageLabel.Font = Enum.Font.GothamBold
    stageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    stageLabel.TextSize = 16
    stageLabel.TextXAlignment = Enum.TextXAlignment.Left
    stageLabel.Text = "Stage: 1"
    stageLabel.Parent = frame

    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.new(1, -20, 0, 25)
    coinsLabel.Position = UDim2.new(0, 10, 0, 35)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Font = Enum.Font.GothamMedium
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 15
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Text = "Coins: 0"
    coinsLabel.Parent = frame

    local leaderstats = player:WaitForChild("leaderstats", 10)
    if leaderstats then
        local stageVal = leaderstats:WaitForChild("Stage", 5)
        local coinsVal = leaderstats:WaitForChild("Coins", 5)

        if stageVal then
            stageLabel.Text = "Stage: " .. tostring(stageVal.Value)
            stageVal.Changed:Connect(function(val)
                stageLabel.Text = "Stage: " .. tostring(val)
            end)
        end

        if coinsVal then
            coinsLabel.Text = "Coins: " .. tostring(coinsVal.Value)
            coinsVal.Changed:Connect(function(val)
                coinsLabel.Text = "Coins: " .. tostring(val)
            end)
        end
    end
end

return HUDController
