extends Area2D
class_name Bullet

const SPEED : int = 7
const DAMAGE : int = 10
const VELOCITY_INITIAL_OFFSET : float = 2.0

var particles : GPUParticles2D = null

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	particles = %Particles
	return

func _physics_process(_delta: float) -> void:
	position += direction * SPEED
	return

func set_direction(direction_arg : Vector2) -> void:
	direction = direction_arg
	return

func set_particles_initial_velocity(value : float) -> void:
	particles.process_material.initial_velocity_min = value - VELOCITY_INITIAL_OFFSET
	particles.process_material.initial_velocity_max = value + VELOCITY_INITIAL_OFFSET
	return

func _on_body_entered(body : Node2D) -> void:
	if(body is Player):
		body.hit(DAMAGE)
		queue_free()
	return

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	return
