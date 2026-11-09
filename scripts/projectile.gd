extends Node2D

const SPEED: float = 1050.0
const RADIUS: float = 5.0


func _draw() -> void:
	draw_rect(Rect2(-RADIUS, -10, RADIUS * 2, 20), Color("ffdc85"))

