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

1. Gray-box prototype: move, chop a cube tree, pick up wood, place one building piece
2. Add skill-by-practice system on 2-3 verbs (chopping, combat swing, running)
3. Basic survival stats (hunger/stamina) + day/night cycle
4. First combat pass + one enemy type
5. First magic verb (e.g. fire spell), tied into the same practice system as physical skills
6. One small hand-built biome (replacing gray-box test level)
7. Procedural generation — only after the hand-built version proves the loop is fun
8. Story/quest layer — last, once world + systems exist to hang it on

**Time estimate for the scrappy first playable (solo, AI-assisted, no art):** ~15-25 focused hours
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