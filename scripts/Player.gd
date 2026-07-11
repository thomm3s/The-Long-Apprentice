extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const INTERACT_RANGE = 3.0
const PLACE_RANGE = 10.0
const BLOCK_SCENE: PackedScene = preload("res://scenes/props/Block.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("place_block"):
		_try_place_block()

func _try_interact() -> void:
	var camera: Camera3D = $Camera3D
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z) * INTERACT_RANGE
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)
	if result and result.collider.is_in_group("choppable") and result.collider.has_method("chop"):
		result.collider.chop()
		var next_threshold: int = Skills.get_next_threshold("chopping")
		Skills.practice("chopping", 1)
		# Crossing a threshold on this chop grants bonus wood (perk unlock).
		var wood_gain: int = 2 if Skills.get_count("chopping") >= next_threshold else 1
		Inventory.add("wood", wood_gain)
		print("Wood: ", Inventory.get_count("wood"))

func _try_place_block() -> void:
	if Inventory.get_count("wood") <= 0:
		return
	var camera: Camera3D = $Camera3D
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z) * PLACE_RANGE
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var block: Node3D = BLOCK_SCENE.instantiate()
		get_tree().current_scene.add_child(block)
		block.global_position = result.position + result.normal * 0.5
		Inventory.add("wood", -1)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
