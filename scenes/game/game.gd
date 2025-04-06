extends Node2D
class_name Game

enum Side {
	LEFT,
	RIGHT
}

const VERSION : String = "v1.0.1"

const LEVEL : PackedScene = preload("res://scenes/level/level.tscn")
const DEVIL : PackedScene = preload("res://scenes/enemy/enemy.tscn")
const SATAN : PackedScene = preload("res://scenes/satan/satan.tscn")
const BULLET : PackedScene = preload("res://scenes/bullet/bullet.tscn")

const STATS_ENEMY : Resource = preload("res://data/entity/devil_stats.tres")
const STATS_SATAN : Resource = preload("res://data/entity/satan_stats.tres")

const DEVIL_KILL_COUNT_MAX : int = 6
const DEVIL_SPAWN_TIME : float = 5.0
const SPAWNING_DEVILS_THRESHOLD : int = 1000
const LEVEL_OFFSET : int = 1800
const SATAN_HEIGHT : int = 64

var player : Player = null
var camera : Camera = null

var timer_devil_spawner : Timer = null
var path_left : Path2D = null
var path_right : Path2D = null
var path_follow_left : PathFollow2D = null
var path_follow_right : PathFollow2D = null
var color_rect_white : ColorRect = null
var color_rect_black : ColorRect = null
var label_drop : Label = null
var label_into : Label = null
var label_hell : Label = null

var level : Level = null

var is_spawning_devils : bool = false
var last_spawned : Game.Side = Side.RIGHT
var devil_kill_count : int = 0

func _ready() -> void:
	player = %Player
	camera = %Camera
	timer_devil_spawner = %TimerDevilSpawner
	path_left = %PathLeft
	path_right = %PathRight
	path_follow_left = %PathFollowLeft
	path_follow_right = %PathFollowRight
	color_rect_white = %ColorRectWhite
	color_rect_black = %ColorRectBlack
	label_drop = %LabelDrop
	label_into = %LabelInto
	label_hell = %LabelHell
	
	player.set_physics_process(false)
	player.dead.connect(_on_player_dead)
	player.was_hit.connect(camera.apply_shake)
	camera.shake_fade = 10.0
	
	# prevents lag spike when particles first emit
	var devil_temp : Area2D = DEVIL.instantiate()
	devil_temp.stats = STATS_ENEMY.duplicate()
	devil_temp.player = player
	devil_temp.position = Vector2(-1000, -1000)
	add_child(devil_temp)
	devil_temp.stats.hitpoints = 0
	var bullet_temp : Area2D = BULLET.instantiate()
	bullet_temp.position = Vector2(-1000, -1000)
	add_child(bullet_temp)
	bullet_temp.set_particles_initial_velocity(10.0)
	await get_tree().create_timer(1.0).timeout
	bullet_temp.queue_free()
	
	
	await title_animation()
	player.set_physics_process(true)
	return

func _physics_process(_delta: float) -> void:
	path_follow_left.global_position.x = -32
	path_follow_right.global_position.x = 672
	if(not is_spawning_devils):
		if(player.position.y > SPAWNING_DEVILS_THRESHOLD):
			is_spawning_devils = true
			timer_devil_spawner.start()
	return

func title_animation() -> void:
	await get_tree().create_timer(1.0).timeout
	label_drop.show()
	camera.apply_shake()
	await get_tree().create_timer(0.5).timeout
	label_into.show()
	camera.apply_shake()
	await get_tree().create_timer(0.5).timeout
	label_hell.show()
	camera.apply_shake()
	return

func spawn_level() -> void:
	level = LEVEL.instantiate()
	level.position.y = player.position.y + LEVEL_OFFSET
	get_tree().current_scene.call_deferred("add_child", level)
	return

func spawn_satan() -> void:
	var satan = SATAN.instantiate()
	var satan_stats = STATS_SATAN.duplicate()
	satan.position.x = 0.5 * get_viewport_rect().size.x
	satan.position.y = player.position.y + LEVEL_OFFSET - SATAN_HEIGHT
	satan.player = player
	satan.stats = satan_stats
	satan.dead.connect(_on_satan_dead)
	get_tree().current_scene.call_deferred("add_child", satan)
	return

func fade_to_white(value : float):
	color_rect_white.modulate.a = value
	camera.apply_shake(lerpf(0.0, 10.0, value))
	return

func fade_to_black(value : float):
	color_rect_black.modulate.a = value
	return

func num_enemies() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func _on_devil_dead() -> void:
	devil_kill_count += 1
	camera.apply_shake()
	if(devil_kill_count >= DEVIL_KILL_COUNT_MAX):
		devil_kill_count = -1000
		timer_devil_spawner.stop()
		spawn_level()
		spawn_satan()
	return

func _on_satan_dead() -> void:
	player.progress_bar_hitpoints.hide()
	camera.apply_shake()
	level.dissolve()
	await get_tree().create_timer(2.0).timeout
	var tween : Tween = get_tree().create_tween()
	await tween.tween_method(fade_to_white, 0.0, 1.0, 10.0).finished
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()
	return

func _on_player_dead() -> void:
	player.progress_bar_hitpoints.hide()
	await get_tree().create_timer(1.0).timeout
	var tween : Tween = get_tree().create_tween()
	await tween.tween_method(fade_to_black, 0.0, 1.0, 5.0).finished
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
	return

# debug only
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("skip")):
		#_on_satan_dead()
		pass
	return

func _on_timer_devil_spawner_timeout() -> void:
	timer_devil_spawner.wait_time = DEVIL_SPAWN_TIME + num_enemies()
	var devil = DEVIL.instantiate()
	var stats = STATS_ENEMY.duplicate()
	devil.stats = stats
	devil.player = player
	if(last_spawned == Side.RIGHT):
		path_follow_left.progress_ratio = randf()
		devil.position = path_follow_left.position
		devil.direction = Enemy.Direction.RIGHT
		last_spawned = Side.LEFT
	elif(last_spawned == Side.LEFT):
		path_follow_right.progress_ratio = randf()
		devil.position = path_follow_right.position
		devil.direction = Enemy.Direction.LEFT
		last_spawned = Side.RIGHT
	devil.dead.connect(_on_devil_dead)
	add_child(devil)
	return
