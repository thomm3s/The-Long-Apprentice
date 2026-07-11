extends Node

## Autoload tracking the time of day as a normalized 0-1 value (0 = midnight,
## 0.25 = morning/6am, 0.5 = noon, 0.75 = evening/6pm), looping continuously.
## Visual consumers (the sun in Main.tscn) read this each frame; the bed's
## sleep interaction skips it forward via skip_to_morning().

signal time_changed(normalized_time: float)

## Placeholder pacing: one full in-game day per 10 real-time minutes.
const DAY_LENGTH_SEC: float = 600.0
const MORNING: float = 0.25

var normalized_time: float = MORNING

func _process(delta: float) -> void:
	set_time(normalized_time + delta / DAY_LENGTH_SEC)

func set_time(t: float) -> void:
	normalized_time = wrapf(t, 0.0, 1.0)
	time_changed.emit(normalized_time)

func skip_to_morning() -> void:
	set_time(MORNING)

## Sun height factor: 1 at noon, 0 at sunrise/sunset, negative overnight.
func sun_elevation() -> float:
	return sin((normalized_time - MORNING) * TAU)

func is_night() -> bool:
	return sun_elevation() < 0.0
