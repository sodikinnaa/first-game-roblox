import unittest
import test_summit_mechanics
class DecorTests(unittest.TestCase):
    run_luau=test_summit_mechanics.TestSummitMechanics.run_luau
    def test_strip_scripts_flags_and_fallback_on_failure(self):
        self.run_luau([('DecorAssetService','src/server/services/DecorAssetService.luau')], '''
local part=newPart("Mesh"); local executable={ClassName="Script",IsA=function(_,c) return c=="LuaSourceContainer" end,Destroy=function(self) self.dead=true end}
local model={IsA=function(_,c) return c=="Model" end,GetDescendants=function() return {part,executable} end,ScaleTo=function() end,PivotTo=function() end,GetExtentsSize=function() return vector(2,3,2) end,GetPivot=function() return CFrame.new(vector(0,0,0)) end}
services.AssetService={LoadAssetAsync=function(_,id) assert(id==118266415097960); return model end}
local fallback={Destroy=function(self) self.dead=true end}
assert(DecorAssetService.load(118266415097960,{},vector(0,11,0),4,fallback))
assert(executable.dead and part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery and fallback.dead)
services.AssetService.LoadAssetAsync=function() error("unavailable") end
fallback.dead=false
assert(not DecorAssetService.load(118266415097960,{},vector(0,11,0),4,fallback)); assert(not fallback.dead)
''')
