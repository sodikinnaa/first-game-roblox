"""Execute shipped Luau map code with a minimal Roblox object adapter.

This verifies generated geometry/idempotency, not Studio physics, rendering,
Touched, avatar jumping or real engine instance semantics. No Python map clone.
Set LUAU_BIN or install Luau at build/tools/luau to run.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
LUAU = os.environ.get("LUAU_BIN") or shutil.which("luau") or str(ROOT / "build/tools/luau")

ADAPTER = r'''
local vector = {}
vector.__index = vector
function vector.__add(a, b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vector.__sub(a, b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vector.__mul(a, b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
function vector.__div(a, b) return Vector3.new(a.X/b,a.Y/b,a.Z/b) end
function vector:Lerp(b,t) return self+(b-self)*t end
Vector3 = {new = function(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vector) end}
Color3 = {fromRGB = function(r,g,b) return {R=r,G=g,B=b} end}
UDim2 = {fromOffset = function(x,y) return {x,y} end, fromScale = function(x,y) return {x,y} end}
Enum = setmetatable({}, {__index=function(_,k) return setmetatable({}, {__index=function(_,v) return k.."."..v end}) end})
local cf_mt = {}
cf_mt.__index = cf_mt
function cf_mt.__add(a, b)
    local pos = a.Position + (type(b) == "table" and (b.Position or b) or b)
    return CFrame.new(pos.X, pos.Y, pos.Z, a.LookVector)
end
CFrame = {
    new = function(x,y,z,lv)
        local pos = type(x)=="table" and x or Vector3.new(x,y,z)
        local look = lv or Vector3.new(0, 0, -1)
        return setmetatable({Position=pos, LookVector=look}, cf_mt)
    end,
    lookAt = function(at, target)
        local diff = target - at
        local mag = math.sqrt(diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z)
        local lv = mag > 0 and Vector3.new(diff.X/mag, diff.Y/mag, diff.Z/mag) or Vector3.new(0,0,1)
        return setmetatable({Position=at, LookVector=lv}, cf_mt)
    end
}
local all = {}
local methods = {}
function methods:GetChildren()
    local result = {}
    for _,v in ipairs(all) do if v.Parent == self and not v.dead then table.insert(result,v) end end
    return result
end
function methods:GetDescendants()
    local result = {}
    for _,v in ipairs(self:GetChildren()) do
        table.insert(result,v)
        for _,child in ipairs(v:GetDescendants()) do table.insert(result,child) end
    end
    return result
end
function methods:FindFirstChild(name)
    for _,v in ipairs(self:GetChildren()) do if v.Name == name then return v end end
end
function methods:SetAttribute(k,v) self.attributes[k]=v end
function methods:GetAttribute(k) return self.attributes[k] end
function methods:Destroy()
    for _,v in ipairs(self:GetChildren()) do v:Destroy() end
    self.dead=true; self.Parent=nil
end
function methods:ClearAllChildren()
    for _,v in ipairs(self:GetChildren()) do v:Destroy() end
end
function methods:IsA(kind)
    if self.ClassName == kind then return true end
    if kind == "BasePart" then
        return self.ClassName == "Part" or self.ClassName == "SpawnLocation" or self.ClassName == "WedgePart"
    end
    return false
end
Instance = {new=function(kind)
    local obj=setmetatable({
        ClassName=kind,
        Name=kind,
        attributes={},
        CanCollide=true,
        CanTouch=true,
        CanQuery=true,
        Anchored=false,
        Position=Vector3.new(0,0,0),
        Size=Vector3.new(4,1,2),
        CFrame=CFrame.new(0,0,0)
    }, {__index=methods})
    table.insert(all,obj); return obj
end}
Workspace=Instance.new("Folder")
Workspace.Name = "Workspace"
ReplicatedStorage={Common={}}
game={GetService=function(_,name) return name=="Workspace" and Workspace or ReplicatedStorage end}
'''


def run_map(assertions):
    config = (ROOT / "src/shared/StageConfig.luau").read_text()
    builder = (ROOT / "src/server/services/MapBuilderService.luau").read_text()
    builder = builder.replace("require(ReplicatedStorage.Common.StageConfig)", "LoadedStageConfig")
    source = ADAPTER + "\nlocal LoadedStageConfig = (function()\n" + config + "\nend)()\n"
    source += "local Builder = (function()\n" + builder + "\nend)()\nBuilder.start()\n" + assertions
    scratch = Path(os.environ.get("TMPDIR", str(ROOT / "build")))
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".luau", dir=scratch, mode="w", delete=False) as file:
        file.write(source)
        path = Path(file.name)
    try:
        result = subprocess.run([LUAU, str(path)], text=True, capture_output=True, timeout=15)
    finally:
        path.unlink()
    if result.returncode:
        raise AssertionError(result.stdout + result.stderr)


class MapGeometryTests(unittest.TestCase):
    def test_islands_climb_significantly_and_turn_gently(self):
        run_map(r'''
local stages=LoadedStageConfig.STAGES
assert(#stages==10)
local lastDirection=nil
local turns=0
for i=1,9 do
    local a,b=stages[i],stages[i+1]
    assert(b.pos.Y-a.pos.Y>=12,"missing significant ascent")
    local dx,dz=b.pos.X-a.pos.X,b.pos.Z-a.pos.Z
    local length=math.sqrt(dx*dx+dz*dz)
    local direction=Vector3.new(dx/length,0,dz/length)
    if lastDirection then
        local dot=direction.X*lastDirection.X+direction.Z*lastDirection.Z
        assert(dot>0.85,"abrupt route turn")
        if dot<0.999 then turns+=1 end
    end
    lastDirection=direction
end
assert(stages[10].pos.Y-stages[1].pos.Y>=180,"summit too low")
assert(turns>=6,"route remains straight")
''')

    def test_actual_generated_route_has_safe_edge_gaps_and_landing_sizes(self):
        run_map(r'''
local map=Workspace:FindFirstChild("SkyIslandsMap")
local islands=map:FindFirstChild("Islands")
local stones=map:FindFirstChild("SteppingStones")
assert(#islands:GetChildren()==10,"expected ten resting islands")
for index,data in ipairs(LoadedStageConfig.STAGES) do
    local island=islands:FindFirstChild("Island_"..data.stage)
    assert(island.Size.X>=20 and island.Size.Z>=20,"rest island below 20x20: "..data.stage)
    if index==10 then assert(island.Size.X>=48 and island.Size.Z>=48,"summit too small"); break end
    local route={island}
    for _,stone in ipairs(stones:GetChildren()) do
        if string.match(stone.Name,"^Stone_"..data.stage.."_") then table.insert(route,stone) end
    end
    table.sort(route,function(a,b)
        if a==island then return true end
        if b==island then return false end
        return tonumber(string.match(a.Name,"_(%d+)$"))<tonumber(string.match(b.Name,"_(%d+)$"))
    end)
    local target=LoadedStageConfig.STAGES[index+1]
    local delta=target.pos-data.pos
    local length=math.sqrt(delta.X^2+delta.Z^2)
    local dx,dz=delta.X/length,delta.Z/length
    local expectedRise=(target.pos.Y-data.pos.Y)/(#route)

    table.insert(route,islands:FindFirstChild("Island_"..(data.stage+1)))
    assert(#route>=3,"missing stepping route")
    for n=2,#route do
        local prev,part=route[n-1],route[n]
        local dist=math.sqrt((part.Position.X-prev.Position.X)^2+(part.Position.Z-prev.Position.Z)^2)
        local gap=dist-(prev.Size.Z+part.Size.Z)/2
        assert(gap>=2.5-0.005 and gap<=4+0.005,
            string.format("unsafe edge gap stage %d jump %d: %.3f",data.stage,n-1,gap))
        local rise=(part.Position.Y+part.Size.Y/2)-(prev.Position.Y+prev.Size.Y/2)
        assert(rise>=0 and rise<=2,"unsafe vertical rise")
        assert(math.abs(rise - expectedRise) < 0.05, "rise not divided proportionally")
        local proj = (part.Position.X - prev.Position.X) * dx + (part.Position.Z - prev.Position.Z) * dz
        local lateral = math.sqrt(((part.Position.X - prev.Position.X) - dx * proj)^2 + ((part.Position.Z - prev.Position.Z) - dz * proj)^2)
        assert(lateral < 1e-3, "stone deviated laterally from route segment")
        if n<#route then
            local minimum=data.stage==1 and 14 or (early and 12 or 10)
            assert(part.Size.X>=minimum and part.Size.Z>=minimum,"narrow stone stage "..data.stage)
        end
    end
end
''')

    def test_map_builder_idempotency_cleans_previous_build(self):
        run_map(r'''
-- Builder.start() was called once. Call it a second time.
Builder.buildIslands()
local map=Workspace:FindFirstChild("SkyIslandsMap")
local islands=map:FindFirstChild("Islands")
assert(#islands:GetChildren()==10,"idempotency failed: duplicate islands detected")
local checkpoints=Workspace:FindFirstChild("Checkpoints")
assert(#checkpoints:GetChildren()==10,"idempotency failed: duplicate checkpoints detected")
local before = #Workspace:GetDescendants()
Builder.start()
assert(#Workspace:GetDescendants()==before,"repeated build changed total instance count")
assert(before < 260,"graybox exceeded lightweight instance budget: "..before)
local obstacles = Workspace:FindFirstChild("Obstacles")
assert(#obstacles:GetChildren() >= 10, "obstacles folder missing tiered recovery zones")
for _, ob in ipairs(obstacles:GetChildren()) do
    assert(ob.Name == "KillBrick", "obstacle must be named KillBrick for ObstacleService compatibility")
    assert(ob.CanTouch, "fall recovery must emit touch events")
    assert(not ob.CanCollide, "fall recovery must not collide")
end
''')

    def test_spawn_location_present_on_stage_1_facing_positive_z(self):
        run_map(r'''
local spawns = Workspace:FindFirstChild("Spawns") or Workspace:FindFirstChild("SkyIslandsMap"):FindFirstChild("Spawns")
assert(spawns ~= nil, "Spawns folder missing")
local spawn = spawns:FindFirstChild("SpawnLocation")
assert(spawn ~= nil and spawn:IsA("SpawnLocation"), "SpawnLocation missing or not a SpawnLocation instance")
assert(spawn.Anchored == true, "SpawnLocation must be anchored")
assert(spawn.CanCollide == true, "SpawnLocation should have CanCollide true")
assert(spawn.Duration == 0, "SpawnLocation Duration should be 0 for clean cozy respawn")
assert(spawn.Neutral == true, "SpawnLocation must be neutral")
local d1 = LoadedStageConfig.STAGES[2].pos - LoadedStageConfig.STAGES[1].pos
local len1 = math.sqrt(d1.X^2 + d1.Z^2)
local dir1 = Vector3.new(d1.X / len1, 0, d1.Z / len1)
assert(math.abs(spawn.CFrame.LookVector.X - dir1.X) < 1e-3, "SpawnLocation must face segment 1 direction X")
assert(math.abs(spawn.CFrame.LookVector.Z - dir1.Z) < 1e-3, "SpawnLocation must face segment 1 direction Z")
assert(spawn.CFrame.LookVector.Z > 0.9, "SpawnLocation must face +Z towards stage progression")
assert(spawn.Position.Z < 0, "SpawnLocation should be located at the entry of Stage 1")
''')

    def test_summit_has_safety_railings_landing_area_and_finish_zone(self):
        run_map(r'''
local map = Workspace:FindFirstChild("SkyIslandsMap")
local summitRailings = map:FindFirstChild("SummitRailings")
assert(summitRailings ~= nil, "SummitRailings folder missing")
assert(#summitRailings:GetChildren() >= 3, "Summit requires safety railings around perimeter")
for _, railing in ipairs(summitRailings:GetChildren()) do
    assert(railing:IsA("BasePart"), "Railing must be a BasePart")
    assert(railing.CanCollide == true, "Railing must have CanCollide = true to prevent accidental falls")
    assert(railing.Anchored == true, "Railing must be anchored")
end

local landingAreas = map:FindFirstChild("LandingAreas")
assert(landingAreas ~= nil, "LandingAreas folder missing")
local summitLanding = landingAreas:FindFirstChild("Landing_10")
assert(summitLanding ~= nil, "Summit landing area indicator missing")

local finishZone = map:FindFirstChild("SummitFinishZone")
assert(finishZone ~= nil and finishZone:IsA("BasePart"), "SummitFinishZone missing")
assert(finishZone.CanCollide == false, "SummitFinishZone must not block players")
''')

    def test_tasteful_silhouette_and_decorations_have_cancollide_false(self):
        run_map(r'''
local map = Workspace:FindFirstChild("SkyIslandsMap")
local silhouettes = map:FindFirstChild("Silhouettes")
assert(silhouettes ~= nil, "Silhouettes folder missing for floating-island underbellies")
assert(#silhouettes:GetChildren() >= 10, "Each island should have a floating-island silhouette underbelly")
for _, part in ipairs(silhouettes:GetChildren()) do
    assert(part.CanCollide == false, "Silhouette parts must have CanCollide = false to prevent collision issues")
end

local decorations = map:FindFirstChild("Decorations")
assert(decorations ~= nil, "Decorations folder missing")
for _, part in ipairs(decorations:GetChildren()) do
    assert(part.CanCollide == false, "Decorative parts must have CanCollide = false per PRD collision rules")
end
''')

    def test_checkpoints_face_positive_z(self):
        run_map(r'''
local stages = LoadedStageConfig.STAGES
local checkpoints = Workspace:FindFirstChild("Checkpoints")
assert(checkpoints ~= nil, "Checkpoints folder missing")
for stage = 1, 9 do
    local cp = checkpoints:FindFirstChild("Checkpoint_" .. stage)
    assert(cp ~= nil, "Checkpoint_" .. stage .. " missing")
    local d = stages[stage + 1].pos - stages[stage].pos
    local len = math.sqrt(d.X^2 + d.Z^2)
    local dir = Vector3.new(d.X / len, 0, d.Z / len)
    assert(math.abs(cp.CFrame.LookVector.X - dir.X) < 1e-3, "Checkpoint_" .. stage .. " lookVector X mismatch")
    assert(math.abs(cp.CFrame.LookVector.Z - dir.Z) < 1e-3, "Checkpoint_" .. stage .. " lookVector Z mismatch")
end
local cp10 = checkpoints:FindFirstChild("Checkpoint_10")
assert(cp10 ~= nil, "Checkpoint_10 missing")
assert(cp10.CFrame.LookVector.Z > 0.9, "Checkpoint_10 must face forward into summit")
''')

    def test_fall_recovery_zones_tiered_per_segment(self):
        run_map(r'''
local stages = LoadedStageConfig.STAGES
local obstacles = Workspace:FindFirstChild("Obstacles")
assert(obstacles ~= nil, "Obstacles folder missing")
local killBricks = obstacles:GetChildren()
assert(#killBricks == 10, "expected 10 tiered fall recovery zones (1 per stage segment)")

local minY, maxY = 9999, -9999
for index, data in ipairs(stages) do
    local kb = nil
    for _, child in ipairs(killBricks) do
        if child:GetAttribute("StageSegment") == data.stage then
            kb = child
            break
        end
    end
    assert(kb ~= nil, "missing recovery zone for stage " .. index)
    assert(kb.Position.Y < data.pos.Y, "recovery zone must be below stage " .. index)
    assert(kb.Position.Y >= data.pos.Y - 35, "recovery zone too far below stage " .. index)
    if kb.Position.Y < minY then minY = kb.Position.Y end
    if kb.Position.Y > maxY then maxY = kb.Position.Y end
end
assert(maxY - minY >= 150, "recovery zones must be tiered across significant vertical ascent")
''')


if __name__ == "__main__":
    unittest.main()
