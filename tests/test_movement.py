import unittest
import test_summit_mechanics
class MovementTests(unittest.TestCase):
    run_luau=test_summit_mechanics.TestSummitMechanics.run_luau
    def test_server_profile_and_r15_replacement(self):
        self.run_luau([('MovementConfig','src/shared/MovementConfig.luau'),('MovementService','src/server/services/MovementService.luau')], '''
Enum={HumanoidRigType={R15="R15",R6="R6"}}
local hum={RigType="R15",FindFirstChild=function(self,n) return self[n] end}
for _,n in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale","BodyTypeScale","BodyProportionScale"}) do hum[n]={Value=9} end
local char={FindFirstChildOfClass=function() return hum end}
local player=newPlayer(); player.Character=char; player.CharacterAdded=newSignal(); player.CharacterAppearanceLoaded=newSignal()
players.GetPlayers=function() return {player} end
MovementService.start()
assert(workspace.Gravity==196.2 and hum.WalkSpeed==16 and hum.UseJumpPower and hum.JumpPower==50)
assert(hum.BodyHeightScale.Value==1 and hum.HeadScale.Value==1 and hum.BodyTypeScale.Value==0)
hum.BodyHeightScale.Value=4; player.CharacterAppearanceLoaded:Fire(char); assert(hum.BodyHeightScale.Value==1)
local old={FindFirstChildOfClass=function() return {RigType="R6",GetAppliedDescription=function() return {} end} end,Destroy=function(self) self.dead=true end}
players.CreateHumanoidModelFromDescriptionAsync=function(_,description,rig) assert(rig=="R15"); return char end
player.Character=old; player.CharacterAdded:Fire(old)
assert(player.Character==char and old.dead,"R6 not replaced by requested R15")
''')
