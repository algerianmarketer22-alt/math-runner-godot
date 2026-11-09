extends RefCounted
## Deterministic introductory level: reproducible gameplay and tests.

const WAVE_COUNT: int = 18
const GOAL: int = 200
const LANES: Array[float] = [168.0, 360.0, 552.0]
const PATTERNS: Array = [
	[["+", 5], ["+", 10]],
	[["+", 10], ["*", 2]],
	[["-", 5], ["+", 5], ["+", 10]],
	[["*", 2], ["+", 10], ["/", 2]],
	[["+", 5], ["-", 10], ["*", 2]],
	[["/", 2], ["+", 10], ["-", 5]],
]


func scroll_speed(wave_index: int) -> float:
	return 140.0 + clampi(wave_index, 0, WAVE_COUNT - 1) * 6.0


func spawn_interval(wave_index: int) -> float:
	return 3.2 - clampi(wave_index, 0, WAVE_COUNT - 1) * 0.065


func choices(wave_index: int) -> Array:
	var pattern: Array = PATTERNS[wave_index % PATTERNS.size()].duplicate(true)
	if wave_index >= 6:
		# Rotate lanes without randomizing the level.
		for rotation in range(wave_index % pattern.size()):
			pattern.push_back(pattern.pop_front())
	return pattern

