class_name WorldBackdrop
extends Node2D
## Static night sky, blacked-out skyline and ground. Rain, ash and lightning live
## in NightWeather so this layer is drawn once.

@export var custom_sprite: Texture2D
## World area seen by the zoomed-out camera (1920x1080 / camera zoom).
@export var view_size: Vector2 = Vector2(1920, 1080)
@export var ground_y: float = 917.0
## Extra paint around the view so camera shake never exposes the clear colour.
const BLEED: float = 60.0
const SKY_TOP: Color = Color("0b0e14")
const SKY_LOW: Color = Color("141923")
## Two low-res pixels at the default zoom (0.39), so dithers land on the pixel grid.
const DITHER: float = 5.128
const BAYER: Array[int] = [0, 2, 3, 1]

func _draw() -> void:
	var w: float = view_size.x
	var h: float = view_size.y
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(-BLEED, -BLEED, w + BLEED * 2, h + BLEED * 2), false)
		return
	var g: float = ground_y
	CelArt.rect(self, Rect2(-BLEED, -BLEED, w + BLEED * 2, h + BLEED * 2), SKY_TOP, 0)
	# Banded sky with ordered-dither seams: a pixel-art gradient, not a smooth blend.
	var bands: int = 12
	var band_h: float = (g + BLEED) / float(bands)
	for band: int in range(bands):
		var y: float = -BLEED + band * band_h
		var color: Color = SKY_TOP.lerp(SKY_LOW, float(band) / float(bands - 1))
		CelArt.rect(self, Rect2(-BLEED, y, w + BLEED * 2, band_h + 1), color, 0)
		if band > 0:
			var above: Color = SKY_TOP.lerp(SKY_LOW, float(band - 1) / float(bands - 1))
			_dither_strip(Rect2(-BLEED, y - DITHER * 3, w + BLEED * 2, DITHER * 6), color, above)
	# A drowned moon behind the overcast, then heavy cloud masses.
	var moon: Vector2 = Vector2(w * 0.86, g * 0.22)
	for i: int in range(4):
		draw_circle(moon, 150.0 - i * 30.0, Color(0.35, 0.40, 0.50, 0.025 + i * 0.012))
	draw_circle(moon, 54, Color("2e333d"))
	draw_circle(moon + Vector2(-14, -6), 50, Color("383d47"))
	for i: int in range(int(w / 150.0) + 4):
		var x: float = float(i * 150 - 120)
		var y: float = g * 0.2 + sin(float(i) * 1.7) * 60.0
		CelArt.ellipse(self, Vector2(x, y), Vector2(190, 34), Color("161c27"), 0)
		CelArt.ellipse(self, Vector2(x + 40, y - 14), Vector2(120, 18), Color("1c2331"), 0)
	# Distant fires: low ember glow behind the skyline.
	for x: float in [w * 0.12, w * 0.47, w * 0.71]:
		for i: int in range(5):
			CelArt.ellipse(self, Vector2(x, g - 90), Vector2(260 - i * 40, 120 - i * 20), Color(0.55, 0.20, 0.08, 0.05 + i * 0.02), 0)
	for layer: int in range(2):
		for i: int in range(int(w / 101.0) + 2):
			var x: float = i * 101.0 + layer * 38.0 - 20.0
			var bh: float = 75.0 + float((i * 29 + layer * 47) % 139)
			var base: float = g - 102.0 + layer * 55.0
			var c: Color = Color("12161e") if layer == 0 else Color("0c0f15")
			CelArt.rect(self, Rect2(x, base - bh, 88, bh), c, 0)
			CelArt.poly(self, PackedVector2Array([Vector2(x - 4, base - bh), Vector2(x + 43, base - bh - 22), Vector2(x + 92, base - bh)]), c, 0)
			# Blackout: almost every window is dark; a few candles and one cold screen.
			for row: int in range(3):
				for column: int in range(3):
					var lit: int = (row * 7 + column * 3 + i * 5 + layer) % 17
					var window: Rect2 = Rect2(x + 12 + column * 24, base - 64 + row * 19, 8, 11)
					if lit == 0:
						CelArt.rect(self, window, Color("6b4a24"), 0)
					elif lit == 9:
						CelArt.rect(self, window, Color("2b3b4d"), 0)
					else:
						CelArt.rect(self, window, c.lightened(0.05), 0)
			if (i + layer) % 9 == 4:
				draw_circle(Vector2(x + 44, base - bh - 24), 3, Color("8a2a22"))
	CelArt.poly(self, PackedVector2Array([Vector2(-BLEED, g), Vector2(w + BLEED, g), Vector2(w + BLEED, h + BLEED), Vector2(-BLEED, h + BLEED)]), Color("0b0e0d"), 0)
	CelArt.poly(self, PackedVector2Array([Vector2(-BLEED, g - 1), Vector2(w + BLEED, g - 1), Vector2(w + BLEED, g + 25), Vector2(-BLEED, g + 32)]), Color("151a17"), 0)
	_dither_strip(Rect2(-BLEED, g + 12, w + BLEED * 2, DITHER * 6), Color("0b0e0d"), Color("151a17"))
	CelArt.line(self, Vector2(-BLEED, g + 1), Vector2(w + BLEED, g + 1), Color("06090a"), 4)
	for i: int in range(int(w / 45.0)):
		var x: float = float((i * 137) % int(w))
		var y: float = g + 26.0 + float((i * 19) % maxi(20, int(h - g - 30.0)))
		CelArt.line(self, Vector2(x, y), Vector2(x + 12 + i % 9, y - 2), Color("141a16"), 2)
		if i % 5 == 0:
			CelArt.ellipse(self, Vector2(x + 30, y + 4), Vector2(18, 3), Color(0.25, 0.32, 0.40, 0.25), 0)
	for side: int in range(2):
		var x: float = 40.0 if side == 0 else w - 40.0
		_draw_tree(Vector2(x, g), 1.0 if side == 0 else -1.0)
		for i: int in range(3):
			_draw_sandbag(Vector2(x + (30 + i * 37) * (1.0 if side == 0 else -1.0), g - 3 - i % 2 * 13))
	for x: float in [w * 0.16, w * 0.8]:
		CelArt.poly(self, PackedVector2Array([Vector2(x, g + 2), Vector2(x + 18, g - 22), Vector2(x + 41, g - 18), Vector2(x + 58, g + 3)]), Color("1d221f"))
		for i: int in range(8):
			CelArt.line(self, Vector2(x + 73 + i * 6, g + 4), Vector2(x + 68 + i * 6, g - 13 - i % 3 * 5), Color("0d1210"), 3)

## Ordered (2x2 Bayer) seam between two flat colours: a pixel-art gradient. The top
## half already shows `upper` and the bottom half `lower`; only minority cells are painted.
func _dither_strip(area: Rect2, lower: Color, upper: Color) -> void:
	var rows: int = maxi(2, int(area.size.y / DITHER))
	var columns: int = int(area.size.x / DITHER) + 1
	for row: int in range(rows):
		var mix: float = (float(row) + 0.5) / float(rows)
		var underneath_lower: bool = row >= rows / 2
		for column: int in range(columns):
			var threshold: float = (float(BAYER[(row % 2) * 2 + column % 2]) + 0.5) / 4.0
			var want_lower: bool = threshold < mix
			if want_lower != underneath_lower:
				draw_rect(Rect2(area.position.x + column * DITHER, area.position.y + row * DITHER, DITHER, DITHER), lower if want_lower else upper)

func _draw_tree(base: Vector2, facing: float) -> void:
	CelArt.line(self, base, base + Vector2(7 * facing, -184), Color("06080a"), 13)
	for i: int in range(5):
		var start: Vector2 = base + Vector2(5 * facing, -61 - i * 24)
		var end: Vector2 = start + Vector2((41 - i * 4) * facing * (1 if i % 2 == 0 else -1), -36)
		CelArt.line(self, start, end, Color("06080a"), 7)
		CelArt.line(self, end, end + Vector2(14 * facing, -20), Color("06080a"), 4)

func _draw_sandbag(point: Vector2) -> void:
	CelArt.poly(self, PackedVector2Array([point + Vector2(-24, 0), point + Vector2(-27, -10), point + Vector2(-18, -22), point + Vector2(16, -24), point + Vector2(25, -14), point + Vector2(21, -2)]), Color("2b2820"))
	CelArt.line(self, point + Vector2(-16, -18), point + Vector2(15, -20), Color("3b362a"), 3)
	CelArt.line(self, point + Vector2(-20, -8), point + Vector2(18, -9), Color("1c1a15"), 1)
