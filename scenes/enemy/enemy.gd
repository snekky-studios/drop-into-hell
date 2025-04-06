extends Area2D
class_name Enemy

signal dead

enum State {
	IDLE,
	MOVING
}

enum Direction {
	LEFT,
	RIGHT
}

const BULLET : PackedScene = preload("res://scenes/bullet/bullet.tscn")

const SPEED : float = 300.0
const SPEED_HORIZONTAL : float = 0.3
const TERMINAL_VELOCITY : Vector2 = Vector2(0, 600)
const MOVE_BUFFER : float = 32.0
const MOVE_MAGNITUDE_Y : float = 100.0
const DEATH_TIME : float = 0.5

var sprite_2d : Sprite2D = null
var timer_shoot : Timer = null
var progress_bar_hitpoints : ProgressBar = null
var particles : GPUParticles2D = null

@export var stats : EntityStats = null
@export var player : Player = null

var state : State = State.IDLE
var time : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var position_previous : Vector2 = Vector2.ZERO
var direction : Enemy.Direction = Direction.LEFT

func _ready() -> void:
	sprite_2d = %Sprite2D
	timer_shoot = %TimerShoot
	progress_bar_hitpoints = %ProgressBarHitpoints
	particles = %Particles
	
	stats.changed.connect(_on_stats_changed)
	
	progress_bar_hitpoints.max_value = stats.hitpoints
	progress_bar_hitpoints.value = stats.hitpoints
	return

func _physics_process(delta: float) -> void:
	time += delta
	position.y = player.position.y + MOVE_MAGNITUDE_Y * sin(time)
	if(direction == Direction.LEFT):
		position.x -= SPEED_HORIZONTAL
	elif(direction == Direction.RIGHT):
		position.x += SPEED_HORIZONTAL
	else:
		print("error: invalid direction - " + str(direction))
	
	if(position.x < MOVE_BUFFER):
		direction = Direction.RIGHT
	elif(position.x > get_viewport_rect().size.x - MOVE_BUFFER):
		direction = Direction.LEFT
	
	match state:
		State.IDLE:
			pass
		State.MOVING:
			pass
		_:
			print("error: invalid state - " + str(state))
	
	velocity = (position - position_previous) / delta
	position_previous = position
	return

func hit(damage : int) -> void:
	stats.hitpoints -= damage
	return

func _on_stats_changed() -> void:
	progress_bar_hitpoints.value = stats.hitpoints
	if(stats.hitpoints <= 0):
		dead.emit()
		progress_bar_hitpoints.hide()
		sprite_2d.hide()
		particles.emitting = true
		await get_tree().create_timer(DEATH_TIME).timeout
		queue_free()
	return

func _on_timer_shoot_timeout() -> void:
	var bullet = BULLET.instantiate()
	var direction_bullet_raw = player.position - position
	var direction_bullet = direction_bullet_raw.normalized()
	bullet.set_direction(direction_bullet)
	add_child(bullet)
	bullet.set_particles_initial_velocity(velocity.y)
	return
