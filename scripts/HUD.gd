extends CanvasLayer

const TOAST_DURATION: float = 3.0

@onready var wood_label: Label = $WoodLabel
@onready var chopping_label: Label = $ChoppingLabel
@onready var toast_label: Label = $ToastLabel
@onready var toast_timer: Timer = $ToastTimer

func _ready() -> void:
	Inventory.changed.connect(_on_inventory_changed)
	Skills.practiced.connect(_on_skill_practiced)
	Skills.milestone_reached.connect(_on_milestone_reached)
	toast_label.visible = false
	toast_timer.wait_time = TOAST_DURATION
	toast_timer.one_shot = true
	toast_timer.timeout.connect(_on_toast_timeout)
	_refresh("wood")
	_refresh_chopping()

func _on_inventory_changed(item_name: String, _new_count: int) -> void:
	if item_name == "wood":
		_refresh(item_name)

func _refresh(item_name: String) -> void:
	wood_label.text = "Wood: %d" % Inventory.get_count(item_name)

func _on_skill_practiced(skill_name: String, _new_count: int) -> void:
	if skill_name == "chopping":
		_refresh_chopping()

func _refresh_chopping() -> void:
	chopping_label.text = "Chopping: %d / %d" % [Skills.get_count("chopping"), Skills.get_next_threshold("chopping")]

func _on_milestone_reached(skill_name: String, threshold: int, _new_count: int) -> void:
	show_toast("%s milestone! (%d practices)" % [skill_name.capitalize(), threshold])

func show_toast(text: String) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer.start()

func _on_toast_timeout() -> void:
	toast_label.visible = false
