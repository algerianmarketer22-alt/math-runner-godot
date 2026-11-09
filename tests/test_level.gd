extends SceneTree
## Play the real physics loop with keyboard actions, without rendering.


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var frames: int = 0
	while not game.finished and frames < 4800:
		var closest = null
		for target in game.targets.get_children():
			if target.resolved:
				continue
			if closest == null or target.row_id < closest.row_id:
				closest = target
			elif target.row_id == closest.row_id:
				var rules = load("res://scripts/math_rules.gd")
				if rules.apply(game.charge, target.operation, target.operand) > rules.apply(game.charge, closest.operation, closest.operand):
					closest = target
		Input.action_release("move_left")
		Input.action_release("move_right")
		if closest != null:
			var difference: float = closest.position.x - game.player.position.x
			if absf(difference) > 9.0:
				Input.action_press("move_right" if difference > 0 else "move_left")
		await physics_frame
		frames += 1
	var success: bool = game.finished and game.won and game.resolved_waves == 18
	print("Niveau physique : %d images, %d/18 rangées, charge %d, vies %d, victoire %s" % [frames, game.resolved_waves, game.charge, game.lives, game.won])
	if not success:
		push_error("Le pilote doit finir le niveau par les vraies commandes et collisions")
	game.queue_free()
	await process_frame
	quit(0 if success else 1)
