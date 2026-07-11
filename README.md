# The Long Apprentice

An open-world survival crafting game with a magic/fantasy theme, built in Godot 4.

## Requirements

- [Godot 4.7](https://godotengine.org/download) (Forward Plus renderer)

## Run the game

1. Clone this repo and open the project folder in Godot.
2. When prompted, choose **Import** and select `project.godot`.
3. Press **F5** (or click the **Play** button in the top-right).
4. On the title screen, click **Start** to enter the world.

The main scene is `scenes/world/Main.tscn` — a small 3D first-person test level with trees, a bed, a red-box enemy, and placeholder building blocks.

## Controls

| Action | Key |
|--------|-----|
| Look around | Mouse |
| Move | W A S D |
| Sprint | Shift |
| Jump | Space |
| Interact (chop tree, sleep in bed) | E |
| Melee attack | Left mouse button |
| Place building block | Right mouse button |
| Cast fire bolt | R |
| Release mouse cursor | Escape |

Click inside the game window to recapture the mouse after pressing Escape.

## Fire bolts

Press **R** to cast a fire bolt in the direction you are looking.

- **Mana cost:** 25 per cast (watch the mana bar on the HUD).
- **Mana regen:** refills passively — full from empty in about 20 seconds.
- **Cooldown:** starts at 2 seconds between casts; gets shorter as you practice fire magic (down toward ~0.4s).
- **Damage:** 20 per hit on anything in the `damageable` group (try it on the red enemy).
- **Practice:** each successful cast trains **Fire Magic**; progress shows on the HUD and milestone toasts appear at thresholds.

If nothing happens when you press R, you probably don't have enough mana yet or you're still on cooldown — wait a moment and try again.

## Run a specific scene

To test a scene without changing project settings:

1. Open the scene in the editor (e.g. `scenes/world/Main.tscn`).
2. Press **F6** to run the current scene only.

## Project docs

See [The Long Apprentice - Brief.md](The%20Long%20Apprentice%20-%20Brief.md) for the full design brief and [PROGRESS.md](PROGRESS.md) for current development status.
