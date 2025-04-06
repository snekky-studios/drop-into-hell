extends CharacterBody2D
class_name Player

signal was_hit
signal dead

enum Side {
	RIGHT,
	LEFT
}

const SPEED : int = 300.0
const JUMP_VELOCITY : int = -400.0
const MAX_VELOCITY : int = 600
const MAX_JUMPS : int = 2

const COOLDOWN_SWING : float = 0.5
const COOLDOWN_BLOCK : float = 1.0
const COOLDOWN_JUMP : float = 1.0

@export var stats : EntityStats = null

var animation_player : AnimationPlayer = null
var timer_cooldown_swing : Timer = null
var timer_cooldown_block : Timer = null
var timer_cooldown_jump : Timer = null
var progress_bar_hitpoints = null

var sword_side : Player.Side = Side.RIGHT
var on_cooldown_swing : bool = false
var on_cooldown_block : bool = false
var on_cooldown_jump : bool = false
var num_jumps : int = 0
var is_dead : bool = false

func _ready() -> void:
	animation_player = %AnimationPlayer
	timer_cooldown_swing = %TimerCooldownSwing
	timer_cooldown_block = %TimerCooldownBlock
	timer_cooldown_jump = %TimerCooldownJump
	progress_bar_hitpoints = %ProgressBarHitpoints
	
	stats.changed.connect(_on_stats_changed)
	
	timer_cooldown_swing.wait_time = COOLDOWN_SWING
	timer_cooldown_block.wait_time = COOLDOWN_BLOCK
	
	progress_bar_hitpoints.max_value = stats.hitpoints
	progress_bar_hitpoints.value = stats.hitpoints
	return

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		num_jumps = 0
	
	# Handle jump.
	if not is_dead and num_jumps < MAX_JUMPS and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY
		num_jumps += 1
		timer_cooldown_jump.start()

	# Get the input direction and handle the movement/deceleration.
	var direction : float = Input.get_axis("left", "right")
	if not is_dead and direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	velocity.x = clampf(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
	velocity.y = clampf(velocity.y, -MAX_VELOCITY, MAX_VELOCITY)
	
	move_and_slide()
	return

func _unhandled_input(event: InputEvent) -> void:
	if(is_dead):
		return
	if(event.is_action_pressed("swing") and not on_cooldown_swing):
		on_cooldown_swing = true
		timer_cooldown_swing.start()
		if(get_local_mouse_position().y <= 0):
			if(sword_side == Side.RIGHT):
				animation_player.reset_section()
				animation_player.play("swing_up_left")
				sword_side = Side.LEFT
			elif(sword_side == Side.LEFT):
				animation_player.play("swing_up_right")
				sword_side = Side.RIGHT
			else:
				print("error: invalid sword side - " + str(sword_side))
		elif(get_local_mouse_position().y > 0):
			if(sword_side == Side.RIGHT):
				animation_player.play("swing_down_left")
				sword_side = Side.LEFT
			elif(sword_side == Side.LEFT):
				animation_player.play("swing_down_right")
				sword_side = Side.RIGHT
			else:
				print("error: invalid sword side - " + str(sword_side))
	elif(event.is_action_pressed("block") and not on_cooldown_block):
		on_cooldown_block = true
		timer_cooldown_block.start()
		if(get_local_mouse_position().y <= 0):
			animation_player.play("block_up")
		elif(get_local_mouse_position().y > 0):
			animation_player.play("block_down")
	return

func hit(damage : int) -> void:
	if(is_dead):
		return
	stats.hitpoints -= damage
	was_hit.emit()
	return

func _on_stats_changed() -> void:
	progress_bar_hitpoints.value = stats.hitpoints
	if(stats.hitpoints <= 0):
		dead.emit()
		is_dead = true
		animation_player.play("dead")
	return

func _on_timer_cooldown_swing_timeout() -> void:
	on_cooldown_swing = false
	return


func _on_timer_cooldown_block_timeout() -> void:
	on_cooldown_block = false
	return


func _on_timer_cooldown_jump_timeout() -> void:
	print("jumps reset")
	num_jumps = 0
	return
