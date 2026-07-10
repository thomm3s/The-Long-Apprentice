# Progress & Task Log — The Long Apprentice

*Working memory for automated hourly sessions. Read this first, update it last.*

## How this file is used

Every hourly session:
1. Read this whole file.
2. If the **Task Queue** has fewer than ~3 items left (including empty), top it up first: open `The Long Apprentice - Brief.md` section 10 (Build Order/Milestones), find the next unstarted **Phase**, and break it into 5-10 concrete, small (~20-minute) action items appended to the Task Queue below. This decomposition step itself counts as a valid session if it eats the time budget — it's fine to spend a whole run just planning, then stop without touching code.
3. Pick the top unchecked item in **Task Queue** and work on it for ~20 minutes (one focused increment — don't try to finish the whole milestone in one go).
4. Validate changes (see Validation below).
5. Commit to git with a clear message.
6. Update this file: check off / move completed items, add a **Session Log** entry, add any new sub-tasks discovered.
7. Stop.

If a queue item is too big to finish in 20 minutes, split it into a smaller sub-task, do the sub-task, and leave the rest in the queue. When a Phase from the Brief is fully decomposed and completed, mark it done in the Brief's section 10 (or note it here) and move to the next Phase.

## Validation (do this before committing)

The sandbox itself is ephemeral (fresh Linux VM every run, nothing pre-installed), but the project folder persists — so a Linux Godot binary is cached at `.godot-tools/Godot_v4.7-stable_linux.x86_64` in the project root (gitignored). Each session:
```
GODOT="<project folder>/.godot-tools/Godot_v4.7-stable_linux.x86_64"
if [ ! -x "$GODOT" ]; then
  mkdir -p "<project folder>/.godot-tools"
  curl -L -o /tmp/godot.zip https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip
  unzip -o /tmp/godot.zip -d "<project folder>/.godot-tools"
  chmod +x "$GODOT"
fi
"$GODOT" --headless --import --path "<project folder>"
```
(Thijs runs the Windows build locally at `C:\Users\Thijs\Downloads\Godot_v4.7-stable_win64.exe` — the cached Linux binary matches that version so headless validation reflects what he actually sees in the editor. If Thijs upgrades his local Godot version, update this cached binary and the version numbers here to match.)
Then write/reuse a small `SceneTree` script to `ResourceLoader.load()` and `.instantiate()` any scenes touched this session, and check exit code / stderr for errors. Don't commit if the project doesn't import cleanly or a touched scene fails to load.

**Git note:** the repo has a GitHub remote (`origin`) but sessions should only `git add` the specific touched files and `git commit` locally — never `git push` automatically. If `git status` errors out (stale sandbox-mount cache — a known glitch, not a real repo problem), don't try to fix `.git` by deleting/reiniting it (deletes/renames are blocked on this mount and will make it worse). Just skip git for that run, do the file edits anyway, and note in the Session Log that git was unavailable.

## Current Status (as of 2026-07-10)

Prototype scaffolding exists and loads cleanly: `project.godot`, `scenes/player/Player.tscn`, `scenes/world/Main.tscn`, `scripts/Player.gd` (basic `CharacterBody3D` movement + raycast interact), `scenes/props/Tree.tscn`, `scripts/Tree.gd` (chop-able placeholder tree), `scripts/Inventory.gd` (autoload singleton, numbers-only item counts) — all verified via headless import + instantiate on Godot 4.7, no errors. Project upgraded from 4.3 to 4.7 on 2026-07-10 (config/features auto-bumped by the engine on import). Player can walk up to a Tree instance in Main.tscn and press E to chop it (removes tree, calls `Inventory.add("wood", 1)`, printed to console — no UI yet, that's next queue item).

Git is initialized with a GitHub remote (`origin` -> thomm3s/The-Long-Apprentice). Each session commits locally after validating its change; nothing auto-pushes. This session ran directly on Thijs's Windows machine (not an ephemeral sandbox) with git and the real Windows Godot 4.7 editor binary (`C:\Users\Thijs\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe`) both working normally — the earlier sandbox mount-cache/git issues noted below did not reproduce here.

The two stray placeholder files (`scripts/_probe_test.gd`, `_validate.gd`) have been deleted — they were confirmed inert and unreferenced.

## Task Queue (priority order — top first)

- [ ] Minimal UI: a `Label` (CanvasLayer) showing wood count, updates when inventory changes (listen to `Inventory.changed` signal)
- [ ] Place a block from inventory: pick a build point (raycast to ground), spawn a placeholder cube, decrement wood
- [ ] Skill-by-practice counter for "chopping": hidden counter on the player/skills singleton, increments per chop, simple print/log when it crosses a threshold (perk hookup can come later)
- [ ] Placeholder logo / title screen scene
- [ ] Design note (not code): lock down skill-decay and diminishing-returns rules for the practice system — add findings to the Brief doc, section 4
- [ ] Name check: Steam/itch.io search + basic trademark search for "The Long Apprentice" (research task, write findings into Brief doc)

Currently working through **Phase 0** of the Brief's roadmap (section 10). When this queue runs low (see "How this file is used" step 2), pull the next unstarted **Phase** from `The Long Apprentice - Brief.md` section 10 and break it into queue items here. Phases so far: 0 gray-box prototype, 1 skill-by-practice foundation, 2 survival/atmosphere, 3 combat, 4 magic, 5 crafting/building depth, 6 hand-built biome, 7 procgen, 8 story/NPCs, 9 polish/UX, 10 multiplayer, 11 platform/release prep, 12 post-launch.

## Completed

- [x] 2026-07-10 — Verified Godot 4.3 runs headless in sandbox; `project.godot`, `Player.tscn`, `Main.tscn` import and instantiate without errors.
- [x] 2026-07-10 — Initialized git repo, set up PROGRESS.md and hourly automation.
- [x] 2026-07-10 — "Chop a cube tree" interaction: `scenes/props/Tree.tscn` + `scripts/Tree.gd` (StaticBody3D, group `choppable`, `chop()` emits `chopped` then `queue_free()`s), raycast-based interact in `scripts/Player.gd` (`_unhandled_input` on `interact` action → camera raycast, `INTERACT_RANGE = 3.0` → calls `chop()`). Two Tree instances placed in `scenes/world/Main.tscn` in front of player spawn for manual testing.
- [x] 2026-07-10 — Basic inventory (numbers only): `scripts/Inventory.gd` autoload singleton (registered in `project.godot` `[autoload]`), `Dictionary` of item name → count, `add(item_name, amount)` / `get_count(item_name)`, emits `changed(item_name, new_count)` signal for the future UI to hook into. `Player.gd`'s chop handler now calls `Inventory.add("wood", 1)` instead of tracking a local `wood_count` var.

## Session Log

*(newest first — each hourly run appends one entry)*

- **2026-07-10 (inventory)** — Implemented "Basic inventory (numbers only)" (top queue item). Files touched: `scripts/Inventory.gd` (new — autoload singleton, `add()`/`get_count()`, `changed` signal), `project.godot` (edited — added `[autoload]` section registering `Inventory`), `scripts/Player.gd` (edited — chop handler now calls `Inventory.add("wood", 1)` / `Inventory.get_count("wood")` instead of a local `wood_count` var). Also deleted the two stray placeholder files noted as safe to remove (`scripts/_probe_test.gd`, `_validate.gd` + their `.uid` files) since this run had normal filesystem access. Found the previous session's uncommitted "chop tree" work already committed as `2c9ae96 first claude change` at the start of this run (git and the real Windows Godot editor both work fine in this environment — the sandbox mount-cache/git issues from the prior session's notes didn't reproduce here). Validation: headless `--import` clean (no SCRIPT ERROR output), plus a throwaway `SceneTree` probe script (deleted after use) loaded/instantiated `Tree.tscn`, `Main.tscn`, `Player.tscn` and exercised the `Inventory` autoload end-to-end (`add`/`get_count` round-tripped correctly) — printed `ALL_OK`. Committed this session's changes. Next session should pick up "Minimal UI: wood count label".
- **2026-07-10 (chop tree)** — Implemented "Chop a cube tree" (top queue item). Files touched: `scripts/Tree.gd` (new), `scenes/props/Tree.tscn` (new), `scripts/Player.gd` (edited — added `_try_interact()` raycast + `wood_count`), `scenes/world/Main.tscn` (edited — added 2 Tree instances). Validation passed: headless `--import` clean, and a throwaway `SceneTree` script (`ResourceLoader.load` + `.instantiate()` on Tree.tscn/Main.tscn/Player.tscn) reported `ALL_OK` for all three. **Blocker hit and worked around:** the sandbox's bash mount of the project folder served stale/truncated cached content for files that already existed before this session (`Player.gd`, `Main.tscn`) even well after edits via the file-editing tool and after long waits — reads consistently returned an identical mid-line truncation, while brand-new files synced immediately. Worked around by writing the final content for those two files directly via bash heredoc (content matches what's shown above / in the files now) — bash self-consistent read-after-write worked fine, only the cross-tool sync was stale. Two harmless stray files were created while diagnosing this and could not be deleted (`rm` is blocked on this mount, same as the known `.git` issue): `scripts/_probe_test.gd` and `_validate.gd` (project root) — both overwritten with inert comment-only placeholders so they don't affect Godot's script parsing. **These two files are safe to delete manually** next time someone has normal filesystem access; they aren't referenced anywhere. **Git unavailable this run** — `git status` still fails with "unknown error occurred while reading the configuration files" and `.git/config` is unreadable via `cat` despite `ls`/`stat` showing it exists (same known stale-mount-cache issue noted in the Validation section, not a real repo problem). Did not touch `.git`. Nothing committed — next session with a working git should commit: `scripts/Tree.gd`, `scenes/props/Tree.tscn`, `scripts/Player.gd`, `scenes/world/Main.tscn`, `PROGRESS.md`, and ideally delete the two stray placeholder files. Next session should pick up "Basic inventory (numbers only)" — a good time to migrate `wood_count` off Player and into the new autoload.
- **2026-07-10 (setup)** — Created this file, initialized git, set up hourly scheduled task. No feature work yet — next session should start on "Chop a cube tree."

## Notes for future sessions

- Engine: Godot 4.7 stable, GDScript. Thijs runs the Windows editor locally; sandbox sessions validate against the matching Linux 4.7 build.
- Follow the folder structure and conventions in `The Long Apprentice - Brief.md` (scenes/player, scenes/world, scenes/props, scripts, assets, addons).
- Reusable-component rule from the Brief: never place raw meshes directly — build a scene once (e.g. `Tree.tscn`), instance it everywhere.
- Input actions aren't fully defined yet in the Input Map beyond what `Player.gd` assumes (`move_forward/back/left/right`, `jump`) — check `project.godot` `[input]` section before assuming an action exists; add missing ones there.
- Keep each session scoped — one small vertical slice, tested, committed. Resist the urge to start multiple queue items in one run.
- If genuinely blocked (missing decision, unclear design), don't guess silently — leave a clear note in the Session Log describing the blocker so the next session (or Thijs) can resolve it.
