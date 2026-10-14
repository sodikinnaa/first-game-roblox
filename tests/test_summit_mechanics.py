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
cp1.CFrame=CFrame.lookAt(cp1.Position,cp1.Position+vector(0,0,1))
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
    if type(option) == "table" and option ~= SummitConfig.Personalization.Confetti then assert(option.Enabled == false) end
end
local confetti = SummitConfig.Personalization.Confetti
assert(confetti.Enabled and confetti.Type == "World3D", "3D default missing")
assert(confetti.DurationSeconds >= 3 and confetti.DurationSeconds <= 5)
assert(confetti.MaxLiveParticles >= 40 and confetti.MaxLiveParticles <= 60)
assert(#confetti.Colors >= 3)
assert(SummitConfig.Replay.Enabled and not SummitConfig.Replay.GrantRewards)
for _, color in ipairs(confetti.Colors) do
    assert(#color == 3)
    for _, channel in ipairs(color) do assert(channel >= 150 and channel <= 255) end
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

    def run_luau_client(self, scenario):
        if not Path(LUAU).is_file():
            self.skipTest('Luau CLI unavailable; Studio runtime verification pending')
        chunks = [
            (ROOT / 'tests/roblox_test_double.luau').read_text(),
            (ROOT / 'tests/summit_client_test_double.luau').read_text(),
        ]
        for name, rel_path in [
            ('SummitConfig', 'src/shared/SummitConfig.luau'),
            ('ConfettiController', 'src/client/controllers/ConfettiController.luau'),
            ('SummitController', 'src/client/controllers/SummitController.luau'),
        ]:
            source = ROOT / rel_path
            self.assertTrue(source.is_file(), f'Missing shipped module: {rel_path}')
            chunks.append(f'local {name} = (function()\n{source.read_text()}\nend)()\nmodules["{name}"] = {name}\nreplicatedStorage.Common["{name}"] = "{name}"\nscript.Parent["{name}"] = "{name}"\n')
        chunks.append(scenario)
        build = ROOT / 'build'
        build.mkdir(exist_ok=True)
        target = build / 'test_summit_client.luau'
        target.write_text('\n'.join(chunks))
        result = subprocess.run([LUAU, str(target)], text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_confetti_controller_lifecycle_and_instant_cleanup(self):
        self.run_luau_client('''
local config = SummitConfig.resolve(SummitConfig)
assert(config.Confetti and config.Confetti.Enabled, "confetti not enabled in resolved config")
assert(ConfettiController.getState() == "Ready")
ConfettiController.start(config.Confetti)
assert(ConfettiController.getState() == "Playing")
assert(liveCount("Attachment") == 1, "attachment not mounted on character")
assert(liveCount("ParticleEmitter") == 1, "emitter not created")
local emitter = findLive("SummitConfettiEmitter")
assert(emitter and emitter.emitted > 0, "burst emitted count zero")
assert(emitter.Texture == "rbxasset://textures/particles/sparkles_main.dds", "native texture missing")
assert(emitter.Rate == 0 and emitter.Enabled == false)
assert(emitter.Lifetime.Max <= config.Confetti.DurationSeconds)
assert(emitter.Acceleration.Y < 0 and not emitter.LockedToPart)
assert(not ConfettiController.start(config.Confetti), "active burst stacked")
assert(emitter.emitted <= 60, "exceeded max particles safe limit")

advance(1)
ConfettiController.stop()
assert(ConfettiController.getState() == "Ready")
assert(liveCount("Attachment") == 0, "attachment leaked after stop")
assert(liveCount("ParticleEmitter") == 0, "emitter leaked after stop")

-- Character respawn cleanup
ConfettiController.start(config.Confetti)
assert(liveCount("Attachment") == 1)
player.CharacterAdded:Fire(character())
assert(ConfettiController.getState() == "Ready")
assert(liveCount("Attachment") == 0, "attachment leaked after character respawn")
assert(pendingJobs() == 0)
assert(listenerCount(player.CharacterAdded) == 0)
assert(listenerCount(player.CharacterRemoving) == 0)
ConfettiController.start(config.Confetti)
local root = player.Character:FindFirstChild("HumanoidRootPart")
root.Parent = nil
root.AncestryChanged:Fire()
assert(liveCount("Attachment") == 0 and pendingJobs() == 0, "root removal leaked effects")
root.Parent = player.Character
ConfettiController.start(config.Confetti)
advance(config.Confetti.DurationSeconds)
assert(liveCount("Attachment") == 0 and pendingJobs() == 0, "natural expiry leaked")
''')

    def test_summit_controller_free_camera_reduced_motion_and_replay_cooldown(self):
        self.run_luau_client('''
SummitController.start()
local config = SummitConfig.resolve(SummitConfig)

-- First finish event
remote.OnClientEvent:Fire(config)
assert(findLive("SummitCelebrationGui") ~= nil, "banner GUI not displayed")
assert(ConfettiController.getState() == "Playing", "confetti not started on finish")
assert(liveCount("Camera") == 0, "camera manipulated or cutscene camera spawned")

-- Replay protection during playing
local replayBtn = findLive("ReplayButton")
assert(replayBtn ~= nil, "replay button missing")
assert(SummitController.canReplay() == false, "replay allowed while playing")
replayBtn.Activated:Fire()
assert(coinCalls == 0, "replay granted coins")

-- Advance to cooldown
advance(config.Confetti.DurationSeconds + 0.1)
assert(ConfettiController.getState() == "Ready")
assert(SummitController.canReplay() == false, "replay allowed during cooldown")

-- Advance past cooldown
advance(config.Replay.CooldownSeconds)
assert(SummitController.canReplay() == true, "replay not ready after cooldown")

-- Replay click triggers celebration without coins
replayBtn.Activated:Fire()
assert(ConfettiController.getState() == "Playing")
assert(coinCalls == 0, "replay click granted rewards")

-- Reduced motion suppresses 3D confetti
ConfettiController.stop()
settings.ReducedMotion = true
remote.OnClientEvent:Fire(config)
assert(findLive("SummitCelebrationGui") ~= nil, "banner not displayed under reduced motion")
assert(liveCount("ParticleEmitter") == 0, "3D particles emitted under reduced motion")
''')

    def test_optional_config_malformed_colors_fall_back_safely(self):
        self.run_luau([('SummitConfig', 'src/shared/SummitConfig.luau')], '''
local cfg = table.clone(SummitConfig)
cfg.Personalization = {Confetti={Enabled=true, Type="World3D", DurationSeconds=0/0,
    MaxLiveParticles=9999, Colors={{"oops", {}, 0/0}, {200,210,220}}}}
local resolved = SummitConfig.resolve(cfg)
assert(resolved.Confetti.DurationSeconds == 4)
assert(resolved.Confetti.MaxLiveParticles == 60)
assert(#resolved.Confetti.Colors == 1, "invalid colors not discarded")
cfg.PresetId = "Festive"
assert(SummitConfig.resolve(cfg).Confetti ~= nil)
cfg.SchemaVersion = 99
assert(SummitConfig.resolve(cfg).Confetti == nil)
''')

    def test_client_death_interruption_and_stop_release_all_resources(self):
        self.run_luau_client('''
SummitController.start()
SummitController.start()
assert(listenerCount(remote.OnClientEvent) == 1, "startup not idempotent")
remote.OnClientEvent:Fire({})
local first = findLive("SummitConfettiEmitter")
remote.OnClientEvent:Fire({})
assert(findLive("SummitConfettiEmitter") == first, "duplicate finish restarts effects")
player.Character:FindFirstChildOfClass("Humanoid").Died:Fire()
assert(liveCount("ParticleEmitter") == 0)
assert(liveCount("ScreenGui") == 0, "death left presentation GUI")
assert(pendingJobs() == 0, "death left delayed callbacks")
assert(not SummitController.canReplay(), "replay possible without presentation")
SummitController.stop()
assert(listenerCount(remote.OnClientEvent) == 0)
assert(listenerCount(player.CharacterAdded) == 0)
assert(listenerCount(player.CharacterRemoving) == 0)
assert(listenerCount(settings.changed) == 0)

-- Restart, accessibility changes immediately clear an active burst.
SummitController.start()
remote.OnClientEvent:Fire({})
settings.ReducedMotion = true
settings.changed:Fire()
assert(liveCount("ParticleEmitter") == 0)
assert(findLive("BannerFrame").Visible ~= false, "reduced motion lost static banner")
SummitController.stop()
assert(pendingJobs() == 0)
assert(liveCount("ScreenGui") == 0)

-- Already enabled reduced motion yields a static banner, no burst.
SummitController.start()
remote.OnClientEvent:Fire({})
assert(liveCount("ParticleEmitter") == 0)
assert(findLive("BannerFrame") ~= nil)
SummitController.stop()

-- Missing root and emitter failure cannot leak instances or connections.
settings.ReducedMotion = false
local root = player.Character:FindFirstChild("HumanoidRootPart")
root.Parent = nil
assert(not ConfettiController.start(SummitConfig.resolve(SummitConfig).Confetti))
root.Parent = player.Character
local factory = Instance.new
Instance.new = function(class)
    local obj = factory(class)
    if class == "ParticleEmitter" then function obj:Emit(_) error("injected emit failure") end end
    return obj
end
assert(not ConfettiController.start(SummitConfig.resolve(SummitConfig).Confetti))
assert(liveCount("Attachment") == 0 and liveCount("ParticleEmitter") == 0)
assert(pendingJobs() == 0)
assert(listenerCount(player.CharacterAdded) == 0)
Instance.new = factory
''')

    def test_client_static_local_banner_has_cleanup_and_mobile_width(self):
        source = (ROOT / 'src/client/controllers/SummitController.luau').read_text()
        self.assertIn('OnClientEvent:Connect', source)
        self.assertIn('player.CharacterAdded:Connect', source)
        self.assertIn('UDim2.new(0.9', source)
        self.assertNotIn('TweenService', source)
        self.assertNotIn('CurrentCamera', source)
        self.assertNotIn('SoundId', source)
        confetti = (ROOT / 'src/client/controllers/ConfettiController.luau').read_text()
        for forbidden in ['CurrentCamera', 'CameraType', 'ContextActionService', 'WalkSpeed', 'PlatformStand', 'Controls:Disable', 'RenderStepped']:
            self.assertNotIn(forbidden, source + confetti)

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
