# The Long Apprentice — Project Brief

*Living reference doc. Paste this into a new chat to restore context.*

## 1. Concept

An indie, small-team (2-3 people), open-world survival crafting game with a magic/fantasy theme.

**Inspirations:**
- **Valheim** — gather/craft/build loop, exploration, atmospheric mood built more through fog/lighting/color grading than raw polygon detail
- **Windrose** — streamlined, low-friction survival systems (e.g. shared base storage, fast travel, forgiving mechanics) that cut the "faff" out of the genre
- **Mark of the Fool** (book) — tone/progression inspiration only, *not* to be directly referenced due to IP concerns. The borrowed idea is the archetype underneath it: starting as a nobody and earning mastery purely through repetition — not the book's specific terms, characters, or branding.

**Core pillars:**
- Open world, survival + crafting + building
- Magic system woven into the same progression system as physical skills
- **Skills improve by doing them, not by spending abstract XP/levels** (Skyrim-like, not WoW-like)
- Story/world tone: a bit dark-fantasy, atmospheric, character starts from nothing

## 2. Name

**The Long Apprentice**
- Signals the core mechanic: endless mastery through practice, never truly "finished" learning
- Personal resonance for the dev (tall — "Long" double meaning)
- Distinct from Mark of the Fool — no shared terms, titles, or characters
- **TODO before getting attached:** check Steam, itch.io, and do a basic trademark search

## 3. Core Gameplay Loop

```
explore → gather resource → craft/build → get stronger (via practice) → explore further
```

Everything else (story, procedural generation, magic depth, multiplayer) is content layered on top of this loop. The loop needs to feel good with placeholder cubes before anything else is worth building.

## 4. Skill-by-Practice System (key differentiator — design this early, as a real system)

- Each **verb** (chopping, mining, casting a spell, blocking, sneaking, running) has its own hidden counter that increases with use.
- Counters unlock perks/efficiency at thresholds — not a global XP/level bar shared across everything.
- Magic skills use the *same underlying system* as physical skills — casting a fire spell repeatedly should feel mechanically parallel to swinging an axe repeatedly.
- **Open design questions to lock down before scaling this up:**
  - Does a skill decay if unused?
  - Are there diminishing returns to prevent grinding one action forever?
  - How do perks/thresholds get communicated to the player (visible bar vs. felt-only improvement)?

## 5. Tech Stack

- **Engine: Godot 4.x** — chosen because it's free/open-source, has solid 3D, and GDScript is quick to pick up for someone coming from Go/web (feels Python-like). C# is available too if preferred.
- Go itself isn't practical for the 3D client, but could power a future multiplayer backend/server.
- **Cross-platform:** Godot exports to Windows/Linux/Mac from the same project — develop on Mac, export Windows builds without needing a Windows machine.
  - Can't easily *test* Windows builds on Mac — use a VM (Parallels/UTM) or a second PC/friend to sanity-check.
  - Unsigned Windows `.exe` triggers SmartScreen warnings — fine for early builds, sort out code signing closer to real launch.
  - Native code (GDExtension in C++/Rust) is harder to cross-compile — avoid until actually needed.

## 6. Project Setup Reference

**Folder structure:**
```
/scenes
  /player
  /world
  /props
/scripts
/assets
  /models
  /textures
/addons
```

**Project Settings to configure early:**
- Rendering → Renderer: Forward+ (default fine; Mobile only if perf becomes an issue)
- Input Map: define actions early — `move_forward`, `move_back`, `move_left`, `move_right`, `jump`, `interact`, `attack` — bind via Input Map, not hardcoded keys in scripts
- Display → Window → Size: e.g. 1280x720 for testing
- Application → Run → Main Scene: set to your `Main.tscn`

**First scenes:**
- `player/Player.tscn` — `CharacterBody3D` + `CollisionShape3D` + `MeshInstance3D` (capsule placeholder) + `Player.gd`
- `world/Main.tscn` — `Node3D` root + `WorldEnvironment` (for later fog/lighting) + ground `StaticBody3D` plane + Player instanced in

**Starter movement script (`Player.gd`):**
```gdscript
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
```

## 7. Reusable Components (the "swap 1000 trees" problem)

- Never place raw meshes directly — always build a scene (`Tree.tscn`) once, then **instance** it everywhere.
- Swapping the mesh inside the source scene updates every placed instance automatically.
- For variety: make a small pool of scenes (`Tree_Pine.tscn`, `Tree_Oak.tscn`, etc.) and randomize placement.
- For very large counts (1000s+): use `MultiMeshInstance3D` for rendering efficiency, still editable from one source mesh.
- Conclusion: safe to build with placeholder assets now — swapping later is cheap.

## 8. Asset Sources (free/cheap, good for prototyping)

- **Kenney.nl** — CC0 low-poly asset packs (nature, buildings, characters, UI); ideal for scrappy first playable
- **Quaternius** — free low-poly 3D packs, good stylized nature/survival assets
- **Poly Haven** — free HDRIs/textures/some models, CC0
- **Godot Asset Library** (in-editor) — plugins + some 3D assets
- **itch.io** — indie-made low-poly nature/survival packs, $5-20, search "stylized nature pack" / "low poly survival kit" for genre-matched assets
- **Sketchfab** — large model library, filter by downloadable + CC license, quality varies

**Suggested progression:** Kenney first (free, zero friction) → once the loop is fun, invest in a cohesive itch.io pack for a more unified look.

## 9. Low Poly / Art Direction Note

"Low poly" = models built from few polygons — faceted, simplified look, fast to make, runs well on modest hardware. Valheim itself isn't strictly low poly — it's *stylized*, leaning on fog/lighting/color grading for mood more than geometric detail. Practical implication: start with genuinely low-poly placeholders, and get a surprising amount of "Valheim-ish" atmosphere just from Godot's `WorldEnvironment` (fog, lighting, color grading) before touching a modeling tool.

## 10. Build Order / Milestones

*This is the long-term roadmap, organized into phases. Each phase is a "long-term goal" — too big to act on directly. When the active Task Queue (in `PROGRESS.md`) runs low or empties, pull the next unstarted phase from here, break it down into small (~20-minute) concrete action items, and add those to the Task Queue. Phases are ordered by dependency, not necessarily by how "fun" or important they are — earlier phases unblock later ones.*

**Phase 0 — Gray-box prototype** *(current focus, tracked in PROGRESS.md)*
- Move, chop a cube tree, pick up wood, place one building piece

**Phase 1 — Skill-by-practice foundation**
- Skill-by-practice system on 2-3 verbs (chopping, combat swing, running)
- Perk/threshold unlocks for at least one verb, communicated to the player somehow (bar, message, or felt-only — pick one and test it)
- Lock down skill-decay and diminishing-returns rules (design decision, see section 4)

**Phase 2 — Survival & atmosphere basics**
- Hunger/stamina stats with simple UI
- Day/night cycle
- `WorldEnvironment` pass: fog, lighting, color grading for a first taste of mood
- Sleep/bed interaction (skip to morning, safety net for hunger/stamina)

**Phase 3 — Combat & first enemy**
- Basic combat pass (attack, hit detection, damage, death)
- One enemy type with simple AI (chase/attack)
- Player death/respawn flow

**Phase 4 — Magic system**
- First magic verb (e.g. fire spell) tied into the same practice system as physical skills
- Resource cost for casting (mana, stamina, or cooldown — pick one)
- Second magic verb once the first proves the pattern works

**Phase 5 — Crafting & building depth**
- Basic inventory UI (icons, not just numbers)
- Simple crafting recipes (combine resources -> item, via a menu)
- Building snapping/grid + at least 2-3 building piece types (wall, floor, roof)
- A basic workbench/station gating higher-tier recipes

**Phase 6 — Hand-built biome**
- One small hand-built biome (replacing the gray-box test level), populated with resources, the one enemy type, and points of interest
- First non-placeholder assets (Kenney/Quaternius) swapped in for trees/rocks/props

**Phase 7 — Procedural generation**
- Only after Phase 6 proves the loop is fun on a hand-built level
- Start with procedural placement of existing hand-built biome assets, not full terrain generation
- Terrain/heightmap generation once placement-only procgen works

**Phase 8 — Story & NPC layer**
- Once world + systems exist to hang it on
- One NPC with dialogue (even placeholder text) tied to a quest hook
- First quest: a simple fetch/craft/deliver loop using existing systems (no new systems required)

**Phase 9 — Polish & UX**
- Settings menu (video, audio, key rebinding)
- Save/load system
- Audio: SFX for core actions (chop, hit, cast), basic ambient/music pass
- Basic accessibility pass (subtitles for any dialogue, colorblind-safe UI check)

**Phase 10 — Multiplayer**
- Only after single-player loop is solid — multiplayer roughly doubles the work of everything it touches
- Shared base storage sync (a Windrose-inspired low-friction pain point)
- Basic client-server movement/combat sync for 2-4 players

**Phase 11 — Platform & release prep**
- Windows/Linux/Mac export configs, sanity-check each build
- Performance pass (profiler check, especially once procgen/MultiMeshInstance3D is in play)
- Steam/itch.io store page draft, code signing for Windows builds
- External playtesting round + triage feedback into new Task Queue items

**Phase 12 — Post-launch**
- Balance pass from real playtest/player data
- First content update scoped from player feedback (new biome, verb, or enemy — whichever the data supports)

**Time estimate for the scrappy first playable (Phase 0, solo, AI-assisted, no art):** ~15-25 focused hours
- Godot setup, player movement, camera: 2-4 hrs
- Chop a cube "tree" → wood item: 2-3 hrs
- Basic inventory (numbers only): 2-4 hrs
- Place a block from inventory: 4-8 hrs
- One skill-practice counter: 2-4 hrs
- Day/night or survival stat (optional for v0): 2-4 hrs
- Add 1-2 days buffer if new to Godot's editor/node system
- Multiplayer roughly doubles everything — prototype single-player first

## 11. Team Shape (2-3 people)

- 1 gameplay/systems programmer (dev, using Go/web background + AI assistance to ramp on Godot)
- 1 generalist artist — modular, stylized-low-poly assets recommended over realism for small-team speed
- Design/writing/story shared, but one clear owner to keep tone consistent

## 12. Next Steps (pick up here in a new chat)

- [ ] "Chop a cube tree" interaction script
- [ ] Placeholder logo / title screen for the prototype
- [ ] Lock down skill-decay and diminishing-returns rules for the practice system
- [ ] Name check: Steam/itch.io search + trademark search for "The Long Apprentice"