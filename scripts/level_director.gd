extends RefCounted
## Deterministic introductory level: reproducible gameplay and tests.

const WAVE_COUNT: int = 18
const GOAL: int = 200
const LANES: Array[float] = [168.0, 360.0, 552.0]
const PATTERNS: Array = [
	[["+", 5], ["rock", 0], ["+", 2]],
	[["rock", 0], ["*", 2], ["rock", 0]],
	[["+", 5], ["rock", 0], ["/", 2]],
	[["rock", 0], ["rock", 0], ["+", 10]],
	[["*", 2], ["-", 5], ["rock", 0]],
]



func scroll_speed(wave_index: int) -> float:
	return minf(340.0, 100.0 + wave_index * 5.0)


func spawn_interval(wave_index: int) -> float:
	return maxf(1.15, 3.4 - wave_index * 0.055)


func choices(wave_index: int) -> Array:
	var pattern: Array = PATTERNS[wave_index % PATTERNS.size()].duplicate(true)
	if wave_index >= 6:
		# Rotate lanes without randomizing the level.
		for rotation in range(wave_index % pattern.size()):
			pattern.push_back(pattern.pop_front())
	return pattern

