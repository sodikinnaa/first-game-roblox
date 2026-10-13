"""Execute shipped Luau in the Luau CLI with a small Roblox API test double.
Not a Python gameplay emulator or a substitute for Studio multiplayer playtests.
Set LUAU_BIN if the CLI is installed elsewhere.
"""
import os
from pathlib import Path
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
LUAU = os.environ.get('LUAU_BIN') or shutil.which('luau') or str(ROOT / 'build/tools/luau')


class TestSummitMechanics(unittest.TestCase):
    def run_luau(self, files, scenario):
        if not Path(LUAU).is_file():
            self.skipTest('Luau CLI unavailable; Studio runtime verification pending')
        chunks = [(ROOT / 'tests/roblox_test_double.luau').read_text()]
        for name, path in files:
            source = ROOT / path
            self.assertTrue(source.is_file(), f'Missing shipped module: {path}')
            chunks.append(f'local {name} = (function()\n{source.read_text()}\nend)()\nmodules["{name}"] = {name}\nreplicatedStorage.Common["{name}"] = "{name}"\nscript.Parent["{name}"] = "{name}"\n')
        chunks.append(scenario)
        build = ROOT / 'build'
        build.mkdir(exist_ok=True)
        target = build / 'test_summit.luau'
        target.write_text('\n'.join(chunks))
        result = subprocess.run([LUAU, str(target)], text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_finish_validation_idempotence_and_leave(self):
        self.run_luau([
            ('SummitConfig', 'src/shared/SummitConfig.luau'),
            ('SummitService', 'src/server/services/SummitService.luau'),
        ], '''
local player = newPlayer()
local zone = newPart("SummitFinishZone", vector(16, 8, 16))
local root = newPart("HumanoidRootPart", vector(2, 2, 1))
local humanoid = { Health = 100 }
local character = { HumanoidRootPart = root }
function character:FindFirstChild(name) return self[name] end
function character:FindFirstChildOfClass(_) return humanoid end
player.Character = character
local progress = 8
modules.CheckpointService.hasReached = function(_, stage) return progress >= stage end
SummitService.start(zone)
assert(not SummitService.tryFinish(player), "missing checkpoint accepted")
progress = 9
humanoid.Health = 0
assert(not SummitService.tryFinish(player), "dead character accepted")
humanoid.Health = 100
root.Position = vector(9, 0, 0)
assert(not SummitService.tryFinish(player), "outside zone accepted")
root.Position = vector(0, 0, 0)
assert(SummitService.tryFinish(player), "valid finish rejected")
assert(player:GetAttribute("Completed") == true)
assert(stage == 10)
assert(#sent == 1 and sent[1][1] == player, "event not player scoped")
assert(not SummitService.tryFinish(player), "duplicate finish accepted")
assert(#sent == 1 and coinCalls == 0, "duplicate event or new economy")
players.PlayerRemoving:Fire(player)
assert(player:GetAttribute("Completed") == nil, "leave state not cleared")
assert(not SummitService.isCompleted(player))
''')


    def test_player_collision_assignment_existing_and_new_parts(self):
        self.run_luau([('PlayerCollisionService', 'src/server/services/PlayerCollisionService.luau')], '''
local physics = {}
function physics:IsCollisionGroupRegistered(name) return false end
function physics:RegisterCollisionGroup(name) self.registered = name end
function physics:CollisionGroupSetCollidable(a,b,value) self.collidable = value end
services.PhysicsService.IsCollisionGroupRegistered = physics.IsCollisionGroupRegistered
services.PhysicsService.RegisterCollisionGroup = physics.RegisterCollisionGroup
services.PhysicsService.CollisionGroupSetCollidable = physics.CollisionGroupSetCollidable
physics = services.PhysicsService
local part = newPart("Root")
local character = {DescendantAdded=newSignal(),GetDescendants=function() return {part} end}
local player = newPlayer()
player.Character = character
player.CharacterAdded = newSignal()
players.GetPlayers = function() return {player} end
PlayerCollisionService.start()
assert(physics.collidable == false)
assert(part.CollisionGroup == "SkyIslandPlayers")
local accessory = newPart("AccessoryHandle")
character.DescendantAdded:Fire(accessory)
assert(accessory.CollisionGroup == "SkyIslandPlayers")
''')

    def test_checkpoint_history_requires_every_stage(self):
        self.run_luau([('CheckpointService','src/server/services/CheckpointService.luau')], '''
local player = newPlayer()
local root = newPart("HumanoidRootPart")
local character = {HumanoidRootPart=root,_player=player}
function character:FindFirstChild(n) return self[n] end
function character:FindFirstChildOfClass(_) return {Health=100} end
player.Character = character
local cp9 = newPart("Checkpoint_9", vector(8,1,8))
CheckpointService.onCheckpointTouched(cp9,9)
stage = 8
cp9.Touched:Fire({FindFirstAncestorOfClass=function() return character end})
assert(not CheckpointService.hasReached(player,9), "missing historical sequence trusted")
''')

    def test_checkpoint_history_alive_position_existing_character_and_facing(self):
        self.run_luau([('CheckpointService', 'src/server/services/CheckpointService.luau')], '''
local player = newPlayer()
local root = newPart("HumanoidRootPart")
local humanoid = { Health = 100 }
local character = { HumanoidRootPart = root, _player = player }
function character:FindFirstChild(n) return self[n] end
function character:WaitForChild(n) return self[n] end
function character:FindFirstChildOfClass(_) return humanoid end
player.Character = character
player.CharacterAdded = newSignal()
players.GetPlayers = function() return { player } end
local cp1 = newPart("Checkpoint_1", vector(8, 1, 8))
local cp2 = newPart("Checkpoint_2", vector(8, 1, 8))
local cp3 = newPart("Checkpoint_3", vector(8, 1, 8))
local cp10 = newPart("Checkpoint_10", vector(8, 1, 8))
workspace.Checkpoints = {
    FindFirstChild = function(_, n) return ({ Checkpoint_1=cp1, Checkpoint_2=cp2, Checkpoint_3=cp3 })[n] end,
    GetChildren = function() return {cp1, cp2, cp3, cp10} end,
}
CheckpointService.start()
assert(root.CFrame.Position.Y == 3.5 and root.CFrame.LookVector.Z > 0, "existing character not facing +Z")
local hit = {FindFirstAncestorOfClass=function() return character end}
cp3.Touched:Fire(hit)
assert(stage == 1, "skipped checkpoint accepted")
humanoid.Health = 0
cp2.Touched:Fire(hit)
assert(stage == 1, "dead checkpoint accepted")
humanoid.Health = 100
root.Position = vector(100, 0, 0)
cp2.Touched:Fire(hit)
assert(stage == 1, "out of bounds checkpoint accepted")
root.Position = vector(0, 0, 0)
cp2.Touched:Fire(hit)
assert(stage == 2 and CheckpointService.hasReached(player, 2), "valid checkpoint rejected")
cp2.Touched:Fire(hit)
assert(coinCalls == 1, "existing stage reward duplicated")
cp3.Touched:Fire(hit)
assert(stage == 3 and coinCalls == 2)
assert(not CheckpointService.hasReached(player, 9), "leaderstats alone trusted")
stage = 9
cp10.Touched:Fire(hit)
assert(stage == 9, "checkpoint auto finished stage 10")
CheckpointService.start()
assert(#player.CharacterAdded.listeners == 1, "duplicate startup")
players.PlayerRemoving:Fire(player)
assert(not CheckpointService.hasReached(player, 2), "history retained after leave")
''')

    def test_configuration_fallback_and_bounds(self):
        self.run_luau([('SummitConfig', 'src/shared/SummitConfig.luau')], '''
assert(SummitConfig.PresetId == "Neutral")
for _, option in pairs(SummitConfig.Personalization) do
    if type(option) == "table" then assert(option.Enabled == false) end
end
for _, bad in ipairs({false, {}, {SchemaVersion=99}, {SchemaVersion=1, PresetId="Birthday"}}) do
    assert(SummitConfig.resolve(bad).Title == "Puncak Tercapai!")
end
local custom = {SchemaVersion=1, PresetId="Neutral", Core={BannerTitle="Hello", BannerDurationSeconds=999}}
assert(SummitConfig.resolve(custom).Title == "Hello")
assert(SummitConfig.resolve(custom).DurationSeconds == 10)
custom.Core.BannerDurationSeconds = 0/0
assert(SummitConfig.resolve(custom).DurationSeconds == 5)
''')

    def test_client_static_local_banner_has_cleanup_and_mobile_width(self):
        source = (ROOT / 'src/client/controllers/SummitController.luau').read_text()
        self.assertIn('OnClientEvent:Connect', source)
        self.assertIn('player.CharacterAdded:Connect', source)
        self.assertIn('UDim2.new(0.9', source)
        self.assertNotIn('TweenService', source)
        self.assertNotIn('CurrentCamera', source)
        self.assertNotIn('SoundId', source)

    def test_entrypoints_generate_map_before_binding_and_start_client(self):
        server = (ROOT / 'src/server/Main.server.luau').read_text()
        self.assertIn('MapBuilderService.start()', server)
        for service in ['CheckpointService', 'SummitService', 'ObstacleService']:
            self.assertLess(server.index('MapBuilderService.start()'), server.index(service + '.start()'))
        client = (ROOT / 'src/client/Main.client.luau').read_text()
        self.assertIn('SummitController.start()', client)
        self.assertLess(client.index('SummitController.start()'), client.index('HUDController.start()'))


if __name__ == '__main__':
    unittest.main()
