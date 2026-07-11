extends CharacterBody3D

## Placeholder enemy: stands still and can be killed via its Health child
## (group "damageable" + the player's attack raycast). Chase AI and its own
## melee attack are separate queue items.

signal enemy_died

@onready var health: Node = $Health

func _ready() -> void:
	health.died.connect(_on_died)

func _on_died() -> void:
	enemy_died.emit()
	queue_free()
