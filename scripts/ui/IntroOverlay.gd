class_name IntroOverlay
extends CanvasLayer
## Startup-only presentation. No world drawing, boss phases or run snapshots.
signal finished
enum State { CARD, BULLETIN, VIDEO, FADING, FINISHED }
const CARD_SECONDS: float = 2.8
const BULLETIN_SECONDS: float = 2.6
const FADE_SECONDS: float = 0.45
const CREDIT: String = "ORTA DOĞU TEKNİK ÜNİVERSİTESİ • İNŞAAT MÜHENDİSLİĞİ • GİRAY ESKALEN"
@export_file("*.ogv", "*.webm") var video_path: String = "res://assets/cutscenes/intro_cutscene.ogv"
@onready var surface: Control = $Surface
@onready var video: VideoStreamPlayer = $Surface/VideoStreamPlayer
@onready var title: Label = $Surface/Title
@onready var detail: Label = $Surface/Detail
@onready var eyebrow: Label = $Surface/Eyebrow
var state: State = State.FINISHED
var elapsed: float = 0.0
var used_video_path: String = ""
var fallback_reason: String = ""
var _sound: SoundManager
var _saved_bgm: float = -5.0

func active() -> bool:
	return state != State.FINISHED

func begin(sound: SoundManager) -> void:
	_sound = sound
	_saved_bgm = sound.bgm_player.volume_db
	used_video_path = ""
	fallback_reason = ""
	elapsed = 0.0
	surface.modulate = Color.WHITE
	video.volume_db = 0.0
	visible = true
	set_process(true)
	video.finished.connect(skip, CONNECT_ONE_SHOT)
	var stream: VideoStream = _find_video()
	video.visible = stream != null
	if stream != null:
		state = State.VIDEO
		_sound.bgm_player.volume_db = -80.0
		video.stream = stream
		video.paused = false
		video.play()
		_set_text("", "", "")
	else:
		state = State.CARD
		_sound.bgm_player.volume_db = -14.0
		_set_text("AFET KUŞATMASI", CREDIT, "BİR HAZIRLIK VE DAYANIŞMA HİKÂYESİ")

func _find_video() -> VideoStream:
	var candidates: Array[String] = [video_path]
	if video_path == "res://assets/cutscenes/intro_cutscene.ogv":
		candidates.append("res://assets/cutscenes/intro_cutscene.webm")
	for path: String in candidates:
		if not FileAccess.file_exists(path): continue
		var extension: String = path.get_extension().to_lower()
		if extension == "ogv":
			var file: FileAccess = FileAccess.open(path,FileAccess.READ)
			if file == null: continue
			var header: PackedByteArray = file.get_buffer(4096)
			if header.slice(0,4) != "OggS".to_ascii_buffer() or not header.hex_encode().contains("7468656f7261"):
				fallback_reason = "OGV dosyası geçerli bir Theora başlığı içermiyor."
				continue
		elif not ResourceLoader.get_recognized_extensions_for_type("VideoStream").has(extension):
			fallback_reason = "Bu Godot kurulumunda WebM çözücüsü yok; OGV kullanın."
			continue
		var stream: VideoStream = ResourceLoader.load(path,"VideoStream") as VideoStream
		if stream != null:
			used_video_path = path
			return stream
		fallback_reason = "Video açılamadı; metin girişi kullanılıyor."
	return null

func _set_text(top: String, heading: String, subheading: String) -> void:
	eyebrow.text = top
	title.text = heading
	detail.text = subheading
	for label: Label in [eyebrow,title,detail]: label.modulate.a = 0.0

func skip() -> void:
	if not active() or state == State.FADING: return
	state = State.FADING
	elapsed = 0.0
	# Keep the last frame visible while fading, then release the decoder.
	video.paused = true
	Input.action_release("dash")

func cancel() -> void:
	state = State.FINISHED
	video.stop()
	video.stream = null
	if video.finished.is_connected(skip): video.finished.disconnect(skip)
	visible = false
	set_process(false)
	if _sound != null: _sound.bgm_player.volume_db = _saved_bgm

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if not active(): return
	elapsed += delta
	if state == State.VIDEO:
		# A valid header with an unusable decoder must not trap the player.
		if elapsed > 1.5 and (not video.is_playing() or video.get_video_texture() == null):
			video.stop()
			video.stream = null
			video.hide()
			state = State.CARD
			elapsed = 0.0
			used_video_path = ""
			fallback_reason = "Video başlatılamadı; metin girişi kullanılıyor."
			_sound.bgm_player.volume_db = -14.0
			_set_text("AFET KUŞATMASI",CREDIT,"BİR HAZIRLIK VE DAYANIŞMA HİKÂYESİ")
	elif state == State.FADING:
		var progress: float = clampf(elapsed / FADE_SECONDS,0.0,1.0)
		surface.modulate.a = 1.0-smoothstep(0.0,1.0,progress)
		video.volume_db = lerpf(0.0,-80.0,progress)
		_sound.bgm_player.volume_db = lerpf(-80.0 if not used_video_path.is_empty() else -14.0,_saved_bgm,smoothstep(0.0,1.0,progress))
		if elapsed >= FADE_SECONDS-.000001:
			cancel()
			finished.emit()
	else:
		var opacity: float = smoothstep(0.0,0.45,elapsed)
		if state == State.CARD: opacity *= 1.0-smoothstep(CARD_SECONDS-0.4,CARD_SECONDS,elapsed)
		title.modulate.a = opacity
		detail.modulate.a = opacity
		eyebrow.modulate.a = opacity
		if state == State.CARD and elapsed >= CARD_SECONDS:
			state = State.BULLETIN
			elapsed = 0.0
			_set_text("ACİL DURUM BÜLTENİ","AFETE HAZIR OL.","TAHLİYE PLANINI GÖZDEN GEÇİR.\nACİL DURUM ÇANTANI HAZIRLA.")
			_sound.play("warn",-10.0)
		elif state == State.BULLETIN and elapsed >= BULLETIN_SECONDS:
			skip()
