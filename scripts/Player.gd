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
const CAST_FIRE_COST = 25.0
const FIREBALL_SPAWN_OFFSET = 0.5 # ahead of the camera so it clears the near clip plane
## Cast cooldown shrinks from START toward FLOOR as fire_magic practice grows
## (Brief: "cast duration can be decreased by practicing"). SCALE is the
## practice count at which the gap to FLOOR has halved.
const CAST_COOLDOWN_START = 2.0
const CAST_COOLDOWN_FLOOR = 0.4
const CAST_COOLDOWN_PRACTICE_SCALE = 20.0
const BLOCK_SCENE: PackedScene = preload("res://scenes/props/Block.tscn")
const FIREBALL_SCENE: PackedScene = preload("res://scenes/props/Fireball.tscn")
const MOUSE_SENSITIVITY: float = 0.0025
const MIN_PITCH: float = deg_to_rad(-70.0)
const MAX_PITCH: float = deg_to_rad(35.0)
var _cast_cooldown_remaining: float = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _sprint_held_time: float = 0.0
var _spawn_position: Vector3
var _pitch: float = 0.0

@onready var health: Node = $Health
@onready var visual_body: Node3D = $VisualBody
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready() -> void:
	_spawn_position = position
	health.died.connect(_on_died)
	camera_pivot.rotation.x = _pitch
	visual_body.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Dying is a respawn, not a game over: back to spawn with health and
## survival stats refilled. The HUD shows the "You died" toast off the same
## died signal, so nothing here talks to UI.
func _on_died() -> void:
	position = _spawn_position
	velocity = Vector3.ZERO
	health.refill()
	Stats.add("hunger", Stats.MAX_VALUE)
	Stats.add("stamina", Stats.MAX_VALUE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_pitch = clamp(_pitch - event.relative.y * MOUSE_SENSITIVITY, MIN_PITCH, MAX_PITCH)
		camera_pivot.rotation.x = _pitch
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("place_block"):
		_try_place_block()
	elif event.is_action_pressed("attack"):
		_try_attack()
	elif event.is_action_pressed("cast_fire"):
		_try_cast_fire()

## Raycast from the camera along its view direction, out to max_range.
func _camera_raycast(max_range: float) -> Dictionary:
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

## Pure so it's probe-able headless without needing tree membership (see
## PROGRESS.md's Notes for future sessions) — same pattern as
## Fireball._forward_motion / Enemy._chase_direction.
static func _can_afford_cast(mana: float, cost: float) -> bool:
	return mana >= cost

static func _cast_ready(cooldown_remaining: float) -> bool:
	return cooldown_remaining <= 0.0

## Cooldown duration for the NEXT cast, given how many times fire_magic has
## been practiced so far — approaches CAST_COOLDOWN_FLOOR but never reaches
## it, so practice always helps but casting is never truly instant.
static func _cast_cooldown_for_practice(practice_count: int) -> float:
	var t: float = float(practice_count) / CAST_COOLDOWN_PRACTICE_SCALE
	return CAST_COOLDOWN_FLOOR + (CAST_COOLDOWN_START - CAST_COOLDOWN_FLOOR) / (1.0 + t)

## Aim follows the camera look direction.
static func _cast_aim_direction(camera_basis: Basis) -> Vector3:
	return (-camera_basis.z).normalized()

static func _cast_spawn_transform(camera_pos: Vector3, camera_basis: Basis, spawn_offset: float) -> Transform3D:
	var aim: Vector3 = _cast_aim_direction(camera_basis)
	return Transform3D(Basis.looking_at(aim, Vector3.UP), camera_pos + aim * spawn_offset)

## Casting costs mana, spent up front: a no-mana attempt (or one still on
## cooldown) is a silent no-op and does NOT practice "fire_magic" (unlike
## combat, where whiffs still train — here the resource cost is what counts
## as practice, per the Brief's framing of magic practice). A successful
## cast starts a cooldown that shrinks as fire_magic is practiced more.
func _try_cast_fire() -> void:
	if not _cast_ready(_cast_cooldown_remaining):
		return
	if not _can_afford_cast(Stats.get_value("mana"), CAST_FIRE_COST):
		return
	var fireball: Area3D = FIREBALL_SCENE.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_transform = _cast_spawn_transform(
		camera.global_position, camera.global_transform.basis, FIREBALL_SPAWN_OFFSET
	)
	Stats.add("mana", -CAST_FIRE_COST)
	Skills.practice("fire_magic", 1)
	_cast_cooldown_remaining = _cast_cooldown_for_practice(Skills.get_count("fire_magic"))

func _physics_process(delta):
	if _cast_cooldown_remaining > 0.0:
		_cast_cooldown_remaining = max(_cast_cooldown_remaining - delta, 0.0)
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
