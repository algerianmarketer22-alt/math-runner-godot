extends SceneTree
## Native touch controls and touch-to-mouse UI events, with a real viewport.

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	root.size = Vector2i(720, 1080)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game.hud.set_touch_visible(true)
	await touch(0, Vector2(90, 1000), true)
	check(Input.is_action_pressed("move_left"), "Toucher gauche maintenu")
	await touch(1, Vector2(630, 1000), true)
	check(Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"), "Deux doigts indépendants")
	await touch(0, Vector2(90, 1000), false)
	check(not Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"), "Relâchement d'un seul doigt")
	await touch(1, Vector2(630, 1000), false)
	check(not Input.is_action_pressed("move_right"), "Relâchement complet")
	await tap(Vector2(620, 43))
	check(game.is_paused, "Bouton Pause utilisable au doigt")
	await tap(Vector2(620, 43))
	check(not game.is_paused, "Bouton Reprendre utilisable au doigt")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.is_paused, "Perte de focus met en pause")
	await tap(Vector2(620, 43))
	check(not game.is_paused, "Reprise tactile après perte de focus")
	game.finish(false)
	await tap(Vector2(360, 680))
	check(not game.finished and game.charge == 10, "Bouton Rejouer utilisable au doigt")
	game.queue_free()
	await process_frame
	print("Tactile : %d vérifications, %d échecs" % [checks, failures])
	quit(1 if failures else 0)


func touch(index: int, location: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = location
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func tap(location: Vector2) -> void:
	await touch(0, location, true)
	await touch(0, location, false)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
