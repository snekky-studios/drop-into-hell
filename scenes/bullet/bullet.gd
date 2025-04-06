extends Area2D
class_name Bullet

const SPEED : int = 7
const DAMAGE : int = 8

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	
	return

func _physics_process(delta: float) -> void:
	position += direction * SPEED
	return

func set_direction(direction_arg : Vector2) -> void:
	direction = direction_arg
	return

func _on_body_entered(body : Node2D) -> void:
	if(body is Player):
		body.hit(DAMAGE)
		queue_free()
	return

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	return
