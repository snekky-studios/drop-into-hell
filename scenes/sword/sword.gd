extends Area2D
class_name Sword

const DAMAGE : int = 50

func _ready() -> void:
	return

func _on_area_entered(area: Area2D) -> void:
	if(area is Enemy):
		area.hit(DAMAGE)
	return

func _on_body_entered(body: Node2D) -> void:
	if(body is Satan):
		body.hit(DAMAGE)
	return
