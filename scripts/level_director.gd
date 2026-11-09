extends RefCounted
const WAVE_COUNT: int = 18
const GOAL: int = 200
const LANES: Array[float] = [168.0, 360.0, 552.0]

func scroll_speed(wave_index: int) -> float:
	return minf(165.0, 65.0 + wave_index * 1.8)

func spawn_interval(wave_index: int) -> float:
	return maxf(2.4, 4.8 - wave_index * 0.045)

func enemy_health(kind: String, wave_index: int) -> int:
	var base: int = {"rock": 3, "scout": 3, "armor": 9, "carrier": 18}.get(kind, 0)
	if base == 0:
		return 1
	return base + wave_index / 4 * (2 if kind == "scout" else 4)

func choices(wave_index: int) -> Array:
	var tier: int = wave_index / 6
	var addition: int = 2 + (wave_index * 3 + tier) % 7
	var subtraction: int = 1 + (wave_index + tier) % mini(10, 3 + tier)
	var multiplier: int = 2 + tier % 3
	var divisor: int = 2 + (tier + wave_index / 3) % 3
	var enemy: String = "scout"
	if wave_index >= 4:
		enemy = ["scout", "armor", "carrier"][wave_index % 3]
	var patterns: Array = [
		[["+", addition], [enemy, 0], ["+", 3 + tier % 8]],
		[[enemy, 0], ["*", multiplier], ["-", subtraction]],
		[["/", divisor], [enemy, 0], ["+", addition]],
		[[enemy, 0], ["-", subtraction], ["*", multiplier]],
		[["+", addition], ["/", divisor], [enemy, 0]],
	]
	if wave_index == 0:
		return [["+", 5], ["scout", 0], ["+", 2]]
	return patterns[wave_index % patterns.size()]
