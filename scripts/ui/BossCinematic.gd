class_name BossCinematic
extends Node2D
## Harmless intro staging in screen space. Physics and warnings begin only when
## the manager leaves WAVE_INTRO. Camera focus always returns to authored framing.
@export var custom_sprite: Texture2D
var game: MainGame
var progress: float = 0.0
var letterbox: float = 0.0

func configure(owner_game: MainGame) -> void:
	game = owner_game
	game.waves.intro_beat.connect(_beat)

func _beat(mode_id: int, beat: int) -> void:
	if mode_id in [DisasterWaveManager.Mode.STORM,DisasterWaveManager.Mode.CATACLYSM]:
		game.weather.trigger_flash(.8 if beat < 2 else 1.0)
	if mode_id == DisasterWaveManager.Mode.FLOOD:
		game.game_camera.apply_shake(5.0+beat*2,.35)

func _process(_delta: float) -> void:
	if game == null: return
	var intro: bool = game.waves.state == DisasterWaveManager.State.WAVE_INTRO and not game.waves.failed
	progress = clampf(1.0-game.waves.transition_remaining/game.waves.intro_duration(),0.0,1.0) if intro else 0.0
	letterbox = minf(smoothstep(0.0,.12,progress),1.0-smoothstep(.88,1.0,progress)) if intro else 0.0
	var focus: float = sin(PI*progress) if intro else 0.0
	var side: float = -1.0 if game.waves.mode == DisasterWaveManager.Mode.STORM else (1.0 if game.waves.mode == DisasterWaveManager.Mode.EARTHQUAKE else 0.0)
	game.game_camera.cinematic_offset = Vector2(side*42,-12)*focus
	game.game_camera.zoom = Vector2.ONE * game.base_zoom / float(game.pixel_scale) * (1.0+.025*focus)
	queue_redraw()

func _draw() -> void:
	if game == null or letterbox <= 0.0: return
	var mode_id: int = game.waves.mode
	var storm: bool = mode_id in [DisasterWaveManager.Mode.STORM,DisasterWaveManager.Mode.CATACLYSM]
	var quake: bool = mode_id in [DisasterWaveManager.Mode.EARTHQUAKE,DisasterWaveManager.Mode.CATACLYSM]
	var flood: bool = mode_id in [DisasterWaveManager.Mode.FLOOD,DisasterWaveManager.Mode.CATACLYSM]
	if custom_sprite != null:
		draw_texture_rect(custom_sprite,Rect2(0,0,1920,1080),false,Color(1,1,1,letterbox))
	var ground: float = game.world_to_screen(Vector2(0,game.backdrop.ground_y)).y
	if storm:
		draw_rect(Rect2(0,0,1920,ground),Color(.015,.035,.07,.23*letterbox))
		for i: int in range(35):
			var x: float = fposmod(i*173.0+progress*3900,2300)-200
			var y: float = 150+fmod(i*97,680)
			draw_line(Vector2(x,y),Vector2(x+65+(i%4)*22,y-6),Color("adcada",.25*letterbox),2.0)
		var pulse: float = pow(maxf(0.0,sin(progress*PI*9)),18)
		if pulse > .06:
			var x: float = 270+int(progress*9)%3*650
			var bolt: PackedVector2Array = PackedVector2Array([Vector2(x,75),Vector2(x-37,180),Vector2(x+25,167),Vector2(x-36,320),Vector2(x+10,300),Vector2(x-53,450)])
			draw_polyline(bolt,Color("6fa7db",pulse*.5),14.0)
			draw_polyline(bolt,Color("e4f4ff",pulse),3.0)
	if quake:
		for i: int in range(11):
			var x: float = 80+i*180
			var crack: PackedVector2Array = PackedVector2Array([Vector2(x,ground+6),Vector2(x+22,ground-3),Vector2(x+40,ground+14),Vector2(x+73,ground+7)])
			draw_polyline(crack,Color("0b1015",letterbox),5.0)
			draw_polyline(crack,Color("98a9ad",.55*letterbox),1.5)
		for side: float in [-1.0,1.0]:
			for i: int in range(12):
				var local: float = fposmod(progress*1.6+i*.079,1.0)
				var point: Vector2 = Vector2(960+side*(775+sin(i*2.3)*85),ground-sin(local*PI)*340)
				draw_set_transform(point,progress*8+i)
				CelArt.poly(self,PackedVector2Array([Vector2(-9,-8),Vector2(7,-11),Vector2(15,2),Vector2(1,13),Vector2(-12,6)]),Color("677579"),2.5)
		draw_set_transform(Vector2.ZERO)
	if flood:
		for side: float in [-1.0,1.0]:
			var crest: PackedVector2Array = PackedVector2Array()
			for i: int in range(15):
				var x: float = (0.0 if side < 0 else 1920.0)+side*(-i*18.0)
				crest.append(Vector2(x,ground-(180+sin(i*.4+progress*13)*35)*sin(progress*PI)))
			var water: PackedVector2Array = crest.duplicate()
			water.append(Vector2(crest[-1].x,ground+18))
			water.append(Vector2(crest[0].x,ground+18))
			CelArt.poly(self,water,Color("163a54",letterbox),3.0)
			var band: PackedVector2Array = crest.duplicate()
			for i: int in range(crest.size()-1,-1,-1): band.append(crest[i]+Vector2(0,23))
			draw_colored_polygon(band,Color("287d97",letterbox))
			for row: int in range(5):
				var line: PackedVector2Array = PackedVector2Array()
				for i: int in range(crest.size()):
					line.append(crest[i].lerp(Vector2(crest[i].x,ground),.24+row*.13)+Vector2(0,sin(i*.7+progress*19+row)*6))
				draw_polyline(line,Color("328faa",letterbox*.7),2.0)
			draw_polyline(crest,Color("70ddd9",letterbox),5.0)
			for i: int in range(1,crest.size(),3):
				var point: Vector2 = crest[i]
				draw_arc(point+Vector2(2,8),13,PI*.95,TAU-.2,12,Color("d2fff7",letterbox*.9),3.0)
				draw_circle(point+Vector2(-side*8,-9),2.5,Color("b9faf3",letterbox))
				draw_circle(point+Vector2(side*5,-16),1.5,Color("b9faf3",letterbox))
		# Harmless first surge at the ground-floor sill, then it drains for play.
		var height: float = sin(progress*PI)*72
		draw_rect(Rect2(280,ground-height,1360,height+12),Color("1e6984",.30*letterbox))
		for i: int in range(18):
			draw_arc(Vector2(290+i*78,ground-height+sin(i+progress*18)*5),17,PI,TAU,12,Color("b9faf3",.6*letterbox),2.0)
	draw_rect(Rect2(0,0,1920,88*letterbox),Color("070a0f"))
	draw_rect(Rect2(0,1080-88*letterbox,1920,88*letterbox),Color("070a0f"))
	var reveal: float = minf(smoothstep(.2,.4,progress),1.0-smoothstep(.84,1.0,progress))
	var font: Font = ThemeDB.fallback_font
	var title: String = game.waves.boss_name()
	var size: int = 52 if mode_id == DisasterWaveManager.Mode.CATACLYSM else 76
	var width: float = font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	var point: Vector2 = Vector2(960-width*.5,560)
	draw_string_outline(font,point,title,HORIZONTAL_ALIGNMENT_LEFT,-1,size,12,Color("111518",reveal))
	draw_string(font,point,title,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("e5f5f1",reveal))
	draw_line(Vector2(960-width*.5,581),Vector2(960+width*.5,581),Color("76cece",reveal*.8),3.0)
