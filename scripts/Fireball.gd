extends Area3D

## Reusable magic projectile. A caster spawns this and sets its
## global_transform before adding it to the tree (forward is -Z, matching
## Player's aim direction) — this scene doesn't know or care who cast it. Flies forward at a constant
## speed, damages the first "damageable" group body with a Health child it
## touches, and self-frees on any collision or after MAX_RANGE traveled /
## MAX_LIFETIME elapsed (whichever comes first), so a miss can't fly
## forever. Not yet spawned by anything — the player-casting queue item
## wires that up.

const SPEED: float = 15.0
const DAMAGE: float = 20.0
const MAX_RANGE: float = 20.0
const MAX_LIFETIME: float = 5.0

var _traveled: float = 0.0
var _age: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var motion: Vector3 = _forward_motion(global_transform.basis, delta)
	global_position += motion
	_traveled += motion.length()
	_age += delta
	if _traveled >= MAX_RANGE or _age >= MAX_LIFETIME:
		queue_free()

## Pure so it's probe-able headless without needing tree membership (a node
## add_child()ed during a one-shot probe's _initialize() errors on
## global_transform reads — see PROGRESS.md's Notes for future sessions).
static func _forward_motion(basis: Basis, delta: float) -> Vector3:
	return -basis.z * SPEED * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return
	if body.is_in_group("damageable") and body.has_node("Health"):
		body.get_node("Health").take_damage(DAMAGE)
	queue_free()
