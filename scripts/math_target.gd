extends Node2D

const SIZE: Vector2 = Vector2(136, 74)
var row_id: int = 0
var operation: String = "+"
var operand: int = 5
var resolved: bool = false


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
	var color := Color("8de3b5") if is_bonus() else Color("fa9b87")
	draw_style_box(card_style(color), Rect2(-SIZE / 2.0, SIZE))


func card_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

