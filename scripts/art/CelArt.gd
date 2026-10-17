class_name CelArt
extends RefCounted
## Shared drawing vocabulary. No imported image, font or shader required.

const INK: Color = Color("111518")
const PAPER: Color = Color("ece0c3")
const GOLD: Color = Color("efb961")
const TEAL: Color = Color("65b9a0")
## At the game's 0.39 world scale, 14 vertices retain the pixel silhouette of 24.
const ELLIPSE_SEGMENTS: int = 14
static var _ellipse_unit: PackedVector2Array = PackedVector2Array()

static func poly(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float = 2.5) -> void:
	canvas.draw_colored_polygon(points, color)
	if width > 0.0:
		var closed: PackedVector2Array = points.duplicate()
		closed.append(points[0])
		canvas.draw_polyline(closed, INK, width, false)

static func rect(canvas: CanvasItem, area: Rect2, color: Color, width: float = 2.5) -> void:
	canvas.draw_rect(area, color)
	if width > 0.0:
		canvas.draw_rect(area, INK, false, width)

static func line(canvas: CanvasItem, start: Vector2, end: Vector2, color: Color, width: float = 2.0) -> void:
	canvas.draw_line(start, end, color, width, false)

static func ellipse(canvas: CanvasItem, center: Vector2, radius: Vector2, color: Color, width: float = 2.5) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	if _ellipse_unit.is_empty():
		for i: int in range(ELLIPSE_SEGMENTS): _ellipse_unit.append(Vector2.from_angle(TAU*float(i)/ELLIPSE_SEGMENTS))
	points.resize(ELLIPSE_SEGMENTS)
	for i: int in range(ELLIPSE_SEGMENTS): points[i] = center+_ellipse_unit[i]*radius
	poly(canvas, points, color, width)

static func box(canvas: CanvasItem, area: Rect2, color: Color, depth: Vector2 = Vector2(9.0, -8.0)) -> void:
	var a: Vector2 = area.position
	var b: Vector2 = a + Vector2(area.size.x, 0.0)
	var c: Vector2 = area.end
	poly(canvas, PackedVector2Array([a, a + depth, b + depth, b]), color.lightened(0.20))
	poly(canvas, PackedVector2Array([b, b + depth, c + depth, c]), color.darkened(0.30))
	rect(canvas, area, color)
	line(canvas, a + Vector2(3, 3), b + Vector2(-3, 3), color.lightened(0.30), 2.0)

static func bolt(canvas: CanvasItem, point: Vector2, color: Color = Color("a6b3ae")) -> void:
	canvas.draw_circle(point, 3.6, INK)
	canvas.draw_circle(point + Vector2(-0.6, -0.7), 2.0, color)

static func label(canvas: CanvasItem, point: Vector2, message: String, size: int = 16, color: Color = PAPER) -> void:
	canvas.draw_string(ThemeDB.fallback_font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)
