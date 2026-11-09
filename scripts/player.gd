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


var squad_size: int = 1

func formation() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for i in range(squad_size):
		var column: int = i % 5
		var row: int = i / 5
		var width: int = mini(5, squad_size - row * 5)
		positions.append(Vector2((column - (width - 1) / 2.0) * 24, row * 15 - 20))
	return positions

func _draw() -> void:
	for offset in formation():
		draw_set_transform(offset)
		draw_circle(Vector2(0, 14), 10, Color(0.1, 0.8, 1, 0.12))
		draw_colored_polygon(PackedVector2Array([Vector2(-4, 10), Vector2(0, 27), Vector2(4, 10)]), Color("ffb84d"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-26), Vector2(6,-4), Vector2(19,9), Vector2(18,14), Vector2(4,8), Vector2(4,18), Vector2(-4,18), Vector2(-4,8), Vector2(-18,14), Vector2(-19,9), Vector2(-6,-4)]), Color("5ce3ed"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-21), Vector2(4,10), Vector2(-4,10)]), Color("edfaff"))
		draw_circle(Vector2(0,-3), 3, Color("174f88"))
	draw_set_transform(Vector2.ZERO)
