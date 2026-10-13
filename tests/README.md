# Local verification (Linux)

Install pinned CLIs into ignored `build/tools` from the worktree root:

```sh
mkdir -p build/tools
curl -fLsS https://github.com/luau-lang/luau/releases/download/0.742/luau-ubuntu.zip -o build/tools/luau.zip
unzip -q -o build/tools/luau.zip -d build/tools
chmod +x build/tools/luau build/tools/luau-compile
curl -fLsS https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-linux-x86_64.zip -o build/tools/rojo.zip
unzip -q -o build/tools/rojo.zip -d build/tools
chmod +x build/tools/rojo
python -m unittest discover -s tests -v
build/tools/rojo build default.project.json --output build/sky-island-adventure.rbxl
```

Luau tests discover `LUAU_BIN`, then `luau` on PATH, then `build/tools/luau`.
The summit suite executes the shipped Luau using a small Roblox API test double;
map tests do the same for generation/geometry. Client entry/banner checks are
structural checks only. Existing `test_mechanics.py` is a Python simulation,
not proof of Luau behavior. No new reward economy or persistence is added.

A Rojo build packages source; it does not execute it or bake server-generated
islands into the file. Studio Play must still verify generation, real Touched
behavior, respawns, collision groups, multiplayer event isolation, UI/mobile
safe areas, avatar jumps and physics. No publish is performed by these commands.
