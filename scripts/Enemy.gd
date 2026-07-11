extends CharacterBody3D

## Placeholder enemy: chases the player when they come within AGGRO_RANGE,
## stopping at KEEP_DISTANCE so it doesn't shove into them. Killable via its
## Health child (group "damageable" + the player's attack raycast). Its own
## melee attack is a separate queue item.

signal enemy_died

const SPEED = 3.0
const AGGRO_RANGE = 12.0
const KEEP_DISTANCE = 1.5
## Melee reach is a bit past keep-distance so the enemy can hit from where
## the chase stops.
const MELEE_REACH = 2.0
const MELEE_DAMAGE = 10.0
const MELEE_COOLDOWN = 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _melee_cooldown: float = 0.0

@onready var health: Node = $Health

func _ready() -> void:
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	_melee_cooldown = maxf(_melee_cooldown - delta, 0.0)
	var direction: Vector3 = Vector3.ZERO
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		direction = _chase_direction(global_position, player.global_position)
		var distance: float = global_position.distance_to(player.global_position)
		if _melee_ready(distance, _melee_cooldown):
			_melee_attack(player)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	move_and_slide()

static func _melee_ready(distance: float, cooldown: float) -> bool:
	return cooldown <= 0.0 and distance <= MELEE_REACH

## Damages the target's Health child if it has one (the player only gets a
## Health node in a later queue item — until then this is a harmless swing)
## and starts the cooldown either way.
func _melee_attack(target: Node) -> void:
	_melee_cooldown = MELEE_COOLDOWN
	if target.has_node("Health"):
		target.get_node("Health").take_damage(MELEE_DAMAGE)
		print("Enemy hit player for ", MELEE_DAMAGE)

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
