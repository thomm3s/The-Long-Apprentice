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

Prototype scaffolding exists and loads cleanly: `project.godot`, `scenes/player/Player.tscn`, `scenes/world/Main.tscn`, `scripts/Player.gd` (basic `CharacterBody3D` movement, verified via headless import + instantiate on Godot 4.7 — no errors). Project upgraded from 4.3 to 4.7 on 2026-07-10 (config/features auto-bumped by the engine on import).

Git is initialized with a GitHub remote (`origin` -> thomm3s/The-Long-Apprentice). Each session commits locally after validating its change; nothing auto-pushes. No feature work has started yet.

## Task Queue (priority order — top first)

- [ ] "Chop a cube tree" interaction: add `scenes/props/Tree.tscn` (placeholder cube `StaticBody3D` + `MeshInstance3D` + `CollisionShape3D`), an interact script (raycast or `Area3D` from player), remove tree + increment a wood count on interact
- [ ] Basic inventory (numbers only): a simple autoload/singleton tracking item counts (starting with wood), no UI polish needed yet
- [ ] Minimal UI: a `Label` (CanvasLayer) showing wood count, updates when inventory changes
- [ ] Place a block from inventory: pick a build point (raycast to ground), spawn a placeholder cube, decrement wood
- [ ] Skill-by-practice counter for "chopping": hidden counter on the player/skills singleton, increments per chop, simple print/log when it crosses a threshold (perk hookup can come later)
- [ ] Placeholder logo / title screen scene
- [ ] Design note (not code): lock down skill-decay and diminishing-returns rules for the practice system — add findings to the Brief doc, section 4
- [ ] Name check: Steam/itch.io search + basic trademark search for "The Long Apprentice" (research task, write findings into Brief doc)

Currently working through **Phase 0** of the Brief's roadmap (section 10). When this queue runs low (see "How this file is used" step 2), pull the next unstarted **Phase** from `The Long Apprentice - Brief.md` section 10 and break it into queue items here. Phases so far: 0 gray-box prototype, 1 skill-by-practice foundation, 2 survival/atmosphere, 3 combat, 4 magic, 5 crafting/building depth, 6 hand-built biome, 7 procgen, 8 story/NPCs, 9 polish/UX, 10 multiplayer, 11 platform/release prep, 12 post-launch.

## Completed

- [x] 2026-07-10 — Verified Godot 4.3 runs headless in sandbox; `project.godot`, `Player.tscn`, `Main.tscn` import and instantiate without errors.
- [x] 2026-07-10 — Initialized git repo, set up PROGRESS.md and hourly automation.

## Session Log

*(newest first — each hourly run appends one entry)*

- **2026-07-10 (setup)** — Created this file, initialized git, set up hourly scheduled task. No feature work yet — next session should start on "Chop a cube tree."

## Notes for future sessions

- Engine: Godot 4.7 stable, GDScript. Thijs runs the Windows editor locally; sandbox sessions validate against the matching Linux 4.7 build.
- Follow the folder structure and conventions in `The Long Apprentice - Brief.md` (scenes/player, scenes/world, scenes/props, scripts, assets, addons).
- Reusable-component rule from the Brief: never place raw meshes directly — build a scene once (e.g. `Tree.tscn`), instance it everywhere.
- Input actions aren't fully defined yet in the Input Map beyond what `Player.gd` assumes (`move_forward/back/left/right`, `jump`) — check `project.godot` `[input]` section before assuming an action exists; add missing ones there.
- Keep each session scoped — one small vertical slice, tested, committed. Resist the urge to start multiple queue items in one run.
- If genuinely blocked (missing decision, unclear design), don't guess silently — leave a clear note in the Session Log describing the blocker so the next session (or Thijs) can resolve it.
