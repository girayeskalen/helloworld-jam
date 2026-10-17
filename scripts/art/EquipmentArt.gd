class_name EquipmentArt
extends RefCounted
## Shared silhouettes keep dropped equipment, HUD and installed protection consistent.
static func draw_kit(c: CanvasItem, kind: int, clock: float = 0.0) -> void:
	match kind:
		LootSystem.Kind.COLUMN_KIT:
			CelArt.box(c,Rect2(-12,-17,24,34),Color("526675"),Vector2(5,-4))
			for y: float in [-12.0,-4.0,4.0,12.0]:
				CelArt.rect(c,Rect2(-13,y,26,4),Color("242c35"),1)
				CelArt.line(c,Vector2(-9,y),Vector2(10,y+3),Color("87938e"),1)
			for side: float in [-1.0,1.0]:
				CelArt.line(c,Vector2(side*11,-15),Vector2(-side*11,15),CelArt.INK,6)
				CelArt.line(c,Vector2(side*11,-15),Vector2(-side*11,15),Color("ffc15b"),3)
			for y: float in [-13.0,13.0]: CelArt.bolt(c,Vector2(0,y),Color("fff0b8"))
		LootSystem.Kind.BARRICADE_KIT:
			CelArt.box(c,Rect2(-14,-17,26,28),Color("5c86a3"),Vector2(4,-4))
			for y: float in [-12.0,-5.0,2.0]: CelArt.line(c,Vector2(-11,y),Vector2(9,y),Color("b2d6e3"),2)
			var l: PackedVector2Array = PackedVector2Array([Vector2(2,-11),Vector2(2,15),Vector2(20,15)])
			c.draw_polyline(l,CelArt.INK,8)
			c.draw_polyline(l,Color("7dd4ff"),4)
			CelArt.bolt(c,Vector2(2,-6),Color.WHITE)
			CelArt.bolt(c,Vector2(14,15),Color.WHITE)
			CelArt.box(c,Rect2(-18,9,20,8),Color("c3b591"),Vector2(2,-2))
		LootSystem.Kind.EMERGENCY_BAG:
			CelArt.rect(c,Rect2(-6,-21,12,7),Color("354c49"),2)
			CelArt.box(c,Rect2(-15,-14,30,31),Color("43886c"),Vector2(4,-3))
			CelArt.rect(c,Rect2(-11,-9,22,20),Color("b7d3b7"),2)
			CelArt.rect(c,Rect2(-3,-7,6,16),Color("32a96e"),0)
			CelArt.rect(c,Rect2(-8,-2,16,6),Color("32a96e"),0)
			CelArt.box(c,Rect2(15,-8,7,20),Color("8ec4cf"),Vector2(2,-2))
			CelArt.line(c,Vector2(18,-12),Vector2(18,-7),Color("d6e8ce"),4)
		LootSystem.Kind.SAFETY_KIT:
			CelArt.ellipse(c,Vector2(-4,0),Vector2(11,17),Color("cc4f37"),2)
			CelArt.rect(c,Rect2(-13,-10,18,23),Color("e36b44"),2)
			CelArt.rect(c,Rect2(-10,-5,12,10),Color("e7dfc5"),1)
			CelArt.line(c,Vector2(-6,-17),Vector2(3,-17),Color("535b5c"),5)
			c.draw_polyline(PackedVector2Array([Vector2(4,-16),Vector2(14,-14),Vector2(17,5)]),CelArt.INK,5)
			CelArt.ellipse(c,Vector2(16,7),Vector2(8,8),Color("a6b8b3"),2)
			for i: int in range(4):
				var d: Vector2 = Vector2.from_angle(clock*.5+i*PI*.5)*6
				CelArt.line(c,Vector2(16,7),Vector2(16,7)+d,Color("f7b36f"),2)

static func draw_carbon_wrap(c: CanvasItem, size: Vector2) -> void:
	for x: float in [0.0,size.x-25]:
		CelArt.rect(c,Rect2(x,33,25,size.y-72),Color("232a34"),2)
		for y: int in range(35,int(size.y)-38,8):
			for i: int in range(3):
				var p: Vector2 = Vector2(x+i*8,y+(i%2)*3)
				CelArt.line(c,p,p+Vector2(6,5),Color("657982"),1.5)
		for y: float in [42.0,size.y-48]:
			CelArt.rect(c,Rect2(x-2,y,29,7),Color("e4af55"),1.5)

static func draw_safety_installation(c: CanvasItem, size: Vector2, clock: float) -> void:
	var p: Vector2 = Vector2(size.x-58,43)
	CelArt.line(c,Vector2(75,28),p,Color("718997"),4)
	CelArt.ellipse(c,p,Vector2(18,7),Color("cad6cd"),2)
	c.draw_circle(p+Vector2(10,-2),3,Color("64efa5"))
	for i: int in range(3):
		var x: float = 65+i*(size.x-120)/2
		CelArt.rect(c,Rect2(x-6,25,12,8),Color("bed8d6"),2)
		CelArt.line(c,Vector2(x,33),Vector2(x,40),Color("ffbc70"),3)
	# Equipment installation is an explicit game abstraction, not a real retrofit diagram.
	CelArt.box(c,Rect2(size.x-57,size.y-74,27,44),Color("ac4936"),Vector2(4,-3))
	CelArt.ellipse(c,Vector2(size.x-44,size.y-78),Vector2(10,10),Color("df9a5c"),2)
	c.draw_circle(Vector2(size.x-44,size.y-78),3,Color("76efae"))
