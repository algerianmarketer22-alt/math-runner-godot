extends Node2D

const SIZE: Vector2 = Vector2(136, 74)
var row_id: int = 0
var operation: String = "+"
var operand: int = 5
var resolved: bool = false
var health: int = 1
var max_health: int = 1


func _ready() -> void:
	var label := Label.new()
	label.text = display_text()
	label.position = -SIZE / 2.0
	label.size = SIZE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color("0b1727"))
	add_child(label)


func display_text() -> String:
	if operation == "rock":
		return ""
	var symbol: String = operation
	match operation:
		"*": symbol = "×"
		"/": symbol = "÷"
		"-": symbol = "−"
	return "%s%d" % [symbol, operand]


func is_bonus() -> bool:
	return operation == "+" or operation == "*"


func bounds() -> Rect2:
	return Rect2(position - SIZE / 2.0, SIZE)


func _draw() -> void:
	if operation == "rock":
		draw_colored_polygon(PackedVector2Array([Vector2(-55,-28),Vector2(-20,-42),Vector2(44,-32),Vector2(61,8),Vector2(28,36),Vector2(-48,31)]), Color("6f8093"))
		draw_circle(Vector2(-20,-8), 14, Color("495c71"))
		draw_circle(Vector2(22,12), 10, Color("52667b"))
		draw_rect(Rect2(-55,43,110,5), Color("243448"))
		draw_rect(Rect2(-55,43,110.0 * health / max_health,5), Color("ffb84d"))
		return
	var color := Color("8de3b5") if is_bonus() else Color("fa9b87")
	draw_style_box(card_style(color), Rect2(-SIZE / 2.0, SIZE))


func card_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("e9ffff")
	style.set_border_width_all(2)
	style.shadow_color = Color(0,0,0,0.4)
	style.shadow_size = 6
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

