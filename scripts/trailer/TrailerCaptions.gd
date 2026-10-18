class_name TrailerCaptions
extends Node2D
## Trailer-only overlay (CanvasLayer 60): short captions in the game's PixelFont with
## an accent line, the black/white/dim cards and the closing title. Never used by the
## game itself. Times are seconds of the visible shot (TrailerDirector.t).

const SAFE_LEFT: float = 96.0
const SAFE_RIGHT: float = 1824.0
const TOP_BASELINE: float = 178.0
const BOTTOM_BASELINE: float = 1000.0
const FADE_IN: float = 0.12
const FADE_OUT: float = 0.15

## {text, start, end, size, accent, y}
var captions: Array[Dictionary] = []
var t: float = 0.0
## 0..1 full-screen layers drawn under the captions.
var black: float = 0.0
var white: float = 0.0
var dim: float = 0.0
## Black over everything, captions and title included (the closing fade).
var fade_all: float = 0.0
## Closing card: {start} or empty.
var title: Dictionary = {}
var drawn_rects: Array[Rect2] = []
## --trailer-debug: shot/frame stamp in the corner (sync checks only).
var debug_text: String = ""

func add(text: String, start: float, end: float, accent: Color = UIStyle.TEXT, size: int = UIStyle.LARGE, y: float = TOP_BASELINE) -> void:
	captions.append({"text": text, "start": start, "end": end, "size": size, "accent": accent, "y": y})

func advance(seconds: float) -> void:
	t = seconds
	queue_redraw()

func _draw() -> void:
	drawn_rects.clear()
	if dim > 0.0: draw_rect(Rect2(0, 0, 1920, 1080), Color(0.01, 0.015, 0.02, 0.55 * dim))
	if black > 0.0: draw_rect(Rect2(0, 0, 1920, 1080), Color(0, 0, 0, black))
	if white > 0.0: draw_rect(Rect2(0, 0, 1920, 1080), Color(1, 1, 1, white))
	for caption: Dictionary in captions:
		var start: float = caption["start"]
		var end: float = caption["end"]
		if t < start or t > end: continue
		var appear: float = clampf((t - start) / FADE_IN, 0.0, 1.0)
		var vanish: float = clampf((end - t) / FADE_OUT, 0.0, 1.0)
		var alpha: float = minf(appear, vanish)
		var rise: float = roundf(8.0 * (1.0 - smoothstep(0.0, 1.0, appear)))
		_caption(caption["text"], caption["size"], caption["accent"], caption["y"] + rise, alpha, clampf((t - start) / 0.15, 0.0, 1.0))
	if not title.is_empty(): _title()
	if fade_all > 0.0: draw_rect(Rect2(0, 0, 1920, 1080), Color(0, 0, 0, fade_all))
	if debug_text != "": UIStyle.text(self, Vector2(1500, 60), debug_text, UIStyle.SMALL, Color.YELLOW)

## One caption: a soft dark band (no box edge), the text with the game's shadow and
## an accent line that opens from the centre.
func _caption(text: String, size: int, accent: Color, baseline: float, alpha: float, open: float) -> void:
	var width: float = UIStyle.width(text, size)
	var band_height: float = size + 46.0
	var top: float = baseline - size - 22.0
	var half: float = width * 0.5 + 90.0
	for step: int in range(6):
		var spread: float = half + step * 22.0
		draw_rect(Rect2(960.0 - spread, top + step * 2.0, spread * 2.0, band_height - step * 4.0), Color(0.01, 0.015, 0.02, 0.11 * alpha))
	drawn_rects.append(UIStyle.text(self, Vector2(960.0, baseline), text, size, Color(UIStyle.TEXT, alpha), HORIZONTAL_ALIGNMENT_CENTER))
	var line: float = (width * 0.5 + 12.0) * open
	draw_rect(Rect2(roundf(960.0 - line), baseline + 12.0, roundf(line * 2.0), 6.0), Color(accent, alpha))

func _title() -> void:
	var age: float = t - float(title["start"])
	if age < 0.0: return
	var alpha: float = clampf(age / 0.18, 0.0, 1.0)
	var sub: float = clampf((age - 0.45) / 0.3, 0.0, 1.0)
	var foot: float = clampf((age - 0.9) / 0.3, 0.0, 1.0)
	drawn_rects.append(UIStyle.text(self, Vector2(960, 540), "4 GÜN", 192, Color(UIStyle.TEXT, alpha), HORIZONTAL_ALIGNMENT_CENTER))
	var line: float = 330.0 * alpha
	draw_rect(Rect2(960.0 - line, 574, line * 2.0, 6), Color(UIStyle.ALERT, alpha))
	drawn_rects.append(UIStyle.text(self, Vector2(960, 656), "Hazırlık hayat kurtarır", UIStyle.LARGE, Color(UIStyle.SAFE, sub), HORIZONTAL_ALIGNMENT_CENTER))
	drawn_rects.append(UIStyle.text(self, Vector2(960, 912), "Civil Game Jam 2026", UIStyle.SMALL, Color(UIStyle.MUTED, foot), HORIZONTAL_ALIGNMENT_CENTER))
	var credit: Color = Color(UIStyle.FAINT.lerp(UIStyle.MUTED, 0.6), foot)
	drawn_rects.append(UIStyle.text(self, Vector2(960, 956), "Müzik: Gregor Quendel - Cinematic Epic Trailer (CC BY 4.0, düzenlendi)", UIStyle.SMALL, credit, HORIZONTAL_ALIGNMENT_CENTER))
	drawn_rects.append(UIStyle.text(self, Vector2(960, 990), "Ses efektleri: Ovani Sound", UIStyle.SMALL, credit, HORIZONTAL_ALIGNMENT_CENTER))
