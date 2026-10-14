local DecorAssetService = {}
local allowed = {Model=true, Folder=true, Part=true, MeshPart=true, SpecialMesh=true, SurfaceAppearance=true, Texture=true, Decal=true}

-- Server-only, unparented staging; never assign Model IDs to MeshId.
function DecorAssetService.load(assetId, parent, position, height, fallback)
    if type(assetId) ~= "number" or assetId <= 0 then return false, "InvalidAssetId" end
    local ok, model = pcall(function()
        return game:GetService("AssetService"):LoadAssetAsync(assetId)
    end)
    if not ok or not model then return false, "LoadFailed" end
    local failureStatus = "ValidationFailed"
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
        failureStatus = "PlacementFailed"
        local size = model:GetExtentsSize()
        assert(size.Y > 0 and size.Y < 1000, "invalid decoration bounds")
        local currentScale = model:GetScale()
        model:ScaleTo(math.clamp(currentScale * (height / size.Y), 0.01, 20))
        model:PivotTo(CFrame.new(position))
        -- position denotes the deck surface, not the imported model pivot.
        local bounds, extent = model:GetBoundingBox()
        local targetCenter = position + Vector3.new(0, extent.Y / 2, 0)
        model:PivotTo(model:GetPivot() + (targetCenter - bounds.Position))
        model.Parent = parent
    end)
    if not valid then model:Destroy(); return false, failureStatus end
    if fallback then fallback:Destroy() end
    return true, "Loaded"
end

-- At most two loads per map; game startup never waits for the network.
function DecorAssetService.start()
    local workspace = game:GetService("Workspace")
    local map = workspace:FindFirstChild("SkyIslandsMap")
    if not map then return end
    local decorations = map:FindFirstChild("Decorations")
    if not decorations then return end
    for _, side in ipairs({-1, 1}) do
        decorations:SetAttribute("KenneyTree_" .. side .. "Status", "Loading")
        local fallback = decorations:FindFirstChild("Shrub_1_" .. side)
        task.spawn(function()
            -- Parent may have been destroyed by an offline rebuild during load.
            local parent = Instance.new("Folder")
            parent.Name = "KenneyTree_" .. side
            local ok, status = DecorAssetService.load(118266415097960, parent, Vector3.new(side*9, 11, 2), 4, nil)
            if ok then
                if decorations:IsDescendantOf(workspace) then
                    parent:SetAttribute("AssetId", 118266415097960)
                    parent:SetAttribute("Status", "Loaded")
                    parent.Parent = decorations
                    decorations:SetAttribute("KenneyTree_" .. side .. "Status", "Loaded")
                    if fallback and fallback.Parent then fallback:Destroy() end
                else parent:Destroy() end
            else
                parent:Destroy()
                if decorations:IsDescendantOf(workspace) then
                    decorations:SetAttribute("KenneyTree_" .. side .. "Status", status)
                end
                if fallback and fallback.Parent then
                    fallback:SetAttribute("FallbackActive", true)
                end
                warn(string.format("[DecorAssetService] Stage1 tree side %d status: %s", side, status))
            end
        end)
    end
end
return DecorAssetService
