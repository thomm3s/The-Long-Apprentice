extends StaticBody3D

## Placeholder bed: interacting sleeps through to morning, restoring all
## stamina and part of hunger — the survival loop's safety net. Belongs to
## the "sleepable" group so the player's interact raycast can find it
## generically, mirroring Tree.gd's "choppable" pattern.

signal slept

const HUNGER_RESTORE: float = 50.0

func sleep_in() -> void:
	TimeOfDay.skip_to_morning()
	Stats.add("hunger", HUNGER_RESTORE)
	Stats.add("stamina", Stats.MAX_VALUE)
	slept.emit()
