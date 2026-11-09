extends SceneTree

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	if not FileAccess.file_exists("res://scripts/math_rules.gd"):
		check(false, "Le module de calcul doit exister")
		quit(1)
		return
	var rules = load("res://scripts/math_rules.gd").new()
	check(rules.apply(10, "+", 5) == 15, "+5")
	check(rules.apply(10, "*", 2) == 20, "×2")
	check(rules.apply(10, "+", 10) == 20, "+10")
	check(rules.apply(20, "-", 5) == 15, "Malus −5")
	check(rules.apply(3, "-", 10) == 0, "Pas de charge négative")
	check(rules.apply(15, "/", 2) == 7, "Division entière")
	check(rules.apply(500000, "*", 2) == 999999, "Plafond de charge")
	check(rules.apply(10, "/", 0) == 10, "Division nulle ignorée")
	check(rules.apply(10, "?", 5) == 10, "Opération inconnue ignorée")
	check(rules.apply(rules.apply(10, "+", 5), "*", 2) == 30, "Ordre des opérations")
	check(rules.apply(4, "+", 10) > rules.apply(4, "*", 2), "Addition utile à faible charge")
	check(rules.apply(25, "*", 2) > rules.apply(25, "+", 10), "Multiplication utile à forte charge")
	print("Calcul : %d vérifications, %d échecs" % [checks, failures])
	quit(1 if failures else 0)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
