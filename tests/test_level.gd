extends SceneTree
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in range(3600):
		if game.finished:
			game.restart()
		if frame % 120 == 0:
			Input.action_release("move_left")
			Input.action_release("move_right")
			Input.action_press("move_left" if frame % 240 == 0 else "move_right")
		await physics_frame
		assert(game.charge >= 1 and game.charge <= 24)
		assert(game.projectiles.get_child_count() < 1500)
	print("Survie : 3600 images physiques, effectif et projectiles bornés")
	game.queue_free()
	await process_frame
	quit()
