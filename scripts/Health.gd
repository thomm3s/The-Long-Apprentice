extends Node

## Reusable health component: add as a child node named "Health" to any
## damageable body (player, enemy). The owner listens to died to decide what
## dying means for it (queue_free, respawn, ...); this node only tracks the
## number. Mirrors the project's reusable-scene rule at the script level.

signal damaged(new_health: float, amount: float)
signal died

@export var max_health: float = 100.0

var health: float = max_health

func _ready() -> void:
	# Re-sync in case a scene overrode max_health after _init.
	health = max_health

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = clampf(health - amount, 0.0, max_health)
	damaged.emit(health, amount)
	if health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	health = clampf(health + amount, 0.0, max_health)

func refill() -> void:
	health = max_health
