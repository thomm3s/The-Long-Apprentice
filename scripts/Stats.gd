extends Node

## Autoload singleton tracking survival stats (0-100 each), mirroring
## Inventory.gd/Skills.gd's shape. Hunger decays continuously over time.
## No UI or gameplay consequence wired up yet (separate queue items) — just
## the ticking stat, per Phase 2's scoping (Brief section 10).

signal changed(stat_name: String, new_value: float)

const MAX_VALUE: float = 100.0
## Placeholder pacing: hunger fully depletes over 10 real-time minutes.
const HUNGER_DECAY_PER_SEC: float = MAX_VALUE / (10.0 * 60.0)

var _values: Dictionary = {"hunger": MAX_VALUE}

func _process(delta: float) -> void:
	_apply_delta("hunger", -HUNGER_DECAY_PER_SEC * delta)

func get_value(stat_name: String) -> float:
	return _values.get(stat_name, MAX_VALUE)

func _apply_delta(stat_name: String, delta: float) -> void:
	var old_value: float = get_value(stat_name)
	var new_value: float = clamp(old_value + delta, 0.0, MAX_VALUE)
	if new_value == old_value:
		return
	_values[stat_name] = new_value
	changed.emit(stat_name, new_value)
