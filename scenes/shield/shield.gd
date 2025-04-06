extends Area2D
class_name Shield

func _ready() -> void:
	return

func _on_area_entered(area: Area2D) -> void:
	if(area is Bullet):
		area.queue_free()
	return
