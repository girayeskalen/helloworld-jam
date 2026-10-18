class_name Debrief
extends RefCounted
## Karne: at most three short lines after a disaster — what the player's preparation
## and behaviour did. Every missed habit carries one short tip phrased after AFAD
## guidance (SOURCES.md); the game never promises real-world safety.

const MAX_ROWS: int = 3

## Rows for the fight just played: {ok: bool, fact: String, tip: String}; misses first.
static func rows(game: MainGame, phase_mode: int) -> Array[Dictionary]:
	var prep: Preparedness = game.preparedness
	var tremor: TremorSystem = game.tremor
	var misses: Array[Dictionary] = []
	var wins: Array[Dictionary] = []
	var quake: bool = phase_mode in [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.CATACLYSM]
	var storm: bool = phase_mode in [DisasterWaveManager.Mode.STORM, DisasterWaveManager.Mode.CATACLYSM]
	var flood: bool = phase_mode in [DisasterWaveManager.Mode.FLOOD, DisasterWaveManager.Mode.CATACLYSM]
	if quake:
		var shakes: int = int(tremor.stats["shakes"])
		var covered: int = int(tremor.stats["covered"])
		if shakes > 0:
			var line: String = "Çök-Kapan-Tutun %d/%d" % [covered, shakes]
			if covered >= shakes: wins.append(_row(true, line))
			else: misses.append(_row(false, line, "Sarsıntıda çök, başını koru, tutun."))
		if int(tremor.stats["stair_attempts"]) > 0:
			misses.append(_row(false, "Sarsıntıda kaçmaya çalıştın", "Merdivene ve asansöre koşma."))
		var topples: int = int(tremor.stats["topples"])
		if topples > 0: misses.append(_row(false, "%d eşya devrildi" % topples, "Ağır eşyaları duvara sabitle."))
		elif prep.count(Preparedness.Task.SECURE) == prep.count(Preparedness.Task.SECURE, false): wins.append(_row(true, "Eşyalar sabitti"))
		if prep.gas_off: wins.append(_row(true, "Gaz vanası kapalıydı"))
		elif int(tremor.stats["gas_leaks"]) > 0: misses.append(_row(false, "Gaz kaçağı oldu", "Vanaların yerini öğren, gazı kapat."))
	if int(prep.phase_stats.get("glass", 0)) > 0:
		misses.append(_row(false, "Cam kırıkları geldi", "Pencere ve camlardan uzak dur."))
	if storm and int(Preparedness.UNLOCK[Preparedness.Task.SHUTTER]) <= game.waves.completed_waves:
		var shut: int = prep.count(Preparedness.Task.SHUTTER)
		var windows: int = prep.count(Preparedness.Task.SHUTTER, false)
		var line: String = "Kepenkler %d/%d" % [shut, windows]
		if shut >= windows: wins.append(_row(true, line))
		else: misses.append(_row(false, line, "Fırtınada kepenk ve pencereleri kapat."))
	if flood:
		if prep.power_off: wins.append(_row(true, "Sigortalar kapalıydı"))
		else: misses.append(_row(false, "Sigortalar açık kaldı", "Sel öncesi sigortaları kapat."))
		if int(prep.phase_stats.get("water_hits", 0)) > 0:
			misses.append(_row(false, "Su seni yakaladı", "Sudan uzak dur, yükseğe çık."))
	if prep.phase_stats.get("bag_used", false): wins.append(_row(true, "Afet çantan işe yaradı"))
	elif not prep.bag_ready: misses.append(_row(false, "Afet çantan hazır değildi", "Afet çantanı hazır tut."))
	var result: Array[Dictionary] = []
	for row: Dictionary in misses + wins:
		if result.size() >= MAX_ROWS: break
		result.append(row)
	return result

static func _row(ok: bool, fact: String, tip: String = "") -> Dictionary:
	return {"ok": ok, "fact": fact, "tip": tip}

## Check / cross glyph drawn with lines (the pixel font has no ✓/✗).
static func draw_mark(canvas: CanvasItem, center: Vector2, ok: bool, alpha: float = 1.0) -> void:
	var color: Color = Color(UIStyle.SAFE if ok else UIStyle.DANGER, alpha)
	if ok:
		canvas.draw_polyline(PackedVector2Array([center + Vector2(-8, 0), center + Vector2(-2, 6), center + Vector2(9, -7)]), color, 4.0)
	else:
		canvas.draw_line(center + Vector2(-7, -7), center + Vector2(7, 7), color, 4.0)
		canvas.draw_line(center + Vector2(7, -7), center + Vector2(-7, 7), color, 4.0)
