extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = SPEED * 1.6
const SPRINT_PRACTICE_INTERVAL = 3.0
const STAMINA_DRAIN_PER_SEC = 100.0 / 15.0 # empties in 15s of continuous sprint
const STAMINA_REGEN_PER_SEC = 100.0 / 8.0 # refills in 8s while not sprinting
const STARVING_SPEED_MULT = 0.5 # movement penalty while hunger sits at 0
const JUMP_VELOCITY = 4.5
const INTERACT_RANGE = 3.0
const PLACE_RANGE = 10.0
const ATTACK_RANGE = 2.5
const ATTACK_DAMAGE = 25.0
const BLOCK_SCENE: PackedScene = preload("res://scenes/props/Block.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _sprint_held_time: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("place_block"):
		_try_place_block()
	elif event.is_action_pressed("attack"):
		_try_attack()

## Raycast from the camera along its view direction, out to max_range.
func _camera_raycast(max_range: float) -> Dictionary:
	var camera: Camera3D = $Camera3D
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z) * max_range
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	return space_state.intersect_ray(query)

func _try_interact() -> void:
	var result: Dictionary = _camera_raycast(INTERACT_RANGE)
	if not result:
		return
	if result.collider.is_in_group("choppable") and result.collider.has_method("chop"):
		result.collider.chop()
		var next_threshold: int = Skills.get_next_threshold("chopping")
		Skills.practice("chopping", 1)
		# Crossing a threshold on this chop grants bonus wood (perk unlock).
		var wood_gain: int = 2 if Skills.get_count("chopping") >= next_threshold else 1
		Inventory.add("wood", wood_gain)
		print("Wood: ", Inventory.get_count("wood"))
	elif result.collider.is_in_group("sleepable") and result.collider.has_method("sleep_in"):
		result.collider.sleep_in()

func _try_place_block() -> void:
	if Inventory.get_count("wood") <= 0:
		return
	var result: Dictionary = _camera_raycast(PLACE_RANGE)
	if result:
		var block: Node3D = BLOCK_SCENE.instantiate()
		get_tree().current_scene.add_child(block)
		block.global_position = result.position + result.normal * 0.5
		Inventory.add("wood", -1)

## Swing: always practices "combat" (whiffs train too, same as before),
## and damages whatever damageable body with a Health child is in reach.
func _try_attack() -> void:
	Skills.practice("combat", 1)
	var result: Dictionary = _camera_raycast(ATTACK_RANGE)
	if not result:
		return
	var target: Node = result.collider
	if target.is_in_group("damageable") and target.has_node("Health"):
		target.get_node("Health").take_damage(ATTACK_DAMAGE)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var sprinting: bool = direction != Vector3.ZERO and Input.is_action_pressed("sprint")
	_track_sprint(sprinting, delta)

	if direction:
		var speed: float = _current_speed(sprinting)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

## Movement speed for this frame: sprint bonus, then the starving penalty
## while hunger sits at 0 (the hunger-zero consequence — gray-box only, no
## damage/death from starving yet).
func _current_speed(sprinting: bool) -> float:
	var speed: float = SPRINT_SPEED if sprinting else SPEED
	if Stats.get_value("hunger") <= 0.0:
		speed *= STARVING_SPEED_MULT
	return speed

## Practices "running" every SPRINT_PRACTICE_INTERVAL seconds of continuous
## sprinting; releasing sprint (or stopping) resets the held-time count, so
## only sustained sprinting counts, not tapping the key. Also drains the
## stamina stat while sprinting and regenerates it otherwise (no gameplay
## consequence at 0 stamina yet — that's a separate queue item).
func _track_sprint(sprinting: bool, delta: float) -> void:
	if not sprinting:
		_sprint_held_time = 0.0
		Stats.add("stamina", STAMINA_REGEN_PER_SEC * delta)
		return
	Stats.add("stamina", -STAMINA_DRAIN_PER_SEC * delta)
	_sprint_held_time += delta
	while _sprint_held_time >= SPRINT_PRACTICE_INTERVAL:
		Skills.practice("running", 1)
		_sprint_held_time -= SPRINT_PRACTICE_INTERVAL
