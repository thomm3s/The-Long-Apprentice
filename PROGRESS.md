# Progress & Task Log — The Long Apprentice

*Working memory for automated hourly sessions. Read this first, update it last.*

## How this file is used

Every hourly session:
1. Read this whole file.
2. Pick the top unchecked item in **Task Queue**.
3. Work on it for ~20 minutes (one focused increment — don't try to finish the whole milestone).
4. Validate changes (see Validation below).
5. Commit to git with a clear message.
6. Update this file: check off / move completed items, add a **Session Log** entry, add any new sub-tasks discovered.
7. Stop.

If a queue item is too big to finish in 20 minutes, split it into a smaller sub-task, do the sub-task, and leave the rest in the queue.

## Validation (do this before committing)

The sandbox is ephemeral — Godot isn't pre-installed. Each session:
```
curl -L -o godot.zip https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
unzip -o godot.zip && chmod +x Godot_v4.3-stable_linux.x86_64
./Godot_v4.3-stable_linux.x86_64 --headless --import --path "<project folder>"
```
Then write/reuse a small `SceneTree` script to `ResourceLoader.load()` and `.instantiate()` any scenes touched this session, and check exit code / stderr for errors. Don't commit if the project doesn't import cleanly or a touched scene fails to load.

## Current Status (as of 2026-07-10)

Prototype scaffolding exists and loads cleanly: `project.godot`, `scenes/player/Player.tscn`, `scenes/world/Main.tscn`, `scripts/Player.gd` (basic `CharacterBody3D` movement, verified via headless import + instantiate — no errors).

Git was just initialized for this project. No feature work has started yet.

## Task Queue (priority order — top first)

- [ ] "Chop a cube tree" interaction: add `scenes/props/Tree.tscn` (placeholder cube `StaticBody3D` + `MeshInstance3D` + `CollisionShape3D`), an interact script (raycast or `Area3D` from player), remove tree + increment a wood count on interact
- [ ] Basic inventory (numbers only): a simple autoload/singleton tracking item counts (starting with wood), no UI polish needed yet
- [ ] Minimal UI: a `Label` (CanvasLayer) showing wood count, updates when inventory changes
- [ ] Place a block from inventory: pick a build point (raycast to ground), spawn a placeholder cube, decrement wood
- [ ] Skill-by-practice counter for "chopping": hidden counter on the player/skills singleton, increments per chop, simple print/log when it crosses a threshold (perk hookup can come later)
- [ ] Placeholder logo / title screen scene
- [ ] Design note (not code): lock down skill-decay and diminishing-returns rules for the practice system — add findings to the Brief doc, section 4
- [ ] Name check: Steam/itch.io search + basic trademark search for "The Long Apprentice" (research task, write findings into Brief doc)

When this queue empties, pull the next unstarted milestone from **Section 10 (Build Order/Milestones)** in `The Long Apprentice - Brief.md` and break it into queue items here.

## Completed

- [x] 2026-07-10 — Verified Godot 4.3 runs headless in sandbox; `project.godot`, `Player.tscn`, `Main.tscn` import and instantiate without errors.
- [x] 2026-07-10 — Initialized git repo, set up PROGRESS.md and hourly automation.

## Session Log

*(newest first — each hourly run appends one entry)*

- **2026-07-10 (setup)** — Created this file, initialized git, set up hourly scheduled task. No feature work yet — next session should start on "Chop a cube tree."

## Notes for future sessions

- Engine: Godot 4.3 stable, GDScript.
- Follow the folder structure and conventions in `The Long Apprentice - Brief.md` (scenes/player, scenes/world, scenes/props, scripts, assets, addons).
- Reusable-component rule from the Brief: never place raw meshes directly — build a scene once (e.g. `Tree.tscn`), instance it everywhere.
- Input actions aren't fully defined yet in the Input Map beyond what `Player.gd` assumes (`move_forward/back/left/right`, `jump`) — check `project.godot` `[input]` section before assuming an action exists; add missing ones there.
- Keep each session scoped — one small vertical slice, tested, committed. Resist the urge to start multiple queue items in one run.
- If genuinely blocked (missing decision, unclear design), don't guess silently — leave a clear note in the Session Log describing the blocker so the next session (or Thijs) can resolve it.
