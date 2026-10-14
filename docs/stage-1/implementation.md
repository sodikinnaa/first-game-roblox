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

## Narrow asset visibility follow-up (verification only)

Based on `eb9f42b` / reported published version 4. These local changes are **not published**; no upload, publication, visibility change, commit, push, or dotenv access occurred. Existing main-checkout documents/user edits were not touched.

### Confirmed offline defects and minimal repair

- `MapBuilderService` generates `Shrub_1_-1` and `Shrub_1_1` at centers `(-9,12,2)` and `(9,12,2)`; the deck top is Y11. Names in the loader match. Fallback naming is not the defect.
- `PivotTo(...Y11...)` places the imported **pivot**, not the geometry bottom. Offset-pivot regression failed with “tree sunk under surface”; the fix queries the bounding box after upright placement/scaling and translates its center to `(side*9, 11 + extent.Y/2, 2)`. This proves bottom alignment for adapter fixtures, not the actual imported model's pivot or visibility.
- `ScaleTo` takes absolute canonical scale. A model initially at scale2 failed requested height4 with the old ratio; now uses `GetScale() * height/currentBoundsHeight`, retaining the original clamp `[0.01,20]` (extreme inputs may remain clamped).
- Parent attachment now requires Decorations to remain a descendant of Workspace after the yielding load; missing Decorations is guarded. Staging is destroyed when the old map/decorations was removed. Primitive fallback is removed only after validation, placement, and live attachment succeed.
- Fixed stage-only status codes are persisted on Decorations: `KenneyTree_-1Status` / `KenneyTree_1Status`: `Loading`, `Loaded`, `LoadFailed`, `ValidationFailed`, `PlacementFailed`. Successful `KenneyTree_<side>` folders have `AssetId` and `Status=Loaded`; failure leaves shrub and marks `FallbackActive=true`. Server warnings carry only stage/side/fixed code, never raw exception text, request bodies or credentials. `LoadFailed` does not distinguish permission/network/moderation failures: native Roblox logs must supply that evidence.
- Existing executable stripping, allowlist, 80-instance/24-part budgets, anchored/noncolliding/nontouch/nonquery flags and two asynchronous loads remain. No new model IDs or later-stage changes.

### Public GET evidence and remaining ownership uncertainty

Actual unauthenticated responses are saved in [asset-public-metadata.json](asset-public-metadata.json), checked 2026-10-14:

- `GET https://economy.roblox.com/v2/assets/118266415097960/details` → HTTP200, asset type10 (Model), creator User `11795606123` / `sodikinnaa`, name `Stage1 Kenney FBX Tree`. Public metadata confirms asset identity/creator but contains **no Approved/Active fields**.
- `GET https://games.roblox.com/v1/games?universeIds=10770632072` → HTTP200 but restricted placeholder (`id=0`, creator0/UNKNOWN, `isContentRestricted=true`). This endpoint **cannot establish the universe creator** in this response. No privacy setting was changed to bypass this.
- `GET https://apis.roblox.com/universes/v1/places/71239438116581/universe` → HTTP200 universe `10770632072`; public economy details for that place → HTTP200 creator User `11795606123`. This is corroborating place-owner evidence, not direct universe-owner proof from games API.
- `GET https://apis.roblox.com/assets/v1/assets/118266415097960` → HTTP403 without authentication. `assets/kenney/manifest.json` records `Approved`/`Active` from the earlier completed Open Cloud upload operation's response, not current public metadata. No new authenticated metadata lookup was attempted and current moderation/loadability is not proven.
- `AssetService:LoadAssetAsync` requires ownership/appropriate permission in the target experience; matching asset/place creator is encouraging but not native load evidence. Do **not** enable a third-party loading switch as a workaround.

### Executed local checks versus runtime gate

`python3 -m unittest discover -s tests -v`: **34 passed**, including seven decorator tests executing shipped Luau (offset pivot, noncanonical scale, sanitization, fallback, status, budgets/rejection, removed parents). Four legacy economy tests are Python emulators. Adapter is translation-only and cannot reproduce imported meshes, oriented native bounding boxes, rendering, moderation, AssetService or Roblox physics. New regression failures were observed before the respective fixes. All **17** shipped Luau files compiled; Rojo build succeeded; `git diff --check` clean.

Artifact: `build/Stage1_Visibility_Verified.rbxl`, 25,575 bytes, SHA256 `beee81ce80a09187fb73a326c14c85526e7a60289641ef980f814e21d68ec348`. This packages code, not baked decor or a playtest.

Host probe: Linux; no RobloxStudio, RobloxPlayer, Wine or Sober command found. Roblox Studio/native AssetService renderer was **not executed**. There are no fabricated headless screenshots. Actual model colors, pivot, meshes, visibility, camera clearance and runtime load remain unknown.

### User runtime diagnosis (Studio/server F9)

1. Test the local artifact in an owned Studio experience; a local build does not modify version4. Existing release will not have the new attributes unless a later separately authorized publication happens.
2. In Studio Play, inspect `Workspace.SkyIslandsMap.Decorations`. Expect `KenneyTree_-1` and `KenneyTree_1`, each containing the imported Model/parts; expected bounds bottom Y11, height approximately4, centers X−9/+9 Z2. Shrubs should disappear only for successfully attached trees.
3. Watch `KenneyTree_-1Status` and `KenneyTree_1Status` on Decorations. `Loading` means request pending; `Loaded` means sanitized model attached, **not guaranteed visible pixels**. Failure status should leave the corresponding shrub. Do not confuse Stage2+ shrubs with Stage1 fallbacks.
4. Open **F9 → Server** log (owner/developer access), or Studio **Output**. Search `[DecorAssetService]` and native asset ID `118266415097960` errors. Record fixed status, any Roblox-native permission/moderation message, place/universe and tested build/version; redact credentials if sharing logs. `ValidationFailed` indicates rejected structure/budget; `PlacementFailed` indicates sizing/pivot/attachment operation failed. Avoid third-party loading changes.
5. If Loaded but invisible, inspect actual child MeshParts/Transparency/materials/mesh delivery and GetBoundingBox in Studio; compare with deck top and camera location. This cannot be settled by offline tests alone.

## Real verification and remaining gates

`python3 -m unittest discover -s tests -v`: 28 tests passed; shipped Luau runs through adapters for geometry/count/gaps/surface heights/rebuild, checkpoint state/rotated respawn, movement/R15 replacement path, HUD input feedback, and decorator sanitization/fallback. Four legacy Python economy tests remain emulators and are not runtime evidence. All 17 shipped Luau files compiled with real `luau-compile`. Rojo build succeeded at:

`/home/dev/.hermes/cache/scratch/stage1-implementation/build/Stage1_Welcome_Meadow.rbxl`

Logs are ignored build artifacts under `build/verification/`. Map is generated at server startup, not baked Workspace. CI/README publish workflow unchanged.

Studio gates pending: actual R15 replacement lifecycle/appearance/scale, HipHeight/collider, camera after CP1/CP2 respawn, manual reset/death race, true touched checkpoint/recovery behavior, walk-without-jump and autojump on first gap, PC/touch comfort on all links, multiplayer collision independence, asset load/pivot/colors/camera clearance, portrait/landscape HUD/control safe areas, and mobile performance. Headless Luau is not Roblox physics/rendering. No commit/push before parent review.
