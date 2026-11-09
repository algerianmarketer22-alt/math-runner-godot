extends RefCounted
## Pure integer arithmetic shared by gameplay and automated tests.

const MAX_VALUE: int = 999999


static func apply(value: int, operation: String, operand: int) -> int:
	var result: int = value
	match operation:
		"+": result += operand
		"-": result -= operand
		"*": result *= operand
		"/":
			if operand != 0:
				result = floori(float(value) / float(operand))
	return clampi(result, 0, MAX_VALUE)
