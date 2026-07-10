extends Node

## Autoload singleton tracking item counts by name (numbers only, no UI/items yet).

signal changed(item_name: String, new_count: int)

var _counts: Dictionary = {}

func add(item_name: String, amount: int = 1) -> void:
	_counts[item_name] = get_count(item_name) + amount
	changed.emit(item_name, _counts[item_name])

func get_count(item_name: String) -> int:
	return _counts.get(item_name, 0)
