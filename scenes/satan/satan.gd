extends CharacterBody2D
class_name Satan

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

const SPEED : float = 20
const MOVE_BUFFER : float = 32.0
const PLAYER_OFFSET : float = 32.0
const DAMAGE : int = 20
const DEATH_TIME : float = 0.5

var sprite_2d : Sprite2D = null
var timer_shoot : Timer = null
var timer_attack : Timer = null
var progress_bar_hitpoints : ProgressBar = null
var animation_player : AnimationPlayer = null
var particles : GPUParticles2D = null

@export var stats : EntityStats = null
@export var player : Player = null

var state : State = State.IDLE
var time : float = 0.0
var direction : Satan.Direction = Direction.LEFT

func _ready() -> void:
	sprite_2d = %Sprite2D
	timer_shoot = %TimerShoot
	timer_attack = %TimerAttack
	progress_bar_hitpoints = %ProgressBarHitpoints
	animation_player = %AnimationPlayer
	particles = %Particles
	
	stats.changed.connect(_on_stats_changed)
	
	progress_bar_hitpoints.max_value = stats.hitpoints
	progress_bar_hitpoints.value = stats.hitpoints
	return

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if(position.x < player.position.x - PLAYER_OFFSET):
		direction = Direction.RIGHT
		velocity.x = SPEED
	elif(position.x >= player.position.x + PLAYER_OFFSET):
		direction = Direction.LEFT
		velocity.x = -SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
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
	var bullet0 = BULLET.instantiate()
	var bullet1 = BULLET.instantiate()
	var bullet2 = BULLET.instantiate()
	
	var direction_bullet_raw = player.position - position
	var direction_bullet = direction_bullet_raw.normalized()
	
	bullet0.set_direction(direction_bullet)
	bullet1.set_direction(direction_bullet)
	bullet2.set_direction(direction_bullet)
	
	add_child(bullet0)
	bullet0.set_particles_initial_velocity(velocity.y)
	await get_tree().create_timer(0.2).timeout
	add_child(bullet1)
	bullet1.set_particles_initial_velocity(velocity.y)
	await get_tree().create_timer(0.2).timeout
	add_child(bullet2)
	bullet2.set_particles_initial_velocity(velocity.y)
	return

func _on_timer_attack_timeout() -> void:
	if(direction == Direction.LEFT):
		animation_player.play("attack_left")
	elif(direction == Direction.RIGHT):
		animation_player.play("attack_right")
	return

func _on_area_hitbox_body_entered(body: Node2D) -> void:
	if(body is Player):
		player.hit(DAMAGE)
	return
