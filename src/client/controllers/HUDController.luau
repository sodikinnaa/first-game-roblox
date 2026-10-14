local Players = game:GetService("Players")
local player = Players.LocalPlayer

local HUDController = {}
local started = false
local UserInputService = game:GetService("UserInputService")

function HUDController.start()
    if started then return end
    started = true
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ObbyHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Active = false
    frame.Size = UDim2.new(0, 220, 0, 94)
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
    coinsLabel.Size = UDim2.new(1, -20, 0, 22)
    coinsLabel.Position = UDim2.new(0, 10, 0, 32)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Font = Enum.Font.GothamMedium
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 15
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Text = "Coins: 0"
    coinsLabel.Parent = frame

    local checkpointLabel = Instance.new("TextLabel")
    checkpointLabel.Name = "CheckpointLabel"
    checkpointLabel.Size = UDim2.new(1, -20, 0, 22)
    checkpointLabel.Position = UDim2.new(0, 10, 0, 58)
    checkpointLabel.BackgroundTransparency = 1
    checkpointLabel.Font = Enum.Font.GothamMedium
    checkpointLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
    checkpointLabel.TextSize = 14
    checkpointLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkpointLabel.Text = "Checkpoint: CP1 Aktif"
    checkpointLabel.Parent = frame

    local tutorialFrame = Instance.new("Frame")
    tutorialFrame.Name = "TutorialFrame"
    tutorialFrame.Active = false
    tutorialFrame.Size = UDim2.new(0.9, 0, 0, 46)
    tutorialFrame.Position = UDim2.new(0.05, 0, 0, 120)
    tutorialFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 28)
    tutorialFrame.BackgroundTransparency = 0.3
    tutorialFrame.BorderSizePixel = 0
    tutorialFrame.Parent = screenGui

    local tutCorner = Instance.new("UICorner")
    tutCorner.CornerRadius = UDim.new(0, 8)
    tutCorner.Parent = tutorialFrame

    local tutorialText = Instance.new("TextLabel")
    tutorialText.Name = "TutorialText"
    tutorialText.Size = UDim2.new(1, -16, 1, 0)
    tutorialText.Position = UDim2.new(0, 8, 0, 0)
    tutorialText.BackgroundTransparency = 1
    tutorialText.Font = Enum.Font.GothamMedium
    tutorialText.TextColor3 = Color3.fromRGB(240, 245, 240)
    tutorialText.TextSize = 13
    tutorialText.TextWrapped = true
    tutorialText.Active = false
    tutorialText.Parent = tutorialFrame

    local currentStage = 1
    local isTouch = UserInputService.TouchEnabled

    local function updateTutorial()
        if currentStage == 1 then
            if isTouch then
                tutorialText.Text = "Arahkan kamera dengan geser layar. Tombol lompat ada di kanan bawah."
            else
                tutorialText.Text = "Arahkan kamera dengan mouse. Tekan Space untuk melompati celah."
            end
        elseif currentStage == 2 then
            tutorialText.Text = "Selamat! Checkpoint 2 aktif. Ikuti arah menuju Cloud Garden."
        else
            tutorialText.Text = "Ikuti jalur batu menuju puncak."
        end
    end

    if UserInputService.LastInputTypeChanged then
        UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
            if lastInputType == Enum.UserInputType.Touch then
                isTouch = true
            elseif lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.MouseButton1 then
                isTouch = false
            end
            updateTutorial()
        end)
    end
    updateTutorial()

    local leaderstats = player:WaitForChild("leaderstats", 10)
    if leaderstats then
        local stageVal = leaderstats:WaitForChild("Stage", 5)
        local coinsVal = leaderstats:WaitForChild("Coins", 5)

        if stageVal then
            local function onStage(val)
                currentStage = val
                stageLabel.Text = "Stage: " .. tostring(val)
                checkpointLabel.Text = "Checkpoint: CP" .. tostring(val) .. " Aktif"
                updateTutorial()
            end
            onStage(stageVal.Value)
            stageVal.Changed:Connect(onStage)
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
