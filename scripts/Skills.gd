extends Node

## Autoload singleton tracking skill-by-practice counters (hidden for now,
## no perks wired up yet — just counts and milestone prints). Perk thresholds
## follow the diminishing-returns design locked in Brief section 4
## (2026-07-11): thresholds widen geometrically (~2.1x each step) instead of
## a flat interval, so grinding a single verb yields perks further and
## further apart over time.

signal practiced(skill_name: String, new_count: int)

## Example thresholds from the design note; beyond this the sequence
## continues by multiplying the last value by THRESHOLD_GROWTH and rounding.
const BASE_THRESHOLDS: Array[int] = [10, 25, 55, 115, 235]
const THRESHOLD_GROWTH: float = 2.1

var _counts: Dictionary = {}

func practice(skill_name: String, amount: int = 1) -> void:
	var old_count: int = get_count(skill_name)
	var new_count: int = old_count + amount
	_counts[skill_name] = new_count
	practiced.emit(skill_name, new_count)

	var old_crossed: int = _thresholds_crossed(old_count)
	var new_crossed: int = _thresholds_crossed(new_count)
	for i in range(old_crossed, new_crossed):
		print("Skill milestone: ", skill_name, " reached threshold ", _threshold_for_index(i), " (practiced ", new_count, " times)")

func get_count(skill_name: String) -> int:
	return _counts.get(skill_name, 0)

## Next practice-count threshold this skill hasn't reached yet.
## Used by perk-unlock checks and the HUD's "N / next threshold" display.
func get_next_threshold(skill_name: String) -> int:
	var idx: int = _thresholds_crossed(get_count(skill_name))
	return _threshold_for_index(idx)

## How many thresholds a given count has reached or passed.
func _thresholds_crossed(count: int) -> int:
	var idx: int = 0
	while _threshold_for_index(idx) <= count:
		idx += 1
	return idx

## The idx-th threshold (0-based) in the widening sequence.
func _threshold_for_index(idx: int) -> int:
	if idx < BASE_THRESHOLDS.size():
		return BASE_THRESHOLDS[idx]
	var t: float = BASE_THRESHOLDS[BASE_THRESHOLDS.size() - 1]
	for i in range(BASE_THRESHOLDS.size(), idx + 1):
		t = round(t * THRESHOLD_GROWTH)
	return int(t)
