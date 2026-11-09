extends CanvasLayer

signal pause_requested
signal restart_requested

var status: Label
var progress: Label
var feedback: Label
var banner: Label
var pause_button: Button
var restart_button: Button
var touch_left: TouchScreenButton
var touch_right: TouchScreenButton
var touch_labels: Array[Label] = []
var show_touch: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var control := Control.new()
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(control)
	var title := make_label(control, "MATH / RUNNER", Vector2(48, 24), Vector2(490, 35), 25)
	title.add_theme_color_override("font_color", Color("5ce3ed"))
	status = make_label(control, "", Vector2(48, 69), Vector2(620, 42), 30)
	progress = make_label(control, "", Vector2(48, 119), Vector2(630, 30), 20)
	feedback = make_label(control, "Bougez pour viser • tir automatique", Vector2(48, 158), Vector2(630, 28), 19)
	feedback.add_theme_color_override("font_color", Color("ffdc85"))
	banner = make_label(control, "", Vector2(76, 385), Vector2(568, 240), 28)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.add_theme_stylebox_override("normal", panel_style())
	banner.hide()
	pause_button = make_button(control, "Pause", Vector2(566, 24), Vector2(108, 38))
	pause_button.pressed.connect(func(): pause_requested.emit())
	restart_button = make_button(control, "Rejouer", Vector2(250, 652), Vector2(220, 58))
	restart_button.pressed.connect(func(): restart_requested.emit())
	restart_button.hide()
	touch_left = make_touch("move_left", Vector2(90, 1000))
	touch_right = make_touch("move_right", Vector2(630, 1000))
	touch_labels.append(make_label(control, "◀", Vector2(30, 968), Vector2(120, 64), 32))
	touch_labels.append(make_label(control, "▶", Vector2(570, 968), Vector2(120, 64), 32))
	for label in touch_labels:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_stylebox_override("normal", panel_style())
	var help := make_label(control, "← → / A D / Q D   ·   P : pause   ·   R : rejouer\nT : afficher les commandes tactiles", Vector2(160, 976), Vector2(400, 80), 16)
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	set_touch_visible(OS.has_feature("mobile"))


func update_status(charge: int, lives: int, resolved: int, total: int, goal: int) -> void:
	status.text = "Charge  %d     /     Vies  %d" % [charge, lives]
	progress.text = "NIVEAU 01     %02d / %02d choix     ·     Objectif %d" % [resolved, total, goal]


func show_message(text: String, can_restart: bool) -> void:
	banner.text = text
	banner.show()
	restart_button.visible = can_restart


func clear_message() -> void:
	banner.hide()
	restart_button.hide()


func set_touch_visible(value: bool) -> void:
	show_touch = value
	touch_left.visible = value
	touch_right.visible = value
	for label in touch_labels:
		label.visible = value


func make_touch(action: String, location: Vector2) -> TouchScreenButton:
	var button := TouchScreenButton.new()
	button.action = action
	button.position = location
	var shape := RectangleShape2D.new()
	shape.size = Vector2(120, 88)
	button.shape = shape
	button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	add_child(button)
	return button


func make_label(parent: Node, text: String, location: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = location
	label.size = dimensions
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e0e9f2"))
	parent.add_child(label)
	return label


func make_button(parent: Node, text: String, location: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = location
	button.size = dimensions
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 20)
	parent.add_child(button)
	return button


func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("142b41")
	style.set_corner_radius_all(12)
	style.content_margin_left = 16
	style.content_margin_right = 16
	return style

