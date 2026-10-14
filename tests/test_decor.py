import unittest
import test_summit_mechanics
class DecorTests(unittest.TestCase):
    run_luau=test_summit_mechanics.TestSummitMechanics.run_luau
    def run_decor(self, scenario):
        adapter = (test_summit_mechanics.ROOT / 'tests/decor_test_double.luau').read_text()
        source = (test_summit_mechanics.ROOT / 'src/server/services/DecorAssetService.luau').read_text()
        self.run_luau([], adapter + '\nlocal DecorAssetService=(function()\n' + source + '\nend)()\n' + scenario)

    def test_offset_pivot_places_bounds_bottom_on_surface(self):
        self.run_decor('''
local model=decorModel(1,vector(2,-5,3))
services.AssetService={LoadAssetAsync=function() return model end}
assert(DecorAssetService.load(118266415097960,decorNode("Target"),vector(9,11,2),4,nil))
local box,size=model:GetBoundingBox()
near(box.Position.Y-size.Y/2,11,"tree sunk under surface: pivot is not bottom")
near(box.Position.X,9); near(box.Position.Z,2)
''')

    def test_noncanonical_scale_reaches_requested_height(self):
        self.run_decor('''
local model=decorModel(2,vector(0,0,0))
services.AssetService={LoadAssetAsync=function() return model end}
assert(DecorAssetService.load(118266415097960,decorNode("Target"),vector(9,11,2),4,nil))
near(model:GetExtentsSize().Y,4,"ScaleTo is absolute: existing canonical scale must be included")
''')

    def test_start_loading_and_success_replace_only_matching_shrub(self):
        self.run_decor('''
local map=decorNode("SkyIslandsMap",workspace)
local decorations=decorNode("Decorations",map)
local shrubs={}
for _,side in ipairs({-1,1}) do shrubs["Shrub_1_"..side]=decorNode("Shrub_1_"..side,decorations) end
function decorations:FindFirstChild(n) return shrubs[n] end
function map:FindFirstChild(n) return n=="Decorations" and decorations or nil end
workspace.SkyIslandsMap=map
local jobs={}; task.spawn=function(fn) table.insert(jobs,fn) end
local created={}; Instance.new=function(class) local n=decorNode(class); table.insert(created,n); return n end
services.AssetService={LoadAssetAsync=function() return decorModel(2,vector(2,-5,3)) end}
DecorAssetService.start(); assert(#jobs==2)
for _,side in ipairs({-1,1}) do
    assert(decorations:GetAttribute("KenneyTree_"..side.."Status")=="Loading","pending network load invisible")
    assert(not shrubs["Shrub_1_"..side].dead)
end
for _,fn in ipairs(jobs) do fn() end
for i,side in ipairs({-1,1}) do
    assert(created[i].Name=="KenneyTree_"..side and created[i].Parent==decorations)
    assert(created[i]:GetAttribute("Status")=="Loaded")
    assert(decorations:GetAttribute("KenneyTree_"..side.."Status")=="Loaded")
    assert(shrubs["Shrub_1_"..side].dead)
end
assert(#warnings==0)
''')

    def test_start_reports_sanitized_failure_and_keeps_fallback(self):
        self.run_decor('''
local map=decorNode("SkyIslandsMap",workspace)
local decorations=decorNode("Decorations",map)
local shrubs={}
for _,side in ipairs({-1,1}) do shrubs["Shrub_1_"..side]=decorNode("Shrub_1_"..side,decorations) end
function decorations:FindFirstChild(n) return shrubs[n] end
function map:FindFirstChild(n) return n=="Decorations" and decorations or nil end
workspace.SkyIslandsMap=map
services.AssetService={LoadAssetAsync=function() error("secret injected raw error") end}
DecorAssetService.start()
for _,side in ipairs({-1,1}) do
    assert(decorations:GetAttribute("KenneyTree_"..side.."Status")=="LoadFailed","missing persistent load diagnosis")
    assert(not shrubs["Shrub_1_"..side].dead)
end
assert(#warnings==2)
for _,w in ipairs(warnings) do assert(not string.find(w,"secret")); assert(string.find(w,"LoadFailed")) end
''')

    def test_rebuild_or_removed_decorations_do_not_replace_fallback(self):
        self.run_decor('''
for _,detach in ipairs({"map","decorations"}) do
    local map=decorNode("SkyIslandsMap",workspace)
    local decorations=decorNode("Decorations",map)
    local fallback=decorNode("Shrub",decorations)
    function decorations:FindFirstChild(n) return fallback end
    function map:FindFirstChild(n) return decorations end
    workspace.SkyIslandsMap=map
    local created={}; Instance.new=function(c) local n=decorNode(c); table.insert(created,n); return n end
    services.AssetService={LoadAssetAsync=function()
        if detach=="map" then map.Parent=nil else decorations.Parent=nil end
        return decorModel(1,vector(0,0,0))
    end}
    DecorAssetService.start()
    for _,n in ipairs(created) do assert(n.dead and not n.Parent,"orphan decor leaked during yielded load") end
    assert(not fallback.dead)
end
workspace.SkyIslandsMap=decorNode("Empty",workspace)
function workspace.SkyIslandsMap:FindFirstChild() return nil end
DecorAssetService.start() -- missing Decorations cannot dereference nil
''')

    def test_rejected_models_keep_fallback_and_destroy_staging(self):
        self.run_decor('''
for _,case in ipairs({"scriptOnly","overBudget","placementError"}) do
    local m=decorModel(1,vector(0,0,0))
    if case=="scriptOnly" then
        function m:GetDescendants() return {{IsA=function(_,c) return c=="LuaSourceContainer" end,Destroy=function() end}} end
    elseif case=="overBudget" then
        function m:GetDescendants() local list={}; for i=1,81 do table.insert(list,newPart()) end; return list end
    else function m:GetBoundingBox() error("private raw payload") end end
    services.AssetService={LoadAssetAsync=function() return m end}
    local fallback=decorNode("Shrub")
    local ok,status=DecorAssetService.load(118266415097960,decorNode("Target"),vector(0,11,0),4,fallback)
    assert(not ok and m.dead and not fallback.dead)
    assert(status==(case=="placementError" and "PlacementFailed" or "ValidationFailed"))
end
''')

    def test_strip_scripts_flags_and_fallback_on_failure(self):
        self.run_decor('''
local part=newPart("Mesh"); local executable={ClassName="Script",IsA=function(_,c) return c=="LuaSourceContainer" end,Destroy=function(self) self.dead=true end}
local model=decorModel(1,vector(0,0,0))
function model:GetDescendants() return {part,executable} end
services.AssetService={LoadAssetAsync=function(_,id) assert(id==118266415097960); return model end}
local fallback={Destroy=function(self) self.dead=true end}
assert(DecorAssetService.load(118266415097960,{},vector(0,11,0),4,fallback))
assert(executable.dead and part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery and fallback.dead)
services.AssetService.LoadAssetAsync=function() error("unavailable") end
fallback.dead=false
assert(not DecorAssetService.load(118266415097960,{},vector(0,11,0),4,fallback)); assert(not fallback.dead)
''')
