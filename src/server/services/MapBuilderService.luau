local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StageConfig = require(ReplicatedStorage.Common.StageConfig)

local MapBuilderService = {}

local function ensureFolder(name: string, parent: Instance): Folder
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder :: Folder
end

local function part(name, size, position, color, material, parent)
    local result = Instance.new("Part")
    result.Name = name
    result.Anchored = true
    result.Size = size
    result.Position = position
    result.Color = color
    result.Material = material
    result.TopSurface = Enum.SurfaceType.Smooth
    result.BottomSurface = Enum.SurfaceType.Smooth
    result.CanTouch = false
    result:SetAttribute("SkyIslandGenerated", true)
    result.Parent = parent
    return result
end

function MapBuilderService.buildIslands()
    -- Rebuild only owned geometry. Call before checkpoint/obstacle listeners bind.
    local oldMap = Workspace:FindFirstChild("SkyIslandsMap")
    if oldMap then oldMap:Destroy() end
    for _, folderName in ipairs({"Checkpoints", "Obstacles"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:GetAttribute("SkyIslandGenerated") then child:Destroy() end
            end
        end
    end
    local map = ensureFolder("SkyIslandsMap", Workspace)
    local silhouettes = ensureFolder("Silhouettes", map)
    local decorations = ensureFolder("Decorations", map)
    local landingAreas = ensureFolder("LandingAreas", map)
    local railings = ensureFolder("SummitRailings", map)
    local spawns = ensureFolder("Spawns", map)
    local islands = ensureFolder("Islands", map)
    local stones = ensureFolder("SteppingStones", map)
    local checkpoints = ensureFolder("Checkpoints", Workspace)
    local obstacles = ensureFolder("Obstacles", Workspace)

    for index, data in ipairs(StageConfig.STAGES) do
        part("Island_" .. data.stage, data.size, data.pos, data.color, data.material, islands)
        local cp = part("Checkpoint_" .. data.stage, Vector3.new(8, 0.5, 8),
            data.pos + Vector3.new(0, data.size.Y / 2 + 0.25, -data.size.Z / 4),
            Color3.fromRGB(147, 205, 214), Enum.Material.SmoothPlastic, checkpoints)
        local deckY = data.pos.Y + data.size.Y / 2
        -- Three inset strata suggest a floating rock without meshes/assets.
        for layer = 1, 3 do
            local scale = 1 - layer * 0.19
            local rock = part("Rock_" .. data.stage .. "_" .. layer,
                Vector3.new(data.size.X * scale, 3, data.size.Z * scale),
                data.pos - Vector3.new(0, 2.5 + (layer - 1) * 3, 0),
                Color3.fromRGB(151 - layer * 9, 157 - layer * 9, 150 - layer * 9),
                Enum.Material.Slate, silhouettes)
            rock.CanCollide = false
            rock.CanQuery = false
        end
        local landing = part("Landing_" .. data.stage, Vector3.new(12, 0.05, 8),
            Vector3.new(0, deckY + 0.03, data.pos.Z - data.size.Z / 4),
            Color3.fromRGB(209, 223, 205), Enum.Material.SmoothPlastic, landingAreas)
        landing.CanCollide = false
        landing.CanQuery = false
        for _, side in ipairs({-1, 1}) do
            local shrub = part("Shrub_" .. data.stage .. "_" .. side, Vector3.new(3, 2, 3),
                data.pos + Vector3.new(side * (data.size.X / 2 - 3), data.size.Y / 2 + 1, 2),
                Color3.fromRGB(124, 163, 124), Enum.Material.Grass, decorations)
            shrub.Shape = Enum.PartType.Ball
            shrub.CanCollide = false
            shrub.CanQuery = false
        end
        local labelBase = part("Label_" .. data.stage, Vector3.new(0.2, 0.2, 0.2),
            data.pos + Vector3.new(-data.size.X / 2 + 3, 4, 0), data.color, data.material, decorations)
        labelBase.CanCollide = false
        labelBase.CanQuery = false
        labelBase.Transparency = 1
        local gui = Instance.new("BillboardGui")
        gui.Size = UDim2.fromOffset(200, 54)
        gui.StudsOffset = Vector3.new(0, 1, 0)
        gui.MaxDistance = 90
        gui.AlwaysOnTop = false
        gui.Parent = labelBase
        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = data.stage .. " · " .. data.name
        text.TextSize = 18
        text.Font = Enum.Font.GothamMedium
        text.TextColor3 = Color3.fromRGB(54, 73, 69)
        text.TextStrokeTransparency = 0.8
        text.Parent = gui
        cp.CanCollide = false
        cp.CanTouch = true
        cp.CFrame = CFrame.lookAt(cp.Position, cp.Position + Vector3.new(0, 0, 1))
        if index == 1 then
            local spawn = Instance.new("SpawnLocation")
            spawn.Name = "SpawnLocation"
            spawn.Anchored = true
            spawn.Size = Vector3.new(8, 0.5, 8)
            spawn.Position = cp.Position
            spawn.CFrame = CFrame.lookAt(spawn.Position, spawn.Position + Vector3.new(0, 0, 1))
            spawn.Neutral = true
            spawn.Duration = 0
            spawn.CanCollide = true
            spawn.Transparency = 1
            spawn.Parent = spawns
        end
        if index < #StageConfig.STAGES then
            local nextData = StageConfig.STAGES[index + 1]
            local count, width = data.stoneCount, data.stoneWidth
            local startEdge = data.pos.Z + data.size.Z / 2
            local endEdge = nextData.pos.Z - nextData.size.Z / 2
            local gap = (endEdge - startEdge - count * width) / (count + 1)
            local early = data.stage <= 3
            assert(gap >= (early and 2 or 3) and gap <= (early and 3 or 5), "Unsafe route gap")
            assert(width >= (data.stage == 1 and 14 or (early and 12 or 10)), "Narrow route")
            for s = 1, count do
                local z = startEdge + gap * s + width * (s - 0.5)
                local y = data.pos.Y + (nextData.pos.Y - data.pos.Y) * s / (count + 1)
                part(string.format("Stone_%d_%d", data.stage, s), Vector3.new(width, 2, width),
                    Vector3.new(data.pos.X, y, z), Color3.fromRGB(227, 230, 224),
                    data.stage == 3 and Enum.Material.WoodPlanks or Enum.Material.SmoothPlastic, stones)
            end
        else
            local finish = part("SummitFinishZone", Vector3.new(20, 8, 20),
                data.pos + Vector3.new(0, 5, 0), data.color, data.material, map)
            finish.CanCollide = false
            finish.CanTouch = true
            finish.Transparency = 1

            -- Perimeter railings prevent accidental falls from the 48x48 celebration plaza.
            local railHeight = 3.5
            local railY = data.pos.Y + data.size.Y / 2 + railHeight / 2
            local railColor = Color3.fromRGB(220, 215, 200)
            local railMat = Enum.Material.Marble

            -- North back railing (+Z)
            part("SummitRailing_North", Vector3.new(48, railHeight, 1.2),
                Vector3.new(0, railY, data.pos.Z + data.size.Z / 2 - 0.6),
                railColor, railMat, railings)
            -- West side railing (-X)
            part("SummitRailing_West", Vector3.new(1.2, railHeight, 48),
                Vector3.new(data.pos.X - data.size.X / 2 + 0.6, railY, data.pos.Z),
                railColor, railMat, railings)
            -- East side railing (+X)
            part("SummitRailing_East", Vector3.new(1.2, railHeight, 48),
                Vector3.new(data.pos.X + data.size.X / 2 - 0.6, railY, data.pos.Z),
                railColor, railMat, railings)
            -- South entrance railings (-Z), leaving 16-stud walkway in center
            part("SummitRailing_South_Left", Vector3.new(16, railHeight, 1.2),
                Vector3.new(-16, railY, data.pos.Z - data.size.Z / 2 + 0.6),
                railColor, railMat, railings)
            part("SummitRailing_South_Right", Vector3.new(16, railHeight, 1.2),
                Vector3.new(16, railY, data.pos.Z - data.size.Z / 2 + 0.6),
                railColor, railMat, railings)
        end
    end
    local void = part("KillBrick", Vector3.new(300, 4, 900), Vector3.new(0, -4, 320),
        Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, obstacles)
    void.CanCollide = false
    void.CanTouch = true
    void.Transparency = 1
end

function MapBuilderService.start()
    MapBuilderService.buildIslands()
end

return MapBuilderService
