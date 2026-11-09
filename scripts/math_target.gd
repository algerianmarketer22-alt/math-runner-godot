extends Node2D

const SIZE: Vector2 = Vector2(136, 74)
var row_id: int = 0
var operation: String = "+"
var operand: int = 5
var resolved: bool = false
var health: int = 1
var max_health: int = 1
var hit_flash: float = 0.0
var caption: Label

func is_enemy() -> bool:
	return operation in ["rock", "scout", "armor", "carrier"]

func enemy_name() -> String:
	return {"rock": "DRONE", "scout": "ÉCLAIREUR", "armor": "BLINDÉ", "carrier": "CUIRASSÉ"}.get(operation, "")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	caption = Label.new()
	caption.position = Vector2(-68, 49) if is_enemy() else Vector2(-68, -22)
	caption.size = Vector2(136, 42)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 15 if is_enemy() else 36)
	caption.add_theme_color_override("font_color", Color("f4e9cf"))
	add_child(caption)
	if not is_enemy():
		var label := Label.new()
		label.text = "RENFORT" if is_bonus() else "RISQUE"
		label.position = Vector2(-68, -34)
		label.size.x = 136
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color("9eb8b8"))
		add_child(label)
	update_caption()

func update_caption() -> void:
	caption.text = "%s  %d" % [enemy_name(), health] if is_enemy() else display_text()

func _process(delta: float) -> void:
	if hit_flash > 0:
		hit_flash = maxf(0, hit_flash - delta)
		update_caption()
		queue_redraw()

func display_text() -> String:
	if is_enemy():
		return ""
	var symbol: String = {"*": "×", "/": "÷", "-": "−"}.get(operation, operation)
	return "%s%d" % [symbol, operand]

func is_bonus() -> bool:
	return operation == "+" or operation == "*"

func bounds() -> Rect2:
	return Rect2(position - SIZE / 2, SIZE)

func _draw() -> void:
	if not is_enemy():
		var ink := Color("73cabb") if is_bonus() else Color("e58b71")
		var style := StyleBoxFlat.new()
		style.bg_color = Color("152c37")
		style.border_color = ink
		style.set_border_width_all(2)
		style.set_corner_radius_all(5)
		style.shadow_color = Color(0,0,0,0.35)
		style.shadow_size = 5
		draw_style_box(style, Rect2(-SIZE / 2, SIZE))
		draw_rect(Rect2(-68,-37,5,74), ink)
		return
	var hull := Color("cb745e")
	var outline := PackedVector2Array([Vector2(0,30),Vector2(-12,0),Vector2(-55,-15),Vector2(-52,-27),Vector2(-12,-17),Vector2(0,-33),Vector2(12,-17),Vector2(52,-27),Vector2(55,-15),Vector2(12,0)])
	if operation == "armor":
		hull = Color("b9ad8d")
		outline = PackedVector2Array([Vector2(-40,-31),Vector2(40,-31),Vector2(60,0),Vector2(40,30),Vector2(-40,30),Vector2(-60,0)])
	elif operation == "carrier":
		hull = Color("aeb8c3")
		outline = PackedVector2Array([Vector2(-60,-30),Vector2(60,-30),Vector2(60,20),Vector2(38,34),Vector2(13,20),Vector2(-13,20),Vector2(-38,34),Vector2(-60,20)])
	if hit_flash > 0:
		hull = Color("fff3d5")
	draw_set_transform(Vector2(4,6))
	draw_colored_polygon(outline, Color(0,0,0,0.3))
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(outline, hull)
	var edge := outline.duplicate()
	edge.append(outline[0])
	draw_polyline(edge, hull.lightened(0.3), 2, true)
	draw_rect(Rect2(-9,-22,18,43), Color("344956"))
	draw_rect(Rect2(-5,-5,10,15), Color("f5c577"))
	for side in [-1,1]:
		draw_line(Vector2(side*22,-17), Vector2(side*41,-10), hull.darkened(0.3), 3)
		if operation != "scout":
			draw_rect(Rect2(side*39-4,12,8,23), Color("334652"))
			draw_circle(Vector2(side*39,35), 4, Color("f6b76c"))
	draw_rect(Rect2(-53,42,106,4), Color("243448"))
	draw_rect(Rect2(-53,42,106.0*health/max_health,4), Color("e4b36f"))
	if hit_flash > 0:
		draw_line(Vector2(-14,-38),Vector2(-23,-48),Color("fff2c5"),2)
		draw_line(Vector2(14,-38),Vector2(23,-48),Color("fff2c5"),2)
