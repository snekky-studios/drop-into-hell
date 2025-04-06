extends StaticBody2D
class_name Level

signal finished_dissolving

var tile_map_layer : TileMapLayer = null

func _ready() -> void:
	tile_map_layer = %TileMapLayer
	return

func set_dissolve_integrity(integrity : float) -> void:
	tile_map_layer.material.set_shader_parameter("integrity", integrity)
	return

func dissolve() -> void:
	var tween : Tween = create_tween()
	await tween.tween_method(set_dissolve_integrity, 1.0, 0.0, 1.0).finished
	finished_dissolving.emit()
	queue_free()
	return
