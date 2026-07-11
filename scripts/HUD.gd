extends CanvasLayer

@onready var wood_label: Label = $WoodLabel

func _ready() -> void:
	Inventory.changed.connect(_on_inventory_changed)
	_refresh("wood")

func _on_inventory_changed(item_name: String, _new_count: int) -> void:
	if item_name == "wood":
		_refresh(item_name)

func _refresh(item_name: String) -> void:
	wood_label.text = "Wood: %d" % Inventory.get_count(item_name)
