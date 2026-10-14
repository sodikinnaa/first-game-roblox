from test_map_geometry import run_map
import test_summit_mechanics
import unittest

class Stage1Geometry(unittest.TestCase):
    def test_exact_table_join_and_rebuild(self):
        run_map(r'''
local map=Workspace:FindFirstChild("SkyIslandsMap")
local islands=map:FindFirstChild("Islands")
local stones=map:FindFirstChild("SteppingStones")
local route={islands:FindFirstChild("Island_1"),stones:FindFirstChild("FirstJump")}
assert(route[2],"missing approved tutorial platform")
for i=1,6 do table.insert(route,stones:FindFirstChild("Stone_1_"..i)) end
table.insert(route,stones:FindFirstChild("Rest"))
table.insert(route,islands:FindFirstChild("Island_2"))
assert(#route==10)
local function near(a,b) assert(math.abs(a-b)<0.0001,string.format("%.8f != %.8f",a,b)) end
for i,p in ipairs(route) do
    assert(p.Anchored and p.CanCollide and not p.CanTouch)
    near(p.Size.Y,2)
    if i>=2 and i<=8 then near(p.Size.X,14); near(p.Size.Z,14) end
    if i>=3 and i<=8 then near(p.Position.Y,10+12*(i-2)/7); near(p.Position.Z,37.8+16.8*(i-3)) end
    if i>1 then
        local prev=route[i-1]
        local gap=i==10 and p.Position.X-prev.Position.X-(p.Size.X+prev.Size.X)/2 or p.Position.Z-prev.Position.Z-(p.Size.Z+prev.Size.Z)/2
        near(gap,i==2 and 2 or (i==10 and 0 or 2.8))
        near(p.Position.Y-prev.Position.Y,(i==2 or i==10) and 0 or 12/7)
    end
end
near(route[9].Position.Z,143.6); near(route[10].Position.X,24)
near(route[10].CFrame.LookVector.X,0); near(route[10].CFrame.LookVector.Z,-1)
local cp=Workspace:FindFirstChild("Checkpoints"):FindFirstChild("Checkpoint_2")
near(cp.Position.X,24); near(cp.Position.Y,23.25); near(cp.Position.Z,143.6)
near(cp.CFrame.LookVector.X,1); near(cp.CFrame.LookVector.Z,0)
local departure=stones:FindFirstChild("Stone_2_1")
assert(departure.Position.X>36 and math.abs(departure.Position.Z-143.6)<0.001,"Stage2 must depart +X")
for _,p in ipairs(stones:GetChildren()) do
    if not string.match(p.Name,"^Stone_1_") and p.Name~="FirstJump" and p.Name~="Rest" then
        for _,s in ipairs(route) do
            assert(math.abs(p.Position.X-s.Position.X)>=(p.Size.X+s.Size.X)/2-0.001 or math.abs(p.Position.Z-s.Position.Z)>=(p.Size.Z+s.Size.Z)/2-0.001,"downstream overlaps Stage1")
        end
    end
end
local count=#Workspace:GetDescendants(); Builder.start(); assert(count==#Workspace:GetDescendants())
''')

class RespawnRegression(unittest.TestCase):
    run_luau = test_summit_mechanics.TestSummitMechanics.run_luau
    def test_rotated_checkpoint_preserves_orientation_and_height(self):
        self.run_luau([('CheckpointService','src/server/services/CheckpointService.luau')], '''
local player=newPlayer(); local root=newPart("HumanoidRootPart")
local character={HumanoidRootPart=root}; function character:WaitForChild(n) return self[n] end
player.Character=character
local cp=newPart("Checkpoint_2"); cp.Position=vector(24,23.25,143.6)
workspace.Checkpoints={FindFirstChild=function() return cp end}
stage=2
for _,dir in ipairs({vector(1,0,0),vector(-1,0,0),vector(0,0,-1)}) do
    cp.CFrame=CFrame.lookAt(cp.Position,cp.Position+dir)
    CheckpointService.teleportToCheckpoint(player,character)
    assert(root.CFrame.Position.Y==26.75)
    assert(root.CFrame.LookVector.X==dir.X and root.CFrame.LookVector.Z==dir.Z,"hardcoded respawn facing")
end
''')
