-- Local burst only: no camera/control mutations, no external textures, no frame loop.
local Players = game:GetService("Players")
local ConfettiController = {}
local attachment = nil
local emitter = nil
local expiry = nil
local connections = {}
local playing = false

local function bounded(value, fallback, minimum, maximum)
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.clamp(value, minimum, maximum)
end

function ConfettiController.stop()
    playing = false
    if expiry then task.cancel(expiry); expiry = nil end
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    if emitter then
        emitter.Enabled = false
        emitter:Clear()
        emitter:Destroy()
        emitter = nil
    end
    if attachment then attachment:Destroy(); attachment = nil end
end

function ConfettiController.getState()
    return playing and "Playing" or "Ready"
end

function ConfettiController.start(config, reducedMotion)
    -- An active burst cannot be stacked by repeat Start calls.
    if playing or reducedMotion or type(config) ~= "table"
        or config.Enabled ~= true or config.Type ~= "World3D" then return false end
    local player = Players.LocalPlayer
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not character.Parent or not root or not root:IsA("BasePart")
        or not humanoid or humanoid.Health <= 0 then return false end

    local duration = bounded(config.DurationSeconds, 4, 3, 5)
    local count = math.floor(bounded(config.MaxLiveParticles, 48, 40, 60))
    playing = true
    local ok, message = pcall(function()
        attachment = Instance.new("Attachment")
        attachment.Name = "SummitConfettiAttachment"
        attachment.Position = Vector3.new(0, 2, 0)
        attachment.Parent = root
        emitter = Instance.new("ParticleEmitter")
        emitter.Name = "SummitConfettiEmitter"
        emitter.Enabled = false
        emitter.Rate = 0
        -- Built-in Roblox particle texture, bundled with the client; no uploaded/downloaded asset.
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Lifetime = NumberRange.new(duration - 1, duration)
        emitter.Speed = NumberRange.new(7, 11)
        emitter.EmissionDirection = Enum.NormalId.Top
        emitter.SpreadAngle = Vector2.new(65, 65)
        emitter.Acceleration = Vector3.new(0, -4, 0)
        emitter.Drag = 1.5
        emitter.VelocityInheritance = 0
        emitter.LockedToPart = false
        emitter.Rotation = NumberRange.new(0, 360)
        emitter.RotSpeed = NumberRange.new(-45, 45)
        emitter.LightEmission = 0.15
        emitter.Size = NumberSequence.new(0.18)
        emitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.8, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        local colors = config.Colors
        local first = type(colors) == "table" and colors[1] or nil
        local last = type(colors) == "table" and colors[2] or nil
        local function pastel(color, fallback)
            if type(color) ~= "table" then color = fallback end
            return Color3.fromRGB(
                bounded(color[1], fallback[1], 150, 255),
                bounded(color[2], fallback[2], 150, 255),
                bounded(color[3], fallback[3], 150, 255)
            )
        end
        emitter.Color = ColorSequence.new(pastel(first, {255,185,205}), pastel(last, {180,225,255}))
        emitter.Parent = attachment
        table.insert(connections, player.CharacterAdded:Connect(ConfettiController.stop))
        table.insert(connections, player.CharacterRemoving:Connect(ConfettiController.stop))
        table.insert(connections, humanoid.Died:Connect(ConfettiController.stop))
        table.insert(connections, root.AncestryChanged:Connect(function()
            if not root:IsDescendantOf(character) then ConfettiController.stop() end
        end))
        table.insert(connections, character.AncestryChanged:Connect(function()
            if not character.Parent then ConfettiController.stop() end
        end))
        emitter:Emit(count)
        expiry = task.delay(duration, function()
            expiry = nil
            ConfettiController.stop()
        end)
    end)
    if not ok then
        ConfettiController.stop()
        warn("[ConfettiController] Burst skipped: " .. tostring(message))
        return false
    end
    return true
end

ConfettiController.Start = ConfettiController.start
ConfettiController.Stop = ConfettiController.stop
return ConfettiController
