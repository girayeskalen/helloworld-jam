class_name FurnitureArt
extends RefCounted
## Authored procedural furniture. Local coordinates are a 100 x 100 design sheet.
## Each owner remains a stateful BuildingProp with its own sprite override.

static func draw_furniture(c: CanvasItem, kind: BuildingProp.Kind, size: Vector2, palette: Color) -> void:
	c.draw_set_transform(Vector2(-size.x * 0.5, -size.y), 0, size / 100.0)
	var ink: Color = CelArt.INK
	var cream: Color = Color("d7d0ae")
	var steel: Color = Color("839b99")
	var wood: Color = Color("ab7951")
	match kind:
		BuildingProp.Kind.WORKBENCH:
			CelArt.box(c, Rect2(5, 0, 87, 44), Color("586b6a"), Vector2(5, -3))
			for i: int in range(6):
				var x: float = 14 + i * 13
				CelArt.line(c, Vector2(x, 9), Vector2(x, 31), cream, 4)
				CelArt.ellipse(c, Vector2(x, 8), Vector2(4, 5), steel, 1.5)
			for x: float in [9.0, 83.0]:
				CelArt.box(c, Rect2(x, 54, 8, 46), steel, Vector2(4, -4))
			CelArt.box(c, Rect2(0, 48, 96, 10), wood, Vector2(6, -6))
			CelArt.box(c, Rect2(66, 37, 18, 10), steel, Vector2(5, -4))
			CelArt.line(c, Vector2(76, 34), Vector2(76, 50), ink, 3)
			CelArt.rect(c, Rect2(23, 43, 28, 5), Color("dfb963"))
		BuildingProp.Kind.TOOL_CABINET:
			CelArt.box(c, Rect2(0, 0, 91, 97), steel, Vector2(9, -5))
			for i: int in range(5):
				CelArt.rect(c, Rect2(8, 8 + i * 17, 75, 14), Color("526a6a"))
				CelArt.line(c, Vector2(33, 14 + i * 17), Vector2(59, 14 + i * 17), cream, 3)
			for x: float in [12.0, 80.0]:
				CelArt.ellipse(c, Vector2(x, 98), Vector2(5, 3), ink)
			CelArt.rect(c, Rect2(12, 88, 30, 5), CelArt.GOLD, 1)
		BuildingProp.Kind.TOOLBOX:
			CelArt.rect(c, Rect2(30, 8, 40, 20), ink)
			CelArt.rect(c, Rect2(37, 15, 26, 9), steel, 1)
			CelArt.box(c, Rect2(0, 30, 94, 67), Color("b45e46"), Vector2(6, -12))
			CelArt.rect(c, Rect2(0, 43, 94, 9), Color("d89962"))
			for x: float in [21.0, 72.0]:
				CelArt.rect(c, Rect2(x, 39, 7, 22), steel)
		BuildingProp.Kind.FRIDGE:
			CelArt.box(c, Rect2(0, 0, 89, 97), Color("bfcec2"), Vector2(11, -6))
			CelArt.rect(c, Rect2(6, 5, 78, 31), Color("dce0c9"))
			CelArt.rect(c, Rect2(6, 39, 78, 52), Color("d2d9c4"))
			for y: float in [23.0, 47.0]:
				CelArt.line(c, Vector2(70, y), Vector2(70, y + 12), ink, 4)
			CelArt.rect(c, Rect2(18, 51, 19, 18), Color("d79774"), 1.5)
			CelArt.line(c, Vector2(22, 55), Vector2(32, 55), cream, 2)
		BuildingProp.Kind.STOVE:
			CelArt.box(c, Rect2(0, 18, 93, 78), cream, Vector2(7, -14))
			for x: float in [20.0, 65.0]:
				CelArt.ellipse(c, Vector2(x, 15), Vector2(12, 6), ink)
				CelArt.ellipse(c, Vector2(x, 15), Vector2(7, 3), steel, 1)
			CelArt.rect(c, Rect2(12, 48, 70, 39), Color("344e56"))
			CelArt.rect(c, Rect2(20, 56, 53, 23), Color("536f70"), 1)
			CelArt.line(c, Vector2(15, 44), Vector2(78, 44), ink, 4)
			for i: int in range(4):
				CelArt.ellipse(c, Vector2(15 + i * 20, 30), Vector2(4, 4), ink)
			CelArt.box(c, Rect2(12, -1, 24, 15), Color("536b70"), Vector2(3, -4))
			CelArt.ellipse(c, Vector2(25, -5), Vector2(13, 4), steel)
			CelArt.line(c, Vector2(6, 3), Vector2(12, 3), ink, 4)
			CelArt.line(c, Vector2(37, 3), Vector2(43, 3), ink, 4)
		BuildingProp.Kind.HOOD:
			CelArt.box(c, Rect2(38, 0, 26, 52), steel, Vector2(5, -4))
			CelArt.poly(c, PackedVector2Array([Vector2(24, 44), Vector2(76, 44), Vector2(100, 90), Vector2(0, 90)]), Color("aabcb0"))
			CelArt.rect(c, Rect2(2, 89, 96, 10), Color("435a5b"))
			for i: int in range(6):
				CelArt.line(c, Vector2(18 + i * 12, 78), Vector2(23 + i * 10, 87), ink, 2)
		BuildingProp.Kind.SHELF, BuildingProp.Kind.TOY_SHELF:
			CelArt.box(c, Rect2(0, 0, 92, 97), wood.darkened(0.15), Vector2(8, -5))
			for row: int in range(3):
				CelArt.rect(c, Rect2(5, 5 + row * 30, 80, 25), Color("544f44"), 1.5)
				for i: int in range(4):
					var p: Vector2 = Vector2(15 + i * 19, 22 + row * 30)
					if kind == BuildingProp.Kind.SHELF:
						CelArt.ellipse(c, p, Vector2(7, 6), cream, 1.4)
						CelArt.ellipse(c, p, Vector2(4, 3), steel, 1)
					else:
						CelArt.box(c, Rect2(p - Vector2(6, 11), Vector2(12, 14)), Color.from_hsv(fmod(i * .21 + row * .12, 1), .35, .78), Vector2(3, -3))
		BuildingProp.Kind.TV:
			CelArt.box(c, Rect2(2, 69, 90, 26), wood, Vector2(8, -6))
			CelArt.rect(c, Rect2(40, 42, 10, 29), ink)
			CelArt.rect(c, Rect2(0, 0, 96, 58), Color("273b42"))
			CelArt.rect(c, Rect2(6, 6, 84, 43), Color("558b94"), 1)
			CelArt.poly(c, PackedVector2Array([Vector2(8, 45), Vector2(35, 18), Vector2(59, 42), Vector2(88, 27), Vector2(88, 48)]), Color("8caaa0"), 0)
			CelArt.line(c, Vector2(12, 82), Vector2(82, 82), ink, 2)
		BuildingProp.Kind.COFFEE_TABLE:
			for x: float in [14.0, 79.0]:
				CelArt.box(c, Rect2(x, 50, 7, 45), wood.darkened(.3), Vector2(4, -6))
			CelArt.box(c, Rect2(1, 27, 91, 27), wood, Vector2(8, -21))
			CelArt.box(c, Rect2(21, 12, 30, 9), Color("658f84"), Vector2(3, -5))
			CelArt.ellipse(c, Vector2(68, 24), Vector2(8, 8), cream)
		BuildingProp.Kind.COMPUTER:
			for x: float in [8.0, 82.0]:
				CelArt.rect(c, Rect2(x, 64, 7, 36), steel)
			CelArt.box(c, Rect2(0, 57, 94, 10), wood, Vector2(6, -8))
			for x: float in [3.0, 50.0]:
				CelArt.rect(c, Rect2(x + 18, 36, 6, 20), ink)
				CelArt.box(c, Rect2(x, 1, 43, 39), Color("273e48"), Vector2(3, -3))
				CelArt.rect(c, Rect2(x + 4, 6, 34, 27), Color("65a49d"), 1)
				for i: int in range(4):
					CelArt.line(c, Vector2(x + 8, 11 + i * 5), Vector2(x + 20 + i * 4, 11 + i * 5), cream, 1.5)
			CelArt.box(c, Rect2(29, 49, 37, 5), cream, Vector2(3, -3))
		BuildingProp.Kind.SWIVEL_CHAIR:
			CelArt.line(c, Vector2(50, 65), Vector2(50, 92), ink, 6)
			for x: float in [10.0, 50.0, 90.0]:
				CelArt.line(c, Vector2(50, 88), Vector2(x, 96), ink, 4)
				CelArt.ellipse(c, Vector2(x, 97), Vector2(5, 3), steel)
			CelArt.box(c, Rect2(18, 0, 64, 47), Color("42767a"), Vector2(5, -4))
			CelArt.box(c, Rect2(9, 53, 80, 13), Color("64948c"), Vector2(7, -9))
			for x: float in [7.0, 86.0]:
				CelArt.line(c, Vector2(x, 41), Vector2(x, 59), ink, 4)
		BuildingProp.Kind.CORKBOARD:
			CelArt.box(c, Rect2(0, 0, 96, 94), wood, Vector2(4, -4))
			CelArt.rect(c, Rect2(6, 6, 84, 82), Color("b99467"), 1.5)
			for i: int in range(5):
				var p: Vector2 = Vector2(12 + i % 3 * 26, 12 + i / 3 * 37)
				CelArt.rect(c, Rect2(p, Vector2(21, 28)), cream, 1)
				c.draw_circle(p + Vector2(10, 3), 2.2, Color("ba5e49"))
		BuildingProp.Kind.BED:
			CelArt.box(c, Rect2(0, 7, 94, 43), wood, Vector2(6, -5))
			CelArt.box(c, Rect2(1, 53, 92, 40), palette, Vector2(6, -24))
			CelArt.poly(c, PackedVector2Array([Vector2(7, 30), Vector2(85, 30), Vector2(94, 67), Vector2(2, 67)]), palette.lightened(0.25))
			for x: float in [15.0, 53.0]:
				CelArt.box(c, Rect2(x, 22, 28, 15), cream, Vector2(3, -5))
			CelArt.rect(c, Rect2(2, 67, 92, 13), Color("d0ae81"))
			for x: float in [10.0, 81.0]:
				CelArt.rect(c, Rect2(x, 92, 8, 8), wood)
		BuildingProp.Kind.NIGHTSTAND:
			CelArt.box(c, Rect2(2, 53, 89, 43), wood, Vector2(9, -9))
			CelArt.rect(c, Rect2(10, 62, 72, 22), Color("bc9261"))
			CelArt.ellipse(c, Vector2(46, 72), Vector2(4, 3), cream)
			CelArt.line(c, Vector2(47, 14), Vector2(47, 49), ink, 4)
			CelArt.poly(c, PackedVector2Array([Vector2(30, 2), Vector2(64, 2), Vector2(77, 28), Vector2(18, 28)]), Color("e8c483"))
			CelArt.ellipse(c, Vector2(47, 48), Vector2(17, 4), Color("b49b67"))
			c.draw_circle(Vector2(47, 24), 35, Color(1, .73, .32, .04))
		BuildingProp.Kind.WARDROBE:
			CelArt.box(c, Rect2(0, 1, 91, 96), Color("725c59"), Vector2(9, -5))
			for x: float in [6.0, 48.0]:
				CelArt.rect(c, Rect2(x, 7, 37, 83), Color("ac8d78"))
				CelArt.rect(c, Rect2(x + 5, 13, 27, 66), Color("bd9f84"), 1)
			CelArt.line(c, Vector2(38, 43), Vector2(38, 54), ink, 3)
			CelArt.line(c, Vector2(55, 43), Vector2(55, 54), ink, 3)
		BuildingProp.Kind.CURTAINS:
			CelArt.line(c, Vector2(0, 0), Vector2(100, 0), wood, 5)
			for side: int in range(2):
				var x: float = side * 75
				CelArt.poly(c, PackedVector2Array([Vector2(x, 3), Vector2(x + 25, 3), Vector2(x + 15, 57), Vector2(x + 25, 96), Vector2(x, 96)]), Color("8d7382"))
				for i: int in range(3):
					CelArt.line(c, Vector2(x + 4 + i * 6, 7), Vector2(x + 3 + i * 4, 91), Color("b79aa3"), 1.4)
		BuildingProp.Kind.BUNK_BED:
			for x: float in [1.0, 89.0]:
				CelArt.box(c, Rect2(x, 0, 7, 99), Color("c39c60"), Vector2(4, -3))
			for y: float in [31.0, 82.0]:
				CelArt.box(c, Rect2(5, y, 83, 10), Color("6e9a98"), Vector2(7, -11))
				CelArt.rect(c, Rect2(8, y - 14, 74, 6), Color("c5ac75"))
				CelArt.box(c, Rect2(13, y - 13, 21, 8), cream, Vector2(3, -3))
			for x: float in [64.0, 83.0]:
				CelArt.line(c, Vector2(x, 25), Vector2(x, 99), ink, 3)
			for i: int in range(6):
				CelArt.line(c, Vector2(64, 32 + i * 12), Vector2(83, 32 + i * 12), cream, 3)
		BuildingProp.Kind.AIRCON:
			CelArt.box(c, Rect2(0, 0, 93, 92), Color("c1cfc4"), Vector2(7, -7))
			for i: int in range(4):
				CelArt.line(c, Vector2(10, 46 + i * 11), Vector2(83, 46 + i * 11), Color("587b7c"), 3)
			CelArt.rect(c, Rect2(70, 16, 15, 11), Color("6b9c8b"))
		BuildingProp.Kind.POSTER:
			CelArt.rect(c, Rect2(0, 0, 96, 96), cream)
			CelArt.rect(c, Rect2(7, 7, 82, 82), palette, 1)
			CelArt.poly(c, PackedVector2Array([Vector2(10, 83), Vector2(41, 22), Vector2(62, 60), Vector2(88, 37), Vector2(88, 87)]), palette.lightened(.3), 1)
			c.draw_circle(Vector2(72, 24), 10, CelArt.GOLD)
		BuildingProp.Kind.SKYLIGHT:
			CelArt.poly(c, PackedVector2Array([Vector2(15, 0), Vector2(84, 0), Vector2(100, 94), Vector2(0, 94)]), Color("426779"))
			CelArt.line(c, Vector2(50, 3), Vector2(50, 91), cream, 4)
			CelArt.line(c, Vector2(9, 46), Vector2(91, 46), cream, 4)
			CelArt.line(c, Vector2(25, 9), Vector2(12, 36), Color("94b8bb"), 3)
		BuildingProp.Kind.FIRE_CABINET:
			CelArt.box(c, Rect2(0, 0, 90, 98), Color("b65343"), Vector2(10, -5))
			CelArt.rect(c, Rect2(7, 7, 76, 81), Color("633e3c"))
			CelArt.ellipse(c, Vector2(44, 39), Vector2(27, 25), cream)
			CelArt.ellipse(c, Vector2(44, 39), Vector2(15, 14), Color("b65343"))
			CelArt.box(c, Rect2(34, 58, 20, 28), Color("db7b53"), Vector2(3, -3))
			CelArt.line(c, Vector2(44, 54), Vector2(62, 54), ink, 4)
		BuildingProp.Kind.VENT_MOTOR:
			CelArt.box(c, Rect2(2, 4, 86, 90), steel, Vector2(12, -5))
			CelArt.ellipse(c, Vector2(45, 46), Vector2(33, 32), Color("2d454b"))
			for i: int in range(6):
				var d: Vector2 = Vector2.from_angle(i * TAU / 6)
				CelArt.line(c, Vector2(45, 46) + d * 8, Vector2(45, 46) + d.rotated(.4) * 26, cream, 7)
			CelArt.ellipse(c, Vector2(45, 46), Vector2(8, 8), steel)
			for i: int in range(3):
				CelArt.line(c, Vector2(22 + i * 21, 3), Vector2(22 + i * 21, -13), ink, 4)
		BuildingProp.Kind.CHANDELIER:
			CelArt.line(c, Vector2(50, 0), Vector2(50, 62), ink, 4)
			for i: int in range(5):
				var p: Vector2 = Vector2(9 + i * 20, 72 + absf(i - 2) * 4)
				CelArt.line(c, Vector2(50, 49), p, ink, 5)
				CelArt.line(c, Vector2(50, 49), p, CelArt.GOLD, 2.5)
				CelArt.poly(c, PackedVector2Array([p + Vector2(-9, -10), p + Vector2(9, -10), p + Vector2(7, 8), p + Vector2(-7, 8)]), Color("efca88"))
				c.draw_circle(p, 18, Color(1, .74, .3, .045))
		_:
			_draw_room_set(c, kind, palette)
	c.draw_set_transform(Vector2.ZERO)

## 4x4 apartment expansion: boiler, lobby, laundry, dining, music, bath, guest,
## greenhouse, gym, studio and roof-plant furniture on the same 100 x 100 sheet.
static func _draw_room_set(c: CanvasItem, kind: BuildingProp.Kind, palette: Color) -> void:
	var ink: Color = CelArt.INK
	var cream: Color = Color("d7d0ae")
	var steel: Color = Color("839b99")
	var wood: Color = Color("ab7951")
	var custom: bool = not palette.is_equal_approx(Color("ad7655"))
	match kind:
		BuildingProp.Kind.BOILER:
			CelArt.line(c, Vector2(30, 0), Vector2(30, 14), ink, 9)
			CelArt.line(c, Vector2(30, 0), Vector2(30, 14), steel, 4)
			CelArt.line(c, Vector2(86, 30), Vector2(100, 30), ink, 8)
			CelArt.line(c, Vector2(86, 30), Vector2(100, 30), Color("c7a95f"), 4)
			CelArt.box(c, Rect2(8, 12, 78, 80), Color("b8674a"), Vector2(8, -6))
			for y: float in [28.0, 54.0, 80.0]:
				CelArt.line(c, Vector2(11, y), Vector2(83, y), Color("8d4b37"), 3)
			c.draw_circle(Vector2(47, 40), 12, ink)
			c.draw_circle(Vector2(47, 40), 9, cream)
			CelArt.line(c, Vector2(47, 40), Vector2(53, 34), Color("b65343"), 2)
			CelArt.rect(c, Rect2(30, 60, 34, 14), Color("3b4a47"))
			for i: int in range(3):
				c.draw_circle(Vector2(37 + i * 10, 67), 2.6, CelArt.GOLD if i < 2 else Color("ed8065"))
			CelArt.rect(c, Rect2(4, 92, 90, 8), Color("4c5652"))
		BuildingProp.Kind.MAILBOXES:
			CelArt.box(c, Rect2(0, 4, 96, 92), Color("8c7b5a"), Vector2(5, -4))
			for row: int in range(3):
				for column: int in range(4):
					var p: Vector2 = Vector2(6 + column * 22.5, 11 + row * 28)
					CelArt.rect(c, Rect2(p, Vector2(19, 24)), Color("c4b083") if (row + column) % 3 != 0 else Color("a9b6a0"), 1.5)
					CelArt.line(c, p + Vector2(4, 6), p + Vector2(15, 6), ink, 2)
					c.draw_circle(p + Vector2(14, 17), 2.0, ink)
			CelArt.rect(c, Rect2(26, 92, 44, 6), CelArt.GOLD, 1)
		BuildingProp.Kind.ENTRY_DOOR:
			CelArt.box(c, Rect2(0, 0, 96, 100), Color("6e5a48"), Vector2(6, -5))
			CelArt.rect(c, Rect2(6, 5, 84, 15), Color("d9c79a"), 1.5)
			CelArt.rect(c, Rect2(30, 8, 36, 9), Color("4f9a6f"), 1)
			for x: float in [7.0, 50.0]:
				CelArt.rect(c, Rect2(x, 23, 39, 73), Color("4f7884"))
				CelArt.poly(c, PackedVector2Array([Vector2(x + 4, 28), Vector2(x + 22, 28), Vector2(x + 4, 66)]), Color("79a6a3"), 0)
				CelArt.rect(c, Rect2(x, 84, 39, 12), Color("8a7a63"), 1.5)
			CelArt.line(c, Vector2(42, 52), Vector2(42, 64), CelArt.GOLD, 4)
			CelArt.line(c, Vector2(55, 52), Vector2(55, 64), CelArt.GOLD, 4)
			CelArt.poly(c, PackedVector2Array([Vector2(10, 96), Vector2(86, 96), Vector2(96, 100), Vector2(0, 100)]), Color("a64f3e"), 1.5)
		BuildingProp.Kind.WASHER:
			var body: Color = palette if custom else Color("d8dccd")
			CelArt.box(c, Rect2(2, 6, 90, 92), body, Vector2(8, -6))
			CelArt.rect(c, Rect2(7, 11, 80, 16), body.darkened(0.18), 1.5)
			for i: int in range(3):
				c.draw_circle(Vector2(18 + i * 13, 19), 3.5, ink)
			CelArt.rect(c, Rect2(60, 15, 22, 8), Color("8fd3c0"), 1)
			c.draw_circle(Vector2(47, 62), 29, ink)
			c.draw_circle(Vector2(47, 62), 24, steel)
			c.draw_circle(Vector2(47, 62), 19, Color("6f9ea8"))
			c.draw_arc(Vector2(47, 62), 11, 0.3, 3.4, 12, cream, 3, true)
			CelArt.line(c, Vector2(31, 50), Vector2(39, 45), Color("c4e0dc"), 3)
		BuildingProp.Kind.VITRINE:
			CelArt.box(c, Rect2(0, 0, 92, 98), Color("7a4e3a"), Vector2(8, -6))
			CelArt.rect(c, Rect2(7, 7, 78, 58), Color("8fb6b4"))
			for y: float in [27.0, 46.0]:
				CelArt.rect(c, Rect2(7, y, 78, 3), Color("c49a6c"), 0)
			for row: int in range(3):
				for i: int in range(4):
					var p: Vector2 = Vector2(17 + i * 19, 23 + row * 19)
					if row == 1:
						CelArt.rect(c, Rect2(p - Vector2(4, 9), Vector2(9, 9)), cream, 1.2)
					else:
						CelArt.ellipse(c, p - Vector2(0, 7), Vector2(7, 7), cream if i % 2 == 0 else Color("a9c7d4"), 1.2)
			CelArt.line(c, Vector2(46, 7), Vector2(46, 65), ink, 2.5)
			CelArt.poly(c, PackedVector2Array([Vector2(10, 10), Vector2(26, 10), Vector2(10, 40)]), Color(1, 1, 1, 0.22), 0)
			for x: float in [7.0, 48.0]:
				CelArt.rect(c, Rect2(x, 70, 37, 24), Color("9a6a4c"))
				c.draw_circle(Vector2(x + 30.0 if x < 40.0 else x + 7.0, 82), 2.2, CelArt.GOLD)
		BuildingProp.Kind.DINING_TABLE:
			for x: float in [8.0, 84.0]:
				CelArt.box(c, Rect2(x, 38, 8, 60), wood.darkened(0.3), Vector2(4, -4))
			CelArt.box(c, Rect2(0, 26, 98, 12), wood, Vector2(10, -10))
			CelArt.poly(c, PackedVector2Array([Vector2(18, 28), Vector2(80, 28), Vector2(86, 60), Vector2(12, 60)]), cream, 1.5)
			CelArt.line(c, Vector2(16, 52), Vector2(84, 52), Color("b65343"), 3)
			for x: float in [20.0, 74.0]:
				CelArt.ellipse(c, Vector2(x, 24), Vector2(9, 3), Color("e7e1bd"), 1.5)
			CelArt.poly(c, PackedVector2Array([Vector2(43, 23), Vector2(55, 23), Vector2(53, 9), Vector2(45, 9)]), Color("5f8fa0"))
			for i: int in range(3):
				c.draw_circle(Vector2(42 + i * 7, 3 + i % 2 * 3), 4.5, Color("e5a26a") if i != 1 else Color("efca88"))
		BuildingProp.Kind.DINING_CHAIR:
			CelArt.box(c, Rect2(10, 0, 14, 64), wood.darkened(0.1), Vector2(4, -3))
			for y: float in [14.0, 30.0]:
				CelArt.line(c, Vector2(14, y), Vector2(22, y), cream, 3)
			CelArt.box(c, Rect2(8, 52, 82, 12), Color("8f5f48"), Vector2(6, -8))
			CelArt.rect(c, Rect2(12, 46, 72, 7), Color("c9a36d"), 1.5)
			for x: float in [14.0, 82.0]:
				CelArt.line(c, Vector2(x, 64), Vector2(x, 100), ink, 7)
				CelArt.line(c, Vector2(x, 64), Vector2(x, 100), wood, 3)
		BuildingProp.Kind.PIANO:
			CelArt.box(c, Rect2(2, 0, 94, 60), Color("3b2f2c"), Vector2(8, -6))
			CelArt.rect(c, Rect2(8, 6, 82, 30), Color("54423b"), 1.5)
			CelArt.rect(c, Rect2(38, 9, 24, 21), cream, 1)
			for i: int in range(3):
				CelArt.line(c, Vector2(41, 15 + i * 5), Vector2(58, 15 + i * 5), Color("6d5a4a"), 1)
			CelArt.rect(c, Rect2(-2, 42, 102, 12), Color("efe8cf"))
			for i: int in range(14):
				if i % 7 != 2 and i % 7 != 6:
					CelArt.rect(c, Rect2(4 + i * 6.8, 42, 3.6, 7), ink, 0)
			CelArt.box(c, Rect2(4, 56, 90, 36), Color("2f2523"), Vector2(6, -4))
			for x: float in [8.0, 86.0]:
				CelArt.rect(c, Rect2(x, 92, 7, 8), Color("2f2523"))
			for x: float in [42.0, 54.0]:
				CelArt.rect(c, Rect2(x, 88, 6, 6), CelArt.GOLD, 1)
			for x: float in [12.0, 88.0]:
				CelArt.line(c, Vector2(x, -12), Vector2(x, -2), Color("efca88"), 4)
				c.draw_circle(Vector2(x, -15), 4, Color(1, .8, .4, .7))
		BuildingProp.Kind.TURNTABLE:
			CelArt.box(c, Rect2(0, 40, 94, 58), wood, Vector2(8, -6))
			CelArt.rect(c, Rect2(7, 47, 80, 44), Color("3d322c"))
			for i: int in range(9):
				CelArt.rect(c, Rect2(10 + i * 8.5, 52 + i % 3 * 3, 7, 38 - i % 3 * 3), Color.from_hsv(fmod(i * .17 + .05, 1), .45, .75), 1)
			CelArt.box(c, Rect2(4, 20, 86, 16), Color("2f3a3a"), Vector2(6, -8))
			CelArt.ellipse(c, Vector2(38, 18), Vector2(28, 7), ink, 1.5)
			CelArt.ellipse(c, Vector2(38, 18), Vector2(19, 4.5), Color("252a2a"), 1)
			CelArt.ellipse(c, Vector2(38, 18), Vector2(6, 2), Color("d1694f"), 0)
			CelArt.line(c, Vector2(78, 12), Vector2(56, 17), steel, 3)
			c.draw_circle(Vector2(78, 12), 4, steel)
		BuildingProp.Kind.SPEAKER:
			CelArt.box(c, Rect2(6, 0, 84, 98), Color("2c3434"), Vector2(8, -6))
			c.draw_circle(Vector2(48, 24), 14, ink)
			c.draw_circle(Vector2(48, 24), 10, Color("4e5c5a"))
			c.draw_circle(Vector2(48, 24), 4, steel)
			c.draw_circle(Vector2(48, 66), 28, ink)
			c.draw_circle(Vector2(48, 66), 23, Color("4e5c5a"))
			c.draw_arc(Vector2(48, 66), 15, 0, TAU, 20, Color("6f7f7c"), 2, true)
			c.draw_circle(Vector2(48, 66), 7, steel)
			CelArt.rect(c, Rect2(10, 92, 76, 6), CelArt.GOLD, 1)
		BuildingProp.Kind.BATHTUB:
			CelArt.line(c, Vector2(92, 22), Vector2(92, 2), ink, 6)
			CelArt.line(c, Vector2(92, 2), Vector2(80, 2), ink, 6)
			CelArt.line(c, Vector2(92, 22), Vector2(92, 2), steel, 3)
			CelArt.poly(c, PackedVector2Array([Vector2(2, 24), Vector2(98, 24), Vector2(90, 78), Vector2(10, 78)]), Color("e3e6da"))
			CelArt.poly(c, PackedVector2Array([Vector2(70, 24), Vector2(98, 24), Vector2(90, 78), Vector2(76, 78)]), Color("b9c1b6"), 0)
			CelArt.rect(c, Rect2(-2, 18, 104, 9), Color("f2f0e2"))
			CelArt.poly(c, PackedVector2Array([Vector2(6, 20), Vector2(94, 20), Vector2(90, 24), Vector2(10, 24)]), Color("8ec5cf"), 0)
			for i: int in range(6):
				CelArt.ellipse(c, Vector2(16 + i * 12, 14 - i % 2 * 5), Vector2(6, 5), Color("f4f6ee"), 1.2)
			for x: float in [16.0, 84.0]:
				CelArt.poly(c, PackedVector2Array([Vector2(x - 6, 78), Vector2(x + 6, 78), Vector2(x + 8, 98), Vector2(x - 8, 98)]), CelArt.GOLD)
		BuildingProp.Kind.SINK_MIRROR:
			CelArt.ellipse(c, Vector2(50, 22), Vector2(32, 22), Color("c9a35d"))
			CelArt.ellipse(c, Vector2(50, 22), Vector2(26, 17), Color("a9cdd0"), 1.5)
			CelArt.line(c, Vector2(34, 18), Vector2(44, 8), Color("e8f4ee"), 3)
			CelArt.line(c, Vector2(50, 44), Vector2(50, 54), ink, 6)
			CelArt.line(c, Vector2(50, 44), Vector2(58, 44), ink, 5)
			CelArt.line(c, Vector2(50, 44), Vector2(50, 54), steel, 2.5)
			CelArt.rect(c, Rect2(4, 52, 92, 10), Color("f2f0e2"))
			CelArt.box(c, Rect2(10, 62, 80, 36), Color("8fb8b2"), Vector2(6, -4))
			for x: float in [12.0, 52.0]:
				CelArt.rect(c, Rect2(x, 66, 36, 28), Color("a7cbc4"), 1.5)
			CelArt.rect(c, Rect2(0, 44, 10, 26), Color("e8b9a0"), 1.2)
		BuildingProp.Kind.SUITCASE:
			c.draw_rect(Rect2(34, 0, 30, 14), ink, false, 4.0)
			CelArt.box(c, Rect2(4, 12, 88, 80), Color("a85e43"), Vector2(8, -8))
			for x: float in [26.0, 70.0]:
				CelArt.line(c, Vector2(x, 13), Vector2(x, 91), Color("6b3a2d"), 5)
			CelArt.rect(c, Rect2(38, 30, 18, 14), Color("e5d0a7"), 1.2)
			CelArt.rect(c, Rect2(10, 58, 13, 13), Color("65b9a0"), 1.2)
			for x: float in [14.0, 80.0]:
				c.draw_circle(Vector2(x, 95), 4.5, ink)
		BuildingProp.Kind.PLANTER_RACK:
			for x: float in [3.0, 95.0]:
				CelArt.line(c, Vector2(x, 0), Vector2(x, 100), ink, 6)
				CelArt.line(c, Vector2(x, 0), Vector2(x, 100), wood, 2.5)
			for row: int in range(3):
				var y: float = 32.0 + row * 33.0
				CelArt.rect(c, Rect2(0, y, 98, 5), wood)
				for i: int in range(3):
					var x: float = 18.0 + i * 31.0 + row % 2 * 6
					for leaf: int in range(3):
						CelArt.ellipse(c, Vector2(x - 8 + leaf * 8, y - 19 - leaf % 2 * 5), Vector2(5, 9), Color("688c64") if (leaf + i) % 2 == 1 else Color("8aab6e"), 1.2)
					CelArt.poly(c, PackedVector2Array([Vector2(x - 10, y - 12), Vector2(x + 10, y - 12), Vector2(x + 7, y), Vector2(x - 7, y)]), Color("b87858"), 1.5)
		BuildingProp.Kind.TREADMILL:
			CelArt.line(c, Vector2(82, 74), Vector2(70, 18), ink, 9)
			CelArt.line(c, Vector2(82, 74), Vector2(70, 18), steel, 4)
			CelArt.line(c, Vector2(72, 30), Vector2(34, 36), ink, 6)
			CelArt.line(c, Vector2(72, 30), Vector2(34, 36), steel, 2.5)
			CelArt.box(c, Rect2(52, 6, 36, 17), Color("39484c"), Vector2(5, -4))
			CelArt.rect(c, Rect2(57, 10, 20, 8), Color("8fd3c0"), 1)
			CelArt.poly(c, PackedVector2Array([Vector2(0, 76), Vector2(86, 76), Vector2(100, 92), Vector2(6, 96)]), Color("2c3434"))
			CelArt.box(c, Rect2(0, 70, 88, 12), Color("48555a"), Vector2(6, -4))
			for i: int in range(6):
				CelArt.line(c, Vector2(10 + i * 14, 86), Vector2(13 + i * 14, 92), Color("5d6d6f"), 2)
			CelArt.rect(c, Rect2(4, 94, 90, 6), CelArt.GOLD, 1)
		BuildingProp.Kind.WEIGHT_RACK:
			CelArt.line(c, Vector2(-2, 10), Vector2(102, 10), ink, 6)
			CelArt.line(c, Vector2(-2, 10), Vector2(102, 10), steel, 2.5)
			for x: float in [4.0, 84.0]:
				CelArt.rect(c, Rect2(x, 0, 10, 22), Color("3b4545"), 1.5)
			for x: float in [10.0, 86.0]:
				CelArt.line(c, Vector2(x, 14), Vector2(x, 100), ink, 7)
				CelArt.line(c, Vector2(x, 14), Vector2(x, 100), steel, 3)
			for y: float in [44.0, 76.0]:
				var plate: Color = Color("b65343") if y < 60.0 else Color("3d4a4c")
				CelArt.rect(c, Rect2(4, y, 92, 6), Color("5d6b68"))
				for i: int in range(3):
					var x: float = 22.0 + i * 25.0
					CelArt.line(c, Vector2(x, y - 7), Vector2(x + 16, y - 7), ink, 3)
					CelArt.rect(c, Rect2(x - 3, y - 13, 7, 12), plate, 1.2)
					CelArt.rect(c, Rect2(x + 12, y - 13, 7, 12), plate, 1.2)
		BuildingProp.Kind.PUNCH_BAG:
			CelArt.line(c, Vector2(50, 0), Vector2(50, 22), ink, 3)
			for y: float in [4.0, 10.0, 16.0]:
				c.draw_arc(Vector2(50, y), 3, 0, TAU, 8, steel, 1.5)
			CelArt.ellipse(c, Vector2(50, 25), Vector2(22, 6), Color("8a3a32"))
			CelArt.box(c, Rect2(28, 24, 44, 72), Color("b65343"), Vector2(5, -3))
			for y: float in [36.0, 82.0]:
				CelArt.rect(c, Rect2(28, y, 44, 6), cream, 1)
			CelArt.line(c, Vector2(36, 44), Vector2(36, 76), Color("d78366"), 3)
		BuildingProp.Kind.EASEL:
			CelArt.line(c, Vector2(50, 0), Vector2(50, 100), ink, 6)
			CelArt.line(c, Vector2(50, 0), Vector2(50, 100), wood.darkened(0.2), 2.5)
			for side: float in [-1.0, 1.0]:
				CelArt.line(c, Vector2(50 + side * 4, 0), Vector2(50 + side * 34, 100), ink, 7)
				CelArt.line(c, Vector2(50 + side * 4, 0), Vector2(50 + side * 34, 100), wood, 3)
			CelArt.box(c, Rect2(12, 64, 76, 6), wood, Vector2(4, -3))
			CelArt.rect(c, Rect2(16, 8, 68, 56), Color("efe8cf"))
			CelArt.rect(c, Rect2(21, 13, 58, 46), Color("8fbfcc"), 0)
			CelArt.poly(c, PackedVector2Array([Vector2(21, 59), Vector2(40, 30), Vector2(55, 48), Vector2(66, 36), Vector2(79, 59)]), Color("6f9c6a"), 1.2)
			c.draw_circle(Vector2(66, 23), 7, CelArt.GOLD)
			CelArt.line(c, Vector2(30, 46), Vector2(44, 52), Color("d1694f"), 3)
		BuildingProp.Kind.PAINT_TABLE:
			for x: float in [8.0, 82.0]:
				CelArt.box(c, Rect2(x, 48, 8, 50), wood.darkened(0.25), Vector2(4, -4))
			CelArt.box(c, Rect2(0, 38, 96, 11), Color("c9b48c"), Vector2(8, -8))
			for i: int in range(5):
				c.draw_circle(Vector2(10 + i * 19, 44 + i % 2 * 2), 3, Color.from_hsv(fmod(i * .19, 1), .6, .85))
			for i: int in range(4):
				CelArt.rect(c, Rect2(8.0 + i * 11.0, 22, 9, 16), Color.from_hsv(fmod(.55 + i * .21, 1), .5, .8), 1.2)
			CelArt.rect(c, Rect2(54, 18, 12, 20), Color("a9cdd0"), 1.2)
			for i: int in range(3):
				CelArt.line(c, Vector2(57 + i * 3, 22), Vector2(54 + i * 5, 2 + i * 3), wood.darkened(0.2), 2)
			CelArt.ellipse(c, Vector2(84, 32), Vector2(14, 6), Color("d8b98a"), 1.5)
			for i: int in range(4):
				c.draw_circle(Vector2(76 + i * 5, 31 - i % 2 * 2), 1.8, Color.from_hsv(fmod(i * .27, 1), .7, .9))
		BuildingProp.Kind.HVAC_UNIT:
			CelArt.box(c, Rect2(66, 0, 22, 16), steel, Vector2(4, -4))
			CelArt.box(c, Rect2(0, 14, 94, 82), Color("a9b8b0"), Vector2(8, -6))
			c.draw_circle(Vector2(34, 54), 28, ink)
			c.draw_circle(Vector2(34, 54), 24, Color("2d454b"))
			for i: int in range(5):
				var d: Vector2 = Vector2.from_angle(i * TAU / 5)
				CelArt.line(c, Vector2(34, 54) + d * 5, Vector2(34, 54) + d.rotated(.5) * 21, cream, 5)
			c.draw_circle(Vector2(34, 54), 5, steel)
			for i: int in range(6):
				CelArt.line(c, Vector2(68, 26 + i * 10), Vector2(88, 26 + i * 10), Color("5f7472"), 3)
			for i: int in range(6):
				CelArt.poly(c, PackedVector2Array([Vector2(4 + i * 15, 88), Vector2(12 + i * 15, 88), Vector2(6 + i * 15, 95), Vector2(-2 + i * 15, 95)]), CelArt.GOLD if i % 2 == 0 else ink, 0)
