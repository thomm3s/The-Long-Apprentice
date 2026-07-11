extends Node

## Autoload singleton tracking skill-by-practice counters (hidden for now,
## no levels/perks yet — just counts and a threshold print so the loop is
## visible before the design work in Brief section 4 locks down decay/
## diminishing-returns rules).

signal practiced(skill_name: String, new_count: int)

const MILESTONE_INTERVAL: int = 10

var _counts: Dictionary = {}

func practice(skill_name: String, amount: int = 1) -> void:
	var new_count: int = get_count(skill_name) + amount
	_counts[skill_name] = new_count
	practiced.emit(skill_name, new_count)
	if new_count % MILESTONE_INTERVAL == 0:
		print("Skill milestone: ", skill_name, " practiced ", new_count, " times")

func get_count(skill_name: String) -> int:
	return _counts.get(skill_name, 0)
