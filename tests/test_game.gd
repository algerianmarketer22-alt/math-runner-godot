extends SceneTree

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	if not FileAccess.file_exists("res://scenes/main.tscn"):
		check(false, "Le niveau jouable doit exister")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	check(game.charge == 10 and game.lives == 3, "État initial")
	var player = game.player
	check(player.position.x == 360.0, "Départ au centre")
	Input.action_press("move_left")
	player._physics_process(0.2)
	Input.action_release("move_left")
	check(player.position.x < 360.0, "Commande clavier gauche")
	Input.action_press("move_right")
	player._physics_process(10.0)
	Input.action_release("move_right")
	check(player.position.x <= 600.0, "Limite de la piste")
	game.clear_entities()
	player.position.x = 360.0
	player._physics_process(0.5)
	check(game.projectiles.get_child_count() > 0, "Tir automatique sans bouton")
	game.clear_entities()
	game.spawn_wave()
	var target = game.targets.get_child(0)
	var row_id: int = target.row_id
	var operation: String = target.operation
	var operand: int = target.operand
	game.resolve_target(target)
	check(game.charge == load("res://scripts/math_rules.gd").apply(10, operation, operand), "Calcul via une cible réelle")
	var after: int = game.charge
	game.resolve_target(target)
	check(game.charge == after and game.resolved_waves == 1, "Une seule opération par rangée")
	check(not game.active_rows.has(row_id), "Choix exclusif")
	await process_frame
	game.restart()
	game.set_physics_process(false)
	game.spawn_wave()
	target = game.targets.get_child(0)
	var shot = game.PROJECTILE_SCENE.instantiate()
	shot.position = target.position + Vector2(0, 130)
	game.projectiles.add_child(shot)
	game.advance_projectiles(0.25)
	check(game.resolved_waves == 1, "Collision balayée : un tir rapide touche la cible")
	await process_frame
	game.restart()
	game.set_physics_process(false)
	for index in range(3):
		game.spawn_wave()
		var row: int = game.targets.get_child(game.targets.get_child_count() - 1).row_id
		game.miss_row(row)
	check(game.finished and not game.won and game.lives == 0, "Défaite après trois rangées manquées")
	game.restart()
	game.set_physics_process(false)
	check(not game.finished and game.charge == 10 and game.resolved_waves == 0, "Redémarrage complet")
	var first_speed: float = game.director.scroll_speed(0)
	check(game.director.scroll_speed(17) > first_speed, "Vitesse progressive")
	check(game.director.spawn_interval(17) < game.director.spawn_interval(0), "Fréquence progressive")
	for index in range(game.director.WAVE_COUNT):
		game.spawn_wave()
		var chosen = game.targets.get_child(game.targets.get_child_count() - 1)
		game.resolve_target(chosen)
	check(game.finished and game.won, "Victoire après 18 choix résolus")
	check(game.spawned_waves == 18, "Niveau fini sans génération infinie")
	game.restart()
	game.set_physics_process(false)
	game.toggle_pause()
	check(paused and game.is_paused, "Pause")
	game.toggle_pause()
	check(not paused and not game.is_paused, "Reprise")
	check(InputMap.has_action("move_left") and InputMap.has_action("move_right"), "InputMap clavier partagé avec le tactile")
	check(game.hud.touch_left.action == "move_left", "Tactile gauche natif")
	check(game.hud.touch_right.action == "move_right", "Tactile droit natif")
	game.queue_free()
	await process_frame
	print("Jeu : %d vérifications, %d échecs" % [checks, failures])
	quit(1 if failures else 0)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
