extends Camera2D
class_name Camera

#@export var random_strength : float = 30.0
@export var shake_fade : float = 5.0

var shake_strength : float = 0.0

func _ready() -> void:
	return

func _process(delta: float) -> void:
	if(shake_strength > 0):
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		offset = random_offset()
	return

func apply_shake(random_strength : float = 10) -> void:
	shake_strength = random_strength
	return

func random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
