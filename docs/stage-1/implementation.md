# Stage 1 implementation evidence — 2026-10-14

## Authorization and boundaries

The user approved implementation of the Stage1 graybox table, provisional R15 scale 1 / WalkSpeed16 / UseJumpPower=true / JumpPower50 / Gravity196.2, CP2 deck `(24,22,143.6)` with top23 and trigger center `(24,23.25,143.6)` facing +X, and Kenney asset uploads only. This approval supersedes the historical decision blockers in the copied PRD for these specific items; it does **not** approve balancing, runtime acceptance, CP10 redesign, economy, persistence, publishing, visibility or deployment.

Branch `feat/stage-1-welcome-meadow`, base `27d5216`, isolated worktree `/home/dev/.hermes/cache/scratch/stage1-implementation`. Main checkout deletion/untracked documentation was preserved. Documentation here is a copy of main's read-only design snapshot, not a modification of that source.

## Implementation

- Exact 10 playable deck table: Spawn, FirstJump, six stones, Rest, shared Stage2 Destination. A gap2/rise0; B seven gap2.8/rise12/7; C seam0/rise0. SpawnLocation is noncolliding so it does not raise the playable surface.
- CP1 center `(0,11.25,-6)` +Z; CP2 center `(24,23.25,143.6)` +X; root offset +3.5Y. Existing server sequential/alive/identity/zone checks and reward behavior retained. No additional Stage1 checkpoint.
- Stage2–10 use the original positions/build recipe, then one rigid horizontal yaw/translation of every generated downstream BasePart (platforms, checkpoints, recovery, rails, landing indicators and decorations). Original Stage2→3 direction maps to +X. No downstream style/route redesign; Stage1/downstream footprints checked for overlap in real Luau adapter.
- Respawn root cause: hardcoded +Z replaced with checkpoint LookVector. Regression exercises +X, -X and -Z at actual CP2 height.
- Server applies provisional movement/gravity and scales, reapplies scale after appearance load, and attempts explicit R15 model replacement for an R6 character using `Players:CreateHumanoidModelFromDescriptionAsync`. There is no fictional StarterPlayer rig property. Replacement/API failure still means the R15 runtime gate is NOT guaranteed; inspect actual rig in Studio before balancing.
- Supported StarterPlayer speed/jump properties are included in Rojo project. Roblox API schema checked on 2026-10-14; successful Rojo build validates packaging, not engine movement.
- Top HUD shows active checkpoint; passive wrapped tutorial adapts keyboard/touch and reports CP2 activation. All panels passive; control overlap in actual portrait/landscape/small viewport remains a runtime gate.
- Server decorator loads at most two owned tree Model packages asynchronously. Unparented staging, pcall, script removal/class allowlist, instance/part budgets, anchor/no collide/no touch/no query, bounded scale, primitive fallback. No MeshId=model ID, third-party loading switch, or remote asset dependence for playable geometry.

## Kenney upload results — honest importer boundary

Archive CRC/path/link checks passed; local archive License.txt confirms CC0. Three self-contained GLB v2 files were extracted and checked (header/length/chunks/embedded buffers/bufferViews/material counts/accessor bounds): `flower_yellowA`, `tree_default`, `rock_smallA`. All three real Model creation calls returned valid operations, which were polled to `done=true` with **error `Failed to parse the uploaded file`**. HTTP200 upload acceptance was not treated as successful import.

A real Kenney archive FBX tree fallback was uploaded and polled successfully:

- Model asset ID: `118266415097960`
- Operation: `operations/2a4bce82-405e-4d7d-b493-541c2d7869fe`
- `done=true`, response Model, moderation `Approved`, state `Active`.
- Creator user `11795606123` / `sodikinnaa`, verified through introspection `authorizedUserId`, public user lookup, and returned asset creator details.
- Sanitized requests/results/provenance/license/hashes: `assets/kenney/manifest.json`, `assets/kenney/LICENSE.txt`.

Only the completed FBX tree asset is integrated. Flower/rock retain primitive visuals because GLB importer processing failed. No claim that GLB import succeeded, nor that the actual Model was loaded/rendered in Roblox. No publish or visibility changes.

## Real verification and remaining gates

`python3 -m unittest discover -s tests -v`: 28 tests passed; shipped Luau runs through adapters for geometry/count/gaps/surface heights/rebuild, checkpoint state/rotated respawn, movement/R15 replacement path, HUD input feedback, and decorator sanitization/fallback. Four legacy Python economy tests remain emulators and are not runtime evidence. All 17 shipped Luau files compiled with real `luau-compile`. Rojo build succeeded at:

`/home/dev/.hermes/cache/scratch/stage1-implementation/build/Stage1_Welcome_Meadow.rbxl`

Logs are ignored build artifacts under `build/verification/`. Map is generated at server startup, not baked Workspace. CI/README publish workflow unchanged.

Studio gates pending: actual R15 replacement lifecycle/appearance/scale, HipHeight/collider, camera after CP1/CP2 respawn, manual reset/death race, true touched checkpoint/recovery behavior, walk-without-jump and autojump on first gap, PC/touch comfort on all links, multiplayer collision independence, asset load/pivot/colors/camera clearance, portrait/landscape HUD/control safe areas, and mobile performance. Headless Luau is not Roblox physics/rendering. No commit/push before parent review.
