class_name UpgradeIcon
extends Control
## Original pixel silhouettes, drawn on a 64px grid with nearest edges.
@export var custom_sprite: Texture2D
var kind: int = 0
var accent: Color = Color("71e5d2")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _r(x: float, y: float, w: float, h: float, tint: Color) -> void:
	draw_rect(Rect2(x,y,w,h),CelArt.INK)
	draw_rect(Rect2(x+1.5,y+1.5,w-3,h-3),tint)

func _draw() -> void:
	if custom_sprite != null:
		draw_texture_rect(custom_sprite,Rect2(Vector2.ZERO,size),false)
		return
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*size.x/64.0)
	var steel: Color = Color("71849a")
	var light: Color = Color("e5eedc")
	match kind:
		SiegeUpgrades.Kind.DOME:
			draw_colored_polygon(PackedVector2Array([Vector2(6,53),Vector2(6,27),Vector2(14,15),Vector2(25,8),Vector2(39,8),Vector2(50,15),Vector2(58,27),Vector2(58,53)]),CelArt.INK)
			draw_arc(Vector2(32,39),24,PI,TAU,8,accent,5)
			_r(12,37,5,16,accent); _r(47,37,5,16,accent)
			_r(24,25,16,15,light); _r(19,40,26,11,steel)
			_r(6,52,52,5,accent)
		SiegeUpgrades.Kind.AWARE_BAG:
			_r(23,6,18,10,steel); _r(14,14,36,41,Color("365d56"))
			_r(8,26,9,22,steel); _r(47,26,9,22,steel)
			draw_rect(Rect2(28,23,8,24),accent); draw_rect(Rect2(20,31,24,8),accent)
			_r(19,51,8,7,light); _r(37,51,8,7,light)
		SiegeUpgrades.Kind.AWARE_STRUCTURE:
			_r(7,8,11,48,steel); _r(46,8,11,48,steel)
			draw_line(Vector2(15,13),Vector2(49,51),CelArt.INK,9)
			draw_line(Vector2(15,13),Vector2(49,51),accent,5)
			draw_line(Vector2(49,13),Vector2(15,51),CelArt.INK,9)
			draw_line(Vector2(49,13),Vector2(15,51),accent,5)
			for x: int in [10,49]:
				for y: int in [11,48]: draw_rect(Rect2(x,y,5,5),light)
		SiegeUpgrades.Kind.SONIC_DASH:
			for i: int in range(3): _r(4+i*6,19+i*9,21,4,steel)
			draw_colored_polygon(PackedVector2Array([Vector2(40,8),Vector2(22,34),Vector2(35,34),Vector2(27,56),Vector2(59,25),Vector2(42,25),Vector2(49,8)]),CelArt.INK)
			draw_colored_polygon(PackedVector2Array([Vector2(42,12),Vector2(28,31),Vector2(40,31),Vector2(34,46),Vector2(51,28),Vector2(37,28)]),accent)
		SiegeUpgrades.Kind.AUTO_DRONE:
			_r(12,24,40,7,steel); _r(21,28,22,19,steel)
			for x: int in [4,42]:
				_r(x,16,18,8,light); _r(x+7,23,4,11,steel)
			_r(26,32,12,7,accent); _r(28,44,8,8,accent)
			draw_line(Vector2(32,52),Vector2(24,62),accent,2); draw_line(Vector2(32,52),Vector2(40,62),accent,2)
		SiegeUpgrades.Kind.GRAZE_TIME:
			draw_arc(Vector2(32,32),25,0,TAU,12,CelArt.INK,8)
			draw_arc(Vector2(32,32),25,0,TAU,12,accent,4)
			draw_line(Vector2(32,14),Vector2(32,32),light,4); draw_line(Vector2(32,32),Vector2(44,36),light,4)
			_r(4,45,24,8,steel)
			_r(10,40,8,18,accent)
		SiegeUpgrades.Kind.ORBITALS:
			draw_arc(Vector2(32,32),20,0,TAU,12,accent,2)
			for p: Vector2 in [Vector2(15,20),Vector2(49,44)]:
				_r(p.x-9,p.y-9,18,18,steel); _r(p.x-5,p.y-5,10,10,accent)
			_r(27,27,10,10,light)
		SiegeUpgrades.Kind.SLAM_SHIELD:
			_r(13,8,15,32,steel); _r(28,32,17,10,steel)
			_r(10,40,38,9,accent)
			for x: int in [14,28,42]: _r(x,48,5,7,light)
			draw_line(Vector2(3,59),Vector2(20,55),accent,3); draw_line(Vector2(38,56),Vector2(61,59),accent,3)
		SiegeUpgrades.Kind.REMOTE_CRANE:
			_r(8,8,10,47,steel); _r(10,8,44,8,accent)
			draw_line(Vector2(12,14),Vector2(41,14),light,2)
			draw_line(Vector2(48,17),Vector2(48,35),accent,3)
			_r(37,34,21,11,steel)
			draw_line(Vector2(43,46),Vector2(31,58),accent,2); draw_line(Vector2(51,46),Vector2(59,58),accent,2)
	draw_set_transform(Vector2.ZERO)
