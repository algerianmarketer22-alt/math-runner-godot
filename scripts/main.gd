extends Node2D

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")
const TARGET_SCENE = preload("res://scenes/math_target.tscn")
const RULES = preload("res://scripts/math_rules.gd")
const DIRECTOR = preload("res://scripts/level_director.gd")
const HUD = preload("res://scripts/hud.gd")
const MISS_LINE: float = 928.0

var player
var targets: Node2D
var projectiles: Node2D
var hud
var director = DIRECTOR.new()
var active_rows: Dictionary = {}
var charge: int = 1
var lives: int = 3
var spawned_waves: int = 0
var resolved_waves: int = 0
var spawn_cooldown: float = 0.8
var finished: bool = false
var won: bool = false
var is_paused: bool = false
var track_offset: float = 0.0
var scenery_offset: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	configure_input()
	targets = Node2D.new()
	targets.name = "Targets"
	add_child(targets)
	projectiles = Node2D.new()
	projectiles.name = "Projectiles"
	add_child(projectiles)
	player = PLAYER_SCENE.instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = Vector2(360, 856)
	player.fired.connect(fire)
	add_child(player)
	hud = HUD.new()
	hud.pause_requested.connect(toggle_pause)
	hud.restart_requested.connect(restart)
	hud.fire_requested.connect(toggle_fire)
	add_child(hud)
	refresh_hud()


func configure_input() -> void:
	var bindings: Dictionary = {
		"move_left": [KEY_LEFT, KEY_A, KEY_Q],
		"move_right": [KEY_RIGHT, KEY_D],
		"pause_game": [KEY_P, KEY_ESCAPE],
		"restart_game": [KEY_R],
		"toggle_touch": [KEY_T],
		"toggle_fire": [KEY_SPACE],
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key: int in bindings[action]:
				var event := InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action, event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		toggle_pause()
	elif event.is_action_pressed("restart_game"):
		restart()
	elif event.is_action_pressed("toggle_fire"):
		toggle_fire()
	elif event.is_action_pressed("toggle_touch"):
		hud.set_touch_visible(not hud.show_touch)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud):
		release_movement()
		if not is_paused and not finished:
			toggle_pause()


func _physics_process(delta: float) -> void:
	if finished or is_paused:
		return
	var speed: float = director.scroll_speed(maxi(spawned_waves - 1, 0))
	track_offset = fmod(track_offset + speed * delta, 84.0)
	scenery_offset = fmod(scenery_offset + speed * delta * 0.35, 900.0)
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0:
		spawn_wave()
		spawn_cooldown = director.spawn_interval(spawned_waves - 1)
	# Move targets first, then sweep each projectile against their current bounds.
	for target in targets.get_children():
		if not target.resolved:
			target.position.y += speed * delta
	advance_projectiles(delta)
	for target in targets.get_children():
		if not target.resolved and target.position.y > MISS_LINE:
			miss_row(target.row_id)
	queue_redraw()


func fire(origin: Vector2) -> void:
	if finished or is_paused:
		return
	for offset in player.formation():
		var projectile = PROJECTILE_SCENE.instantiate()
		projectile.position = origin + offset
		projectiles.add_child(projectile)


func advance_projectiles(delta: float) -> void:
	for shot in projectiles.get_children():
		if shot.is_queued_for_deletion():
			continue
		var previous: Vector2 = shot.position
		shot.position.y -= shot.SPEED * delta
		var nearest = null
		var nearest_y: float = -INF
		for target in targets.get_children():
			if target.resolved:
				continue
			var rect: Rect2 = target.bounds().grow(shot.RADIUS)
			if previous.x >= rect.position.x and previous.x <= rect.end.x:
				if previous.y >= rect.position.y and shot.position.y <= rect.end.y:
					if target.position.y > nearest_y:
						nearest = target
						nearest_y = target.position.y
		if nearest != null:
			resolve_target(nearest)
			shot.queue_free()
		elif shot.position.y < 190.0:
			shot.queue_free()


func spawn_wave() -> void:
	if finished:
		return
	var row_id: int = spawned_waves
	var choices: Array = director.choices(row_id)
	active_rows[row_id] = true
	for index in range(choices.size()):
		var target = TARGET_SCENE.instantiate()
		target.row_id = row_id
		target.operation = choices[index][0]
		target.operand = choices[index][1]
		target.health = director.enemy_health(target.operation, row_id)
		target.max_health = target.health
		var lane: int = index * 2 if choices.size() == 2 else index
		target.position = Vector2(director.LANES[lane], 240)
		targets.add_child(target)
	spawned_waves += 1


func resolve_target(target: Node2D) -> void:
	if finished or target.resolved or not active_rows.has(target.row_id):
		return
	target.health -= 1
	target.hit_flash = 0.12
	target.queue_redraw()
	if target.health > 0:
		return
	var before: int = charge
	charge = clampi(RULES.apply(charge, target.operation, target.operand), 1, 24)
	if target.is_enemy():
		hud.feedback.text = "%s détruit" % target.enemy_name()
	else:
		hud.feedback.text = "%d %s = %d avions" % [before, target.display_text(), charge]
	target.resolved = true
	target.hide()
	target.queue_free()
	var remaining: bool = false
	for other in targets.get_children():
		if other.row_id == target.row_id and not other.resolved:
			remaining = true
	if not remaining:
		active_rows.erase(target.row_id)
		resolved_waves += 1
	check_finish()
	refresh_hud()


func miss_row(row_id: int) -> void:
	if finished or not active_rows.has(row_id):
		return
	var collision: bool = false
	for obstacle in targets.get_children():
		if obstacle.row_id == row_id and not obstacle.resolved and obstacle.is_enemy():
			for offset in player.formation():
				if absf(player.position.x + offset.x - obstacle.position.x) < 80:
					collision = true
	if collision:
		lives = maxi(0, lives - 1)
		charge = maxi(1, charge / 2)
		hud.feedback.text = "Impact ! Escadrille divisée par deux"
	close_row(row_id)
	check_finish()
	refresh_hud()


func close_row(row_id: int) -> void:
	active_rows.erase(row_id)
	resolved_waves += 1
	for target in targets.get_children():
		if target.row_id == row_id:
			target.resolved = true
			target.hide()
			target.queue_free()


func check_finish() -> void:
	if lives <= 0:
		finish(false)



func finish(victory: bool) -> void:
	finished = true
	won = victory
	player.active = false
	release_movement()
	var title: String = "NIVEAU TERMINÉ" if won else "FIN DE PARTIE"
	var goal: String = "Vagues traversées : %d" % spawned_waves
	hud.show_message("%s\n\nAvions restants : %d\n%s" % [title, charge, goal], true)
	hud.pause_button.disabled = true


func toggle_fire() -> void:
	if finished or is_paused:
		return
	player.firing_enabled = not player.firing_enabled
	hud.set_firing(player.firing_enabled)


func toggle_pause() -> void:
	if finished:
		return
	is_paused = not is_paused
	get_tree().paused = is_paused
	release_movement()
	hud.pause_button.text = "Reprendre" if is_paused else "Pause"
	if is_paused:
		hud.show_message("PAUSE\n\nP ou Échap pour reprendre", false)
	else:
		hud.clear_message()


func restart() -> void:
	get_tree().paused = false
	is_paused = false
	clear_entities()
	active_rows.clear()
	charge = 1
	lives = 3
	spawned_waves = 0
	resolved_waves = 0
	spawn_cooldown = 0.8
	finished = false
	won = false
	player.position = Vector2(360, 856)
	player.fire_cooldown = 0.0
	player.active = true
	player.firing_enabled = true
	hud.set_firing(true)
	release_movement()
	hud.clear_message()
	hud.pause_button.text = "Pause"
	hud.pause_button.disabled = false
	hud.feedback.text = "Bougez pour viser • tir automatique"
	refresh_hud()


func clear_entities() -> void:
	for container in [targets, projectiles]:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()


func release_movement() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")


func refresh_hud() -> void:
	player.squad_size = charge
	player.queue_redraw()
	hud.update_status(charge, lives, spawned_waves, director.WAVE_COUNT, director.GOAL)


func _draw() -> void:
	# Ocean relief: two layers, restrained palette, clear silhouettes.
	draw_rect(Rect2(48, 202, 624, 746), Color("102a38"))
	for band in range(20):
		var y: float = 204 + band * 37
		draw_line(Vector2(50, y), Vector2(670, y), Color(0.15, 0.35, 0.43, 0.13), 1)
	for island in range(4):
		var y: float = 220 + fmod(island * 225 + scenery_offset, 620)
		var x: float = 55 if island % 2 == 0 else 665
		var side: float = 1 if island % 2 == 0 else -1
		var points := PackedVector2Array([Vector2(x,y-30), Vector2(x+side*35,y-15), Vector2(x+side*60,y+30), Vector2(x+side*32,y+68),Vector2(x,y+90)])
		draw_colored_polygon(points, Color("254a4b"))
		draw_polyline(points, Color("417073"), 3, true)
	for i in range(18):
		var px: float = 100 + fmod(i * 173.0, 520)
		var py: float = 210 + fmod(i * 97.0 + track_offset * 3, 720)
		draw_line(Vector2(px, py), Vector2(px+12, py), Color(0.45, 0.72, 0.76, 0.13), 2)
	for x in [48.0, 672.0]:
		draw_line(Vector2(x, 202), Vector2(x, 948), Color("52727b"), 2)
	for x in [264.0, 456.0]:
		for y in range(9):
			var offset: float = 202 + y * 84 + track_offset
			if offset < 942:
				draw_line(Vector2(x, offset), Vector2(x, minf(offset + 12, 942)), Color(0.5,0.7,0.8,0.10), 1)
	draw_line(Vector2(60, MISS_LINE), Vector2(660, MISS_LINE), Color("cc8563"), 2)
