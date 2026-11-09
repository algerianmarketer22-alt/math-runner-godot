extends SceneTree
var failures: int = 0
func _initialize() -> void:
	run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	check(game.charge == 1, "Un avion initial")
	game.spawn_wave()
	var bonus = game.targets.get_child(0)
	game.resolve_target(bonus)
	check(game.charge == 6 and game.player.formation().size() == 6, "+5 ajoute cinq avions")
	game.clear_entities()
	game.fire(game.player.position)
	check(game.projectiles.get_child_count() == 6, "Chaque avion tire")
	game.spawn_wave()
	var multiply = game.targets.get_child(1)
	game.resolve_target(multiply)
	check(game.charge == 12, "x2 double l'escadrille")
	var rock = game.targets.get_child(0)
	game.resolve_target(rock)
	check(game.charge == 12 and rock.health == rock.max_health - 1, "Obstacle résistant sans bonus")
	while not rock.resolved:
		game.resolve_target(rock)
	check(rock.resolved and game.charge == 12, "Obstacle détruit sans puissance gagnée")
	game.spawned_waves = 30
	game.spawn_wave()
	check(game.spawned_waves == 31 and not game.finished, "Survie après 18 vagues")
	check(game.director.scroll_speed(30) > game.director.scroll_speed(0), "Accélération")
	check(game.director.spawn_interval(30) < game.director.spawn_interval(0), "Densité croissante")
	game.restart()
	game.spawn_wave()
	game.player.position.x = 360
	game.miss_row(0)
	check(game.lives == 2, "Collision avec obstacle coûte un blindage")
	game.restart()
	game.spawn_wave()
	game.player.position.x = 120
	game.miss_row(0)
	check(game.lives == 3, "Obstacle esquivé ne blesse pas")
	game.clear_entities()
	game.toggle_fire()
	game.player._physics_process(0.5)
	check(game.projectiles.get_child_count() == 0, "Arrêt du tir")
	game.toggle_fire()
	game.player._physics_process(0.5)
	check(game.projectiles.get_child_count() > 0, "Reprise du tir")
	check(game.director.enemy_health("scout", 0) == 3, "Éclaireur : trois balles")
	check(game.director.enemy_health("armor", 0) == 9, "Blindé : neuf balles")
	check(game.director.enemy_health("carrier", 0) == 18, "Cuirassé : dix-huit balles")
	check(game.director.enemy_health("carrier", 24) > 18, "Résistance progressive")
	check(game.director.scroll_speed(0) == 65, "Défilement ralenti")
	var values: Dictionary = {}
	for wave in range(60):
		for choice in game.director.choices(wave):
			if choice[0] in ["+", "-", "*", "/"]:
				values[str(choice)] = true
	check(values.size() > 15, "Opérations variées")
	game.queue_free()
	await process_frame
	print("Escadrille : 19 vérifications, %d échecs" % failures)
	quit(1 if failures else 0)
