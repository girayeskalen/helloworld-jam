class_name KarneReveal
extends RefCounted
## Presentation-only clock shared by the card screen and the outcome HUD.
signal row_revealed(ok: bool)
const DELAY: float = .2
const STEP: float = .22
const SLIDE: float = .18
var clock: float = 0.0
var revealed: int = 0

func reset() -> void:
	clock = 0.0
	revealed = 0

func advance(delta: float, rows: Array[Dictionary]) -> void:
	clock += delta
	while revealed < rows.size() and clock + .000001 >= DELAY + revealed * STEP:
		var index: int = revealed
		revealed += 1
		row_revealed.emit(rows[index]["ok"])

func progress(index: int) -> float:
	return smoothstep(0, SLIDE, clock - DELAY - index * STEP)

func hint_progress(count: int) -> float:
	var after: float = maxf(.25, DELAY + (count - 1) * STEP + SLIDE)
	return smoothstep(0, SLIDE, clock - after)
