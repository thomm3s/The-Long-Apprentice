extends StaticBody3D

## Placeholder chop-able tree. Belongs to the "choppable" group so the
## player's interact raycast can find it generically (no type checks needed).

signal chopped

func chop() -> void:
	chopped.emit()
	queue_free()
