extends CanvasLayer

const TOAST_DURATION: float = 3.0

@onready var wood_label: Label = $WoodLabel
@onready var chopping_label: Label = $ChoppingLabel
@onready var toast_label: Label = $ToastLabel
@onready var toast_timer: Timer = $ToastTimer
@onready var hunger_bar: ProgressBar = $HungerBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar

func _ready() -> void:
	Inventory.changed.connect(_on_inventory_changed)
	Skills.practiced.connect(_on_skill_practiced)
	Skills.milestone_reached.connect(_on_milestone_reached)
	Stats.changed.connect(_on_stat_changed)
	toast_label.visible = false
	toast_timer.wait_time = TOAST_DURATION
	toast_timer.one_shot = true
	toast_timer.timeout.connect(_on_toast_timeout)
	_refresh("wood")
	_refresh_chopping()
	hunger_bar.value = Stats.get_value("hunger")
	stamina_bar.value = Stats.get_value("stamina")
	mana_bar.value = Stats.get_value("mana")
	_connect_player_health()

## The player is a sibling instanced in Main.tscn, so look it up by group
## rather than a hardcoded path; guard against HUD reuse in player-less
## scenes.
func _connect_player_health() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Health"):
		return
	var health: Node = player.get_node("Health")
	health.health_changed.connect(func(new_health: float): health_bar.value = new_health)
	health.died.connect(func(): show_toast("You died"))
	health_bar.max_value = health.max_health
	health_bar.value = health.health

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

func _on_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"hunger":
			hunger_bar.value = new_value
		"stamina":
			stamina_bar.value = new_value
		"mana":
			mana_bar.value = new_value

func _on_milestone_reached(skill_name: String, threshold: int, _new_count: int) -> void:
	show_toast("%s milestone! (%d practices)" % [skill_name.capitalize(), threshold])

func show_toast(text: String) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer.start()

func _on_toast_timeout() -> void:
	toast_label.visible = false
