class_name PixelFont
extends RefCounted
## The game's own 5x7 pixel capitals, built once at runtime as a bitmap FontFile so
## Labels, Buttons and draw_string all share it. Turkish capitals carry real accents
## (Ç Ğ İ Ö Ş Ü); lowercase input renders as capitals with Turkish casing (i -> İ,
## ı -> I). One font unit is 1 px at BASE = 12; request 24/36/48/60/72 for crisp
## 2x-6x pixels (integer-only scaling).

const BASE: int = 12
const ASCENT: int = 10
const DESCENT: int = 2
## Rows reserved above the 7-row capitals for accents.
const ABOVE: int = 3
## Rows of each glyph ('#' = ink). Plain glyphs start on the capital line; accented
## ones start ABOVE_ROWS[ch] rows higher, and may continue below the baseline.
const GLYPHS: Dictionary = {
	"A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
	"C": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."],
	"D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
	"E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
	"F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
	"G": [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".####"],
	"H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"I": ["###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"],
	"J": ["..###", "...#.", "...#.", "...#.", "#..#.", "#..#.", ".##.."],
	"K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
	"L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
	"M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
	"N": ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
	"O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
	"Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
	"R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
	"S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
	"T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
	"U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"V": ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."],
	"W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"],
	"X": ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"],
	"Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
	"Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
	"Ç": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###.", "..#..", ".##.."],
	"Ş": [".####", "#....", "#....", ".###.", "....#", "....#", "####.", "..#..", ".##.."],
	"Ğ": ["#...#", ".###.", ".....", ".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".####"],
	"İ": [".#.", "...", "###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"],
	"Ö": [".#.#.", ".....", ".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"Ü": [".#.#.", ".....", "#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
	"1": [".#.", "##.", ".#.", ".#.", ".#.", ".#.", "###"],
	"2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
	"3": ["####.", "....#", "....#", ".###.", "....#", "....#", "####."],
	"4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
	"5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
	"6": [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."],
	"7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
	"8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
	"9": [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."],
	".": [".", ".", ".", ".", ".", ".", "#"],
	",": ["..", "..", "..", "..", "..", ".#", ".#", "#."],
	":": [".", "#", ".", ".", ".", "#", "."],
	"!": ["#", "#", "#", "#", "#", ".", "#"],
	"?": [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."],
	"-": ["....", "....", "....", "####", "....", "....", "...."],
	"+": [".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."],
	"/": ["....#", "...#.", "...#.", "..#..", ".#...", ".#...", "#...."],
	"%": ["##..#", "##.#.", "...#.", "..#..", ".#...", ".#.##", "#..##"],
	"(": [".#", "#.", "#.", "#.", "#.", "#.", ".#"],
	")": ["#.", ".#", ".#", ".#", ".#", ".#", "#."],
	"'": ["#", "#", ".", ".", ".", ".", "."],
	"•": ["...", "...", ".#.", "###", ".#.", "...", "..."],
	"·": [".", ".", ".", "#", ".", ".", "."],
	"x": [".....", ".....", "#...#", ".#.#.", "..#..", ".#.#.", "#...#"],
}
const ABOVE_ROWS: Dictionary = {"Ğ": 3, "İ": 2, "Ö": 2, "Ü": 2}
## Lowercase and variant input mapped onto the capitals.
const ALIASES: Dictionary = {"i": "İ", "ı": "I", "ç": "Ç", "ğ": "Ğ", "ö": "Ö", "ş": "Ş", "ü": "Ü",
	"â": "A", "Â": "A", "î": "İ", "Î": "İ", "û": "U", "Û": "U", "×": "x"}
const SPACE: int = 3

static var _font: FontFile = null

static func font() -> FontFile:
	if _font == null: _font = _build()
	return _font

## True when every character of the text has a glyph (tests use this).
static func supports(text: String) -> bool:
	for i: int in range(text.length()):
		var ch: String = text[i]
		if ch == " " or GLYPHS.has(ch) or ALIASES.has(ch): continue
		if ch.to_upper() != ch and GLYPHS.has(ch.to_upper()): continue
		return false
	return true

static func _build() -> FontFile:
	var result: FontFile = FontFile.new()
	result.fixed_size = BASE
	result.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var key: Vector2i = Vector2i(BASE, 0)
	var height: int = ASCENT + DESCENT
	var atlas_width: int = 1
	for ch: String in GLYPHS: atlas_width += String((GLYPHS[ch] as Array)[0]).length() + 1
	var image: Image = Image.create(atlas_width, height, false, Image.FORMAT_RGBA8)
	var cells: Dictionary = {}
	var x: int = 1
	for ch: String in GLYPHS:
		var rows: Array = GLYPHS[ch]
		var width: int = String(rows[0]).length()
		var top: int = ABOVE - int(ABOVE_ROWS.get(ch, 0))
		for r: int in range(rows.size()):
			var row: String = rows[r]
			for c: int in range(width):
				if row[c] == "#": image.set_pixel(x + c, top + r, Color.WHITE)
		cells[ch] = Rect2(x, 0, width, height)
		x += width + 1
	var codes: Dictionary = {}
	for ch: String in GLYPHS: codes[ch.unicode_at(0)] = ch
	for ch: String in ALIASES: codes[ch.unicode_at(0)] = ALIASES[ch]
	for code: int in range(97, 123):
		var upper: String = String.chr(code - 32)
		if not codes.has(code) and GLYPHS.has(upper): codes[code] = upper
	for code: int in codes:
		var cell: Rect2 = cells[codes[code]]
		result.set_glyph_advance(0, BASE, code, Vector2(cell.size.x + 1, 0))
		result.set_glyph_offset(0, key, code, Vector2(0, -ASCENT))
		result.set_glyph_size(0, key, code, cell.size)
		result.set_glyph_uv_rect(0, key, code, cell)
		result.set_glyph_texture_idx(0, key, code, 0)
	for code: int in [32, 160]:
		result.set_glyph_advance(0, BASE, code, Vector2(SPACE, 0))
	result.set_cache_ascent(0, BASE, ASCENT)
	result.set_cache_descent(0, BASE, DESCENT)
	result.set_texture_image(0, key, 0, image)
	return result
