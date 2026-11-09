extends Node2D

signal fired(origin: Vector2)

const SPEED: float = 440.0
const FIRE_INTERVAL: float = 0.22
const MIN_X: float = 120.0
const MAX_X: float = 600.0
var fire_cooldown: float = 0.0
var active: bool = true


func _physics_process(delta: float) -> void:
	if not active:
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	position.x = clampf(position.x + direction * SPEED * delta, MIN_X, MAX_X)
	fire_cooldown -= delta
	if fire_cooldown <= 0.0:
		fired.emit(position + Vector2(0, -42))
		fire_cooldown = FIRE_INTERVAL


func _draw() -> void:
	# Deliberately static shapes: gameplay before animation or effects.
	draw_circle(Vector2(0, 4), 25, Color("173a50"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -32), Vector2(23, 20), Vector2(0, 9), Vector2(-23, 20)
	]), Color("5ce3ed"))
	draw_rect(Rect2(-5, -43, 10, 22), Color("efffff"))

