extends Resource
class_name EntityStats

@export var hitpoints : int = 100 : set = _set_hitpoints
@export var attack : int = 10


func _ready() -> void:
	
	return

func _set_hitpoints(value : int) -> void:
	hitpoints = value
	emit_changed()
	return
