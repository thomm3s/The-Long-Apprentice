extends CharacterBody3D

## Placeholder enemy: chases the player when they come within AGGRO_RANGE,
## stopping at KEEP_DISTANCE so it doesn't shove into them. Killable via its
## Health child (group "damageable" + the player's attack raycast). Its own
## melee attack is a separate queue item.

signal enemy_died

const SPEED = 3.0
const AGGRO_RANGE = 12.0
const KEEP_DISTANCE = 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var health: Node = $Health

func _ready() -> void:
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction: Vector3 = Vector3.ZERO
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		direction = _chase_direction(global_position, player.global_position)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	move_and_slide()

## Flat (XZ) direction from from_pos toward target_pos, or ZERO when the
## target is outside aggro range or already within keep-distance.
static func _chase_direction(from_pos: Vector3, target_pos: Vector3) -> Vector3:
	var to_target: Vector3 = target_pos - from_pos
	to_target.y = 0.0
	var distance: float = to_target.length()
	if distance > AGGRO_RANGE or distance <= KEEP_DISTANCE:
		return Vector3.ZERO
	return to_target.normalized()

func _on_died() -> void:
	enemy_died.emit()
	queue_free()
