-- Client-only API boundary: scheduling/instances, not rendering or Roblox physics.
local now = 0
local jobs = {}
local created = {}
newSignal = function()
    local signal = { listeners = {} }
    function signal:Connect(fn)
        local connection = { Connected = true }
        self.listeners[connection] = fn
        function connection:Disconnect() self.Connected = false; signal.listeners[self] = nil end
        return connection
    end
    function signal:Fire(...)
        local snapshot = table.clone(self.listeners)
        for connection, fn in pairs(snapshot) do if connection.Connected then fn(...) end end
    end
    return signal
end
local function listenerCount(signal)
    local count = 0
    for _ in pairs(signal.listeners) do count += 1 end
    return count
end
function task.delay(seconds, fn)
    local job = { at = now + seconds, fn = fn }
    jobs[job] = true
    return job
end
function task.cancel(job) jobs[job] = nil end
local function advance(seconds)
    local target = now + seconds
    while true do
        local nextJob = nil
        for job in pairs(jobs) do
            if job.at <= target and (not nextJob or job.at < nextJob.at) then nextJob = job end
        end
        if not nextJob then break end
        now = nextJob.at
        jobs[nextJob] = nil
        nextJob.fn()
    end
    now = target
end
local function pendingJobs()
    local count = 0
    for _ in pairs(jobs) do count += 1 end
    return count
end
Instance.new = function(class)
    local obj = { ClassName = class, Name = class, Destroying = newSignal(), AncestryChanged = newSignal(), Activated = newSignal(), emitted = 0 }
    function obj:IsA(name) return name == self.ClassName or (name == "BasePart" and self.ClassName == "Part") end
    function obj:FindFirstChild(name)
        for _, child in ipairs(created) do if child.Parent == self and child.Name == name then return child end end
        return nil
    end
    function obj:WaitForChild(name) return self:FindFirstChild(name) end
    function obj:FindFirstChildOfClass(name)
        for _, child in ipairs(created) do if child.Parent == self and child.ClassName == name then return child end end
        return nil
    end
    function obj:Destroy()
        if self.destroyed then return end
        self.Destroying:Fire()
        self.destroyed = true
        for _, child in ipairs(created) do if child.Parent == self then child:Destroy() end end
        self.Parent = nil
    end
    function obj:IsDescendantOf(ancestor)
        local parent = self.Parent
        while parent do
            if parent == ancestor then return true end
            parent = parent.Parent
        end
        return false
    end
    function obj:Emit(count) self.emitted += count end
    function obj:Clear() self.cleared = true end
    table.insert(created, obj)
    return obj
end
local function liveCount(class)
    local count = 0
    for _, obj in ipairs(created) do if obj.ClassName == class and not obj.destroyed then count += 1 end end
    return count
end
local function findLive(name)
    for _, obj in ipairs(created) do if obj.Name == name and not obj.destroyed then return obj end end
    return nil
end
local player = Instance.new("Player")
local attrs = {}
function player:GetAttribute(key) return attrs[key] end
local attrSignal = newSignal()
function player:SetAttribute(key, value) attrs[key] = value; attrSignal:Fire() end
function player:GetAttributeChangedSignal(_) return attrSignal end
player.CharacterAdded = newSignal()
player.CharacterRemoving = newSignal()
local function character()
    local char = Instance.new("Model")
    char.Parent = workspace
    local root = Instance.new("Part"); root.Name = "HumanoidRootPart"; root.Parent = char
    local humanoid = Instance.new("Humanoid"); humanoid.Health = 100; humanoid.Died = newSignal(); humanoid.Parent = char
    return char
end
player.Character = character()
local gui = Instance.new("PlayerGui"); gui.Parent = player
players.LocalPlayer = player
local remote = Instance.new("RemoteEvent")
remote.OnClientEvent = newSignal()
remote.Name = "SummitFinished"
replicatedStorage.SummitFinished = remote
function replicatedStorage:WaitForChild(name) return self[name] end
local settings = { ReducedMotion = false, changed = newSignal() }
function settings:GetPropertyChangedSignal(_) return self.changed end
local function UserSettings() return { GetService = function() return settings end } end
local Vector2 = {new = function(...) return {...} end}
local UDim2 = {new = function(...) return {...} end}
local UDim = {new = function(...) return {...} end}
local Color3 = {fromRGB = function(...) return {...} end}
local NumberRange = {new = function(min, max) return {Min=min, Max=max or min} end}
local NumberSequenceKeypoint = {new = function(...) return {...} end}
local NumberSequence = {new = function(...) return {...} end}
local ColorSequence = {new = function(...) return {...} end}
local Enum = { Font={GothamBold=1,GothamMedium=2}, TextXAlignment={Center=1}, NormalId={Top=1}, ParticleOrientation={FacingCamera=1} }
local function warn(...) end
