extends DirectionalLight3D

## Sun for the day/night cycle: rotates and dims off the TimeOfDay autoload.
## Attached to Main.tscn's DirectionalLight3D — no state of its own, so any
## scene with a sun can reuse it by attaching this script.

const MAX_ENERGY: float = 1.0

func _process(_delta: float) -> void:
	_apply_time(TimeOfDay.normalized_time)

func _apply_time(t: float) -> void:
	# Sunrise at the horizon (t = 0.25), straight overhead at noon (t = 0.5).
	rotation_degrees.x = -(t - TimeOfDay.MORNING) * 360.0
	light_energy = MAX_ENERGY * clampf(TimeOfDay.sun_elevation(), 0.0, 1.0)
