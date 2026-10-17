class_name CharacterArt
extends RefCounted
## Feet are at the origin. Facing/roll/lean/squash transforms never touch the hitbox.
## pose keys (all optional): scale: Vector2, lean: float, air: float (0..1),
## cape: Vector2 (trailing tip offset in world space), clock: float.

static func draw_avatar(canvas: CanvasItem, feet: Vector2, phase: float, facing: float, roll: float, tint: Color = Color.WHITE, pose: Dictionary = {}) -> void:
	var stretch: Vector2 = pose.get("scale", Vector2.ONE)
	var lean: float = pose.get("lean", 0.0)
	var air: float = pose.get("air", 0.0)
	var clock: float = pose.get("clock", 0.0)
	var cape: Vector2 = pose.get("cape", Vector2(-8, 14))
	var sway: float = sin(phase)
	var knee: float = cos(phase)
	# Squash/stretch pivots on the feet so landing compresses into the floor.
	var center: Vector2 = feet + Vector2(0, -34.0 * stretch.y).rotated(lean)
	canvas.draw_set_transform(center, roll * TAU * facing + lean, Vector2(facing * stretch.x, stretch.y))
	if tint.a < 0.99:
		# A readable cel silhouette, not a glowing rectangle.
		CelArt.ellipse(canvas, Vector2(0, -18), Vector2(22, 21), tint, 0)
		CelArt.poly(canvas, PackedVector2Array([Vector2(-15, 3), Vector2(14, 3), Vector2(15, 22), Vector2(7, 33), Vector2(-13, 33)]), tint, 0)
		canvas.draw_set_transform(Vector2.ZERO)
		return
	# Cape trails behind (local -x is always "behind" after the facing flip).
	var tip: Vector2 = Vector2(cape.x * facing, cape.y) + Vector2(-6, 0)
	var flutter: float = sin(clock * 17.0 + phase) * 3.0
	CelArt.poly(canvas, PackedVector2Array([Vector2(-12, -2), Vector2(2, -1), Vector2(-4 + tip.x * 0.5, 18 + tip.y * 0.6 + flutter), Vector2(-14 + tip.x, 20 + tip.y + flutter), Vector2(-16 + tip.x * 0.6, 10 + tip.y * 0.4)]), Color("6b2622"))
	CelArt.line(canvas, Vector2(-10, 2), Vector2(-12 + tip.x * 0.8, 18 + tip.y * 0.8 + flutter), Color("8f3a30"), 2)
	# Legs: stride on the ground, tucked knees in the air.
	var tuck: float = air * 12.0
	_leg(canvas, Vector2(-8, 19), Vector2(-8 - sway * 10 * (1.0 - air) + air * 4.0, 32 - absf(sway) * 3 - tuck), Color("33434a"))
	_leg(canvas, Vector2(7, 19), Vector2(9 + sway * 11 * (1.0 - air) + air * 8.0, 32 - absf(knee) * 2 - tuck * 1.2), Color("4a5d60"))
	var arm_lift: float = air * 20.0
	CelArt.line(canvas, Vector2(-12, 2), Vector2(-19 + sway * 6, 18 - arm_lift), CelArt.INK, 10)
	CelArt.line(canvas, Vector2(-12, 2), Vector2(-19 + sway * 6, 18 - arm_lift), Color("5d7470"), 5)
	# Backpack is visible behind the shoulder.
	CelArt.box(canvas, Rect2(-21, -1, 12, 22), Color("4d5c41"), Vector2(3, -2))
	CelArt.poly(canvas, PackedVector2Array([Vector2(-13, -1), Vector2(11, -1), Vector2(16, 19), Vector2(-13, 20)]), Color("c4823c"))
	CelArt.poly(canvas, PackedVector2Array([Vector2(4, 0), Vector2(11, -1), Vector2(16, 19), Vector2(5, 20)]), Color("8f5c31"), 0)
	CelArt.line(canvas, Vector2(-5, 0), Vector2(-5, 19), Color("d6d2b8"), 4)
	CelArt.line(canvas, Vector2(9, 0), Vector2(9, 18), Color("d6d2b8"), 3)
	CelArt.rect(canvas, Rect2(-11, 17, 25, 6), Color("27383c"))
	CelArt.bolt(canvas, Vector2(2, 20), Color("e8c781"))
	var hand: Vector2 = Vector2(19 - sway * 7, 17 - arm_lift * 1.2)
	CelArt.line(canvas, Vector2(12, 2), hand, CelArt.INK, 10)
	CelArt.line(canvas, Vector2(12, 2), hand, Color("8a9a88"), 5)
	CelArt.ellipse(canvas, hand + Vector2(0, 1), Vector2(5, 5), Color("c49270"))
	# Large chibi head, shaded cheek and individual hair locks.
	CelArt.ellipse(canvas, Vector2(1, -17), Vector2(21, 21), Color("d2a27a"))
	CelArt.poly(canvas, PackedVector2Array([Vector2(14, -29), Vector2(21, -22), Vector2(18, -6), Vector2(7, 2), Vector2(8, -7)]), Color("a77756"), 0)
	CelArt.ellipse(canvas, Vector2(-19, -16), Vector2(5, 7), Color("bd8a66"))
	CelArt.poly(canvas, PackedVector2Array([Vector2(-18, -20), Vector2(-22, -28), Vector2(-13, -37), Vector2(5, -39), Vector2(20, -30), Vector2(15, -22), Vector2(8, -27), Vector2(1, -23), Vector2(-7, -28), Vector2(-12, -16)]), Color("2f2a25"))
	# Chin strap flutters with speed and time.
	var strap: float = sin(clock * 21.0 + phase * 0.5) * 3.0
	CelArt.line(canvas, Vector2(-18, -28), Vector2(-24 - absf(sway) * 4.0, -8 + strap), Color("3a2f26"), 2.5)
	# Rescue helmet with lip, front plate and the lamp that casts the beam.
	CelArt.poly(canvas, PackedVector2Array([Vector2(-22, -30), Vector2(-17, -43), Vector2(-7, -48), Vector2(11, -46), Vector2(21, -38), Vector2(23, -29)]), Color("e0a940"))
	CelArt.poly(canvas, PackedVector2Array([Vector2(8, -46), Vector2(21, -38), Vector2(23, -29), Vector2(9, -30)]), Color("a06f32"), 0)
	CelArt.rect(canvas, Rect2(-25, -31, 51, 7), Color("eabb62"))
	CelArt.rect(canvas, Rect2(-6, -42, 13, 11), Color("d8d2b0"), 1.5)
	CelArt.line(canvas, Vector2(-3, -36), Vector2(4, -36), Color("8a2a22"), 2)
	CelArt.line(canvas, Vector2(0, -39), Vector2(0, -33), Color("8a2a22"), 2)
	CelArt.rect(canvas, Rect2(17, -42, 8, 8), Color("2a2f30"), 1.5)
	CelArt.rect(canvas, Rect2(19, -40, 5, 4), Color("fff1c4"), 0)
	CelArt.rect(canvas, Rect2(3, -19, 4, 6), CelArt.INK, 0)
	CelArt.rect(canvas, Rect2(14, -18, 3, 5), CelArt.INK, 0)
	CelArt.line(canvas, Vector2(10, -12), Vector2(14, -11), Color("8d5743"), 2)
	CelArt.line(canvas, Vector2(5, -5), Vector2(12, -4), Color("5f4237"), 2)
	canvas.draw_set_transform(Vector2.ZERO)

static func _leg(canvas: CanvasItem, hip: Vector2, foot: Vector2, color: Color) -> void:
	CelArt.line(canvas, hip, foot, CelArt.INK, 11)
	CelArt.line(canvas, hip, foot, color, 6)
	CelArt.poly(canvas, PackedVector2Array([foot + Vector2(-5, -3), foot + Vector2(5, -3), foot + Vector2(9, 2), foot + Vector2(9, 5), foot + Vector2(-5, 5)]), Color("262c29"))
	CelArt.line(canvas, foot + Vector2(-3, 4), foot + Vector2(7, 4), Color("8b8d78"), 2)
