local DecorAssetService = {}
local allowed = {Model=true, Folder=true, Part=true, MeshPart=true, SpecialMesh=true, SurfaceAppearance=true, Texture=true, Decal=true}

-- Server-only, unparented staging; never assign Model IDs to MeshId.
function DecorAssetService.load(assetId, parent, position, height, fallback)
    if type(assetId) ~= "number" or assetId <= 0 then return false end
    local ok, model = pcall(function()
        return game:GetService("AssetService"):LoadAssetAsync(assetId)
    end)
    if not ok or not model then return false end
    local valid = pcall(function()
        assert(model:IsA("Model"), "expected Model container")
        model.Parent = nil
        local descendants = model:GetDescendants()
        assert(#descendants <= 80, "decoration instance budget")
        local parts = 0
        for _, item in ipairs(descendants) do
            if item:IsA("LuaSourceContainer") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                parts += 1
                item.Anchored = true
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
            elseif not allowed[item.ClassName] then
                item:Destroy()
            end
        end
        assert(parts > 0 and parts <= 24, "decoration part budget")
        local size = model:GetExtentsSize()
        assert(size.Y > 0 and size.Y < 1000, "invalid decoration bounds")
        model:ScaleTo(math.clamp(height / size.Y, 0.01, 20))
        model:PivotTo(CFrame.new(position))
        model.Parent = parent
    end)
    if not valid then model:Destroy(); return false end
    if fallback then fallback:Destroy() end
    return true
end

-- At most two loads per map; game startup never waits for the network.
function DecorAssetService.start()
    local workspace = game:GetService("Workspace")
    local map = workspace:FindFirstChild("SkyIslandsMap")
    if not map then return end
    local decorations = map:FindFirstChild("Decorations")
    for _, side in ipairs({-1, 1}) do
        local fallback = decorations:FindFirstChild("Shrub_1_" .. side)
        task.spawn(function()
            -- Parent may have been destroyed by an offline rebuild during load.
            local parent = Instance.new("Folder")
            parent.Name = "KenneyTree_" .. side
            if DecorAssetService.load(118266415097960, parent, Vector3.new(side*9, 11, 2), 4, nil) then
                if map.Parent then
                    parent.Parent = decorations
                    if fallback then fallback:Destroy() end
                else parent:Destroy() end
            else parent:Destroy() end
        end)
    end
end
return DecorAssetService
