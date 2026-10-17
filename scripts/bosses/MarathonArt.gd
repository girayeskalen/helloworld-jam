class_name MarathonArt
extends RefCounted
## Multi-part cel silhouettes drawn on the same low-resolution canvas as the apartment.
const OCEAN: Color = Color("133b55")
const WATER: Color = Color("25677e")
const FOAM: Color = Color("83f6e5")
const COAL: Color = Color("33282b")
const EMBER: Color = Color("ff6732")
const HOT: Color = Color("ffe5a0")

static func hydra(c: DisasterBoss, rig: Dictionary, root: Vector2) -> void:
	var t: float = rig["time"]
	var retreat: float = rig["retreat"]
	var roar: float = sin(float(rig["strike"])*PI)
	c.draw_set_transform(root)
	# Overlapping tide ribbons form one curling body rather than a rectangular sprite.
	for i: int in range(11):
		var y: float = -25-i*33.0
		var x: float = sin(t*2.1-i*.48)*(34+i*2)
		var width: float = 142-i*5.0
		CelArt.ellipse(c,Vector2(x,y),Vector2(width,36),OCEAN if i%2 == 0 else WATER,3.5)
		CelArt.ellipse(c,Vector2(x+width*.23,y+10),Vector2(width*.7,20),Color("102d43"),0)
		for strand: int in range(3):
			var flow: PackedVector2Array = PackedVector2Array()
			for step: int in range(7):
				flow.append(Vector2(x-width*.65+step*width*.2,y-6+strand*9+sin(step*.9+t*2+i)*6))
			c.draw_polyline(flow,Color("46baaF") if strand == 0 else Color("287d8f"),2.5)
		c.draw_arc(Vector2(x,y-8),width*.85,PI*.08,PI*.88,20,FOAM.darkened(.25),4)
	for i: int in range(3):
		var head: Vector2 = rig["heads"][i]
		var base: Vector2 = Vector2((i-1)*35,-235)
		var neck: PackedVector2Array = PackedVector2Array()
		for step: int in range(9):
			var p: Vector2 = base.lerp(head,step/8.0)
			p.x += sin(step*.5+t*2+i)*25*(1-step/10.0)
			neck.append(p)
		c.draw_polyline(neck,CelArt.INK,60,true)
		c.draw_polyline(neck,WATER,50,true)
		c.draw_polyline(neck,Color("388d9c"),18,true)
		c.draw_set_transform(root+head,sin(t*1.5+i)*.12+retreat*.8*(i-1))
		# Crest folds into a hooked wave jaw and ragged foam teeth.
		CelArt.poly(c,PackedVector2Array([Vector2(-57,12),Vector2(-65,-29),Vector2(-43,-63),Vector2(-12,-77),Vector2(33,-64),Vector2(60,-30),Vector2(49,-8),Vector2(26,-25),Vector2(2,-36),Vector2(-16,-17),Vector2(-6,13),Vector2(45,30),Vector2(26,56),Vector2(-22,49)]),OCEAN,4)
		CelArt.poly(c,PackedVector2Array([Vector2(-59,-22),Vector2(-40,-57),Vector2(-10,-69),Vector2(31,-56),Vector2(55,-29),Vector2(27,-36),Vector2(2,-48),Vector2(-29,-29)]),FOAM,3)
		# Hooked white foam fingers turn the crest into a breaking wave crown.
		for crest: int in range(6):
			var p: Vector2 = Vector2(-51+crest*17,-40-sin(crest*.5)*32)
			CelArt.poly(c,PackedVector2Array([p+Vector2(-7,6),p+Vector2(-8,-12),p+Vector2(1,-22),p+Vector2(13,-23),p+Vector2(6,-14),p+Vector2(6,2)]),Color("e9fff6"),1.5)
		c.draw_polyline(PackedVector2Array([Vector2(-45,18),Vector2(-43,-8),Vector2(-23,-33),Vector2(1,-44),Vector2(26,-31)]),Color("3293a7"),4,true)
		CelArt.poly(c,PackedVector2Array([Vector2(-26,8),Vector2(26,3),Vector2(44,26+roar*18),Vector2(-6,29+roar*18)]),Color("0b222e"),3)
		for tooth: int in range(4):
			CelArt.poly(c,PackedVector2Array([Vector2(-20+tooth*14,9),Vector2(-8+tooth*14,7),Vector2(-12+tooth*14,23)]),Color("caf9e8"),1.5)
		c.draw_circle(Vector2(-27,-18),18,Color(FOAM,.18))
		CelArt.ellipse(c,Vector2(-27,-18),Vector2(11,5),Color("dafff2"),2)
		c.draw_line(Vector2(-26,-22),Vector2(-28,-15),Color("12374d"),3)
		c.draw_set_transform(root)
	# Two foam talons and orbital whirlpools with floating timber/steel.
	for side: float in [-1.0,1.0]:
		var hand: Vector2 = Vector2(side*(125+sin(t*2+side)*15),-190+sin(t*3+side)*24)
		CelArt.line(c,Vector2(side*65,-260),hand,OCEAN,35)
		for finger: int in range(3):
			var tip: Vector2 = hand+Vector2(side*(20+finger*9),-30+finger*22)
			CelArt.line(c,hand,tip,FOAM,9)
	for i: int in range(10):
		var a: float = t*(.7+i%2*.4)+i*TAU/10
		var p: Vector2 = Vector2(cos(a)*145,-180+sin(a)*155)
		if i%3 == 0:
			c.draw_arc(p,19,a,a+PI*1.6,16,FOAM,3)
		else:
			c.draw_set_transform(root+p,a)
			if i%2 == 0:
				CelArt.box(c,Rect2(-17,-5,34,10),Color("9d805d"),Vector2(3,-3))
				c.draw_line(Vector2(-12,-2),Vector2(11,0),Color("534d40"),2)
			else:
				CelArt.box(c,Rect2(-11,-15,22,30),Color("597c81"),Vector2(4,-3))
				for band: float in [-9.0,8.0]: CelArt.line(c,Vector2(-11,band),Vector2(11,band),Color("bac7b5"),3)
	c.draw_set_transform(root)
	for i: int in range(20):
		var p: Vector2 = Vector2(sin(t*1.6+i*2.4)*(140-i%3*20),-fposmod(t*130+i*61,510))
		c.draw_rect(Rect2(p,Vector2(4+i%3,5+i%2*3)),Color(FOAM,.75))
	c.draw_set_transform(Vector2.ZERO)

static func flame(c: CanvasItem, base: Vector2, height: float, width: float, clock: float, color: Color) -> void:
	var sway: float = sin(clock)*width*.45
	CelArt.poly(c,PackedVector2Array([base+Vector2(-width,0),base+Vector2(-width*.8,-height*.35),base+Vector2(-width*.4,-height*.23),base+Vector2(sway,-height),base+Vector2(width*.36,-height*.42),base+Vector2(width*.72,-height*.65),base+Vector2(width,0)]),color,3)
	CelArt.poly(c,PackedVector2Array([base+Vector2(-width*.42,-2),base+Vector2(sway*.5,-height*.65),base+Vector2(width*.45,-2)]),HOT,1.5)

static func titan(c: DisasterBoss, rig: Dictionary, root: Vector2) -> void:
	var t: float = rig["time"]
	var hot: Color = Color("fff3df") if rig["enrage"] else HOT
	var ember: Color = Color("ff3a2c") if rig["enrage"] else EMBER
	var retreat: float = rig["retreat"]
	var charge: float = rig["charge"]
	var roar: float = sin(float(rig["strike"])*PI)
	var opening: float = (.4 + charge*.6 + roar*.2) if rig["helix"] else charge*.15
	c.draw_set_transform(root)
	CelArt.ellipse(c,Vector2(0,-8),Vector2(130,20),Color(ember,.14),0)
	# A continuous shoulder mantle breathes behind the articulated arms.
	for i: int in range(7):
		var p: Vector2 = Vector2(-94+i*30,-327+absf(3-i)*7)
		flame(c,p,105+sin(t*5+i)*17,24,t*6+i,Color("c43b2a"))
	# Four independently articulated flame arms / wings.
	for i: int in range(4):
		var side: float = -1.0 if i%2 == 0 else 1.0
		var shoulder: Vector2 = Vector2(side*65,-290-(i/2)*72)
		var hand: Vector2 = rig["arms"][i]
		hand += Vector2(side*(retreat*35+roar*20),retreat*90-charge*35)
		var elbow: Vector2 = shoulder.lerp(hand,.5)+Vector2(side*24,25*sin(t+i))
		CelArt.line(c,shoulder,elbow,CelArt.INK,38)
		CelArt.line(c,elbow,hand,CelArt.INK,32)
		CelArt.line(c,shoulder,elbow,COAL,29)
		CelArt.line(c,elbow,hand,ember,19)
		flame(c,hand,95+i%2*20+charge*25+roar*25,25,t*7+i,ember)
	for side: float in [-1.0,1.0]:
		flame(c,Vector2(side*50,-15),140,38,t*5+side,ember)
		CelArt.box(c,Rect2(side*38-22,-180,44,100),COAL,Vector2(9,-10))
	# Layered charred armour, split by a continuous hot magma heart.
	CelArt.poly(c,PackedVector2Array([Vector2(-82,-395),Vector2(-38,-428),Vector2(48,-419),Vector2(89,-373),Vector2(64,-206),Vector2(25,-147),Vector2(-43,-164),Vector2(-78,-255)]),Color("261c22"),4)
	for row: int in range(4):
		for side: float in [-1.0,1.0]:
			var offset: Vector2 = Vector2(side*(9+retreat*80+opening*22),-391+row*53+sin(t*1.7+row)*4)
			CelArt.poly(c,PackedVector2Array([offset+Vector2(side*6,0),offset+Vector2(side*57,-10),offset+Vector2(side*66,23),offset+Vector2(side*36,53),offset+Vector2(side*8,37)]),Color("59403c") if row%2 == 0 else COAL,3)
			CelArt.poly(c,PackedVector2Array([offset+Vector2(side*57,-10),offset+Vector2(side*66,23),offset+Vector2(side*36,53),offset+Vector2(side*31,26)]),Color("201e24"),1.5)
			CelArt.line(c,offset+Vector2(side*14,8),offset+Vector2(side*49,4),Color("a76b54"),3)
			c.draw_polyline(PackedVector2Array([offset+Vector2(side*16,35),offset+Vector2(side*30,21),offset+Vector2(side*39,29),offset+Vector2(side*48,16)]),ember,2,true)
			for pore: int in range(4):
				c.draw_rect(Rect2(offset+Vector2(side*(16+pore*9),10+pore%2*14),Vector2(4,3)),Color("181d23"))
	var seam: PackedVector2Array = PackedVector2Array([Vector2(0,-412),Vector2(-14,-363),Vector2(8,-326),Vector2(-8,-281),Vector2(11,-232),Vector2(-2,-188)])
	c.draw_polyline(seam,Color(ember,.25),24,true)
	c.draw_polyline(seam,ember,10,true)
	c.draw_polyline(seam,hot,4,true)
	CelArt.ellipse(c,Vector2(0,-330),Vector2(22+opening*13,31+opening*16+sin(t*3)*5),hot,3)
	# Crown, hollow black jaw and swept flame horns.
	var head: Vector2 = Vector2(sin(t*1.8)*5,-465-retreat*50)
	for side: float in [-1.0,1.0]:
		flame(c,head+Vector2(side*42,3),93,23,t*6+side,ember)
		flame(c,Vector2(side*82,-350),98,31,t*4+side,ember)
	CelArt.poly(c,PackedVector2Array([head+Vector2(-45,-40),head+Vector2(-12,-57),head+Vector2(38,-43),head+Vector2(52,-3),head+Vector2(29,43),head+Vector2(-27,43),head+Vector2(-49,4)]),COAL,4)
	for side: float in [-1.0,1.0]:
		var eye: Vector2 = head+Vector2(side*23,-5)
		CelArt.line(c,eye+Vector2(-12,-5*side),eye+Vector2(12,5*side),hot,6)
		CelArt.line(c,eye+Vector2(-15,-17*side),eye+Vector2(14,-7*side),CelArt.INK,7)
	CelArt.poly(c,PackedVector2Array([head+Vector2(-23,15),head+Vector2(22,15),head+Vector2(16,32+roar*18),head+Vector2(-16,32+roar*18)]),Color("180d13"),3)
	for tooth: int in range(4):
		var tip: Vector2 = head+Vector2(-16+tooth*10,17)
		CelArt.poly(c,PackedVector2Array([tip,tip+Vector2(7,0),tip+Vector2(4,9+roar*4)]),hot,1)
	for i: int in range(28):
		var rise: float = fposmod(t*(80+i%4*17)+i*73,570)
		var angle: float = i*2.4+t*2.2+rise*.012
		var p: Vector2 = Vector2(cos(angle)*(105+rise*.09),-rise)
		c.draw_line(p,p+Vector2(-cos(angle)*4,7),Color(ember,.45),2)
		c.draw_rect(Rect2(p,Vector2(3+i%3,5+i%4)),Color(hot,.6+i%3*.1))
	c.draw_set_transform(Vector2.ZERO)

static func projectile(p: HazardProjectile) -> void:
	var a: HazardAttack = p.attack
	var color: Color = FOAM if a.source == 2 else EMBER
	if a.is_area():
		for world_area: Rect2 in a.area_segments():
			var area: Rect2 = Rect2(world_area.position-p.global_position,world_area.size)
			if a.kind == HazardAttack.Kind.WHIRLPOOL:
				for i: int in range(5):
					p.draw_set_transform(Vector2.ZERO,0,Vector2(1,.32))
					p.draw_arc(Vector2.ZERO,32+i*26,p.age*5+i,p.age*5+i+PI*1.4,28,Color(color,.5),5)
			else:
				var fade: float = clampf((a.lifetime-p.age)*4,0,1)
				p.draw_rect(area,Color(OCEAN if a.source == 2 else Color("70211a"),.75*fade))
				for i: int in range(int(area.size.x/34)):
					var base: Vector2 = Vector2(area.position.x+i*34,area.end.y)
					if a.source == 3: flame(p,base,22+sin(p.age*11+i)*10,14,p.age*9+i,Color(color,fade))
					else:
						p.draw_arc(base+Vector2(0,-18),19,PI*.95,TAU,10,Color(color,fade),5)
						p.draw_line(base+Vector2(-8,-7),base+Vector2(13,-11),Color("d2fff2"),3)
		p.draw_set_transform(Vector2.ZERO)
		return
	if a.is_wall():
		for i: int in range(7):
			var y: float = -a.row_height*.5+i*a.row_height/7
			if a.source == 2:
				CelArt.ellipse(p,Vector2(sin(p.age*20+i)*7,y),Vector2(27,24),WATER,3)
				p.draw_arc(Vector2(7,y-8),22,PI,TAU+1,12,FOAM,5)
			else: flame(p,Vector2(-10,y+20),45,24,p.age*20+i,EMBER)
		return
	p.draw_set_transform(Vector2.ZERO,p.age*5 if a.kind != HazardAttack.Kind.HARPOON else a.velocity.angle())
	if p.custom_sprite != null:
		p.draw_texture_rect(p.custom_sprite,Rect2(Vector2.ONE*-a.radius,Vector2.ONE*a.radius*2),false)
	elif a.kind == HazardAttack.Kind.FLOATING_DEBRIS:
		match a.floor_index % 3:
			0:
				CelArt.box(p,Rect2(-18,-13,36,26),Color("746d4b"),Vector2(4,-4))
				for x: float in [-11.0,11.0]: CelArt.line(p,Vector2(x,-12),Vector2(x,12),Color("b7c2b2"),4)
			1:
				CelArt.box(p,Rect2(-25,-7,50,14),Color("96734f"),Vector2(3,-3))
				CelArt.ellipse(p,Vector2(25,0),Vector2(5,8),Color("c5a27b"),2)
			_:
				p.draw_polyline(PackedVector2Array([Vector2(-26,-4),Vector2(-12,8),Vector2(4,-7),Vector2(26,5)]),CelArt.INK,8)
				p.draw_polyline(PackedVector2Array([Vector2(-26,-4),Vector2(-12,8),Vector2(4,-7),Vector2(26,5)]),FOAM,3)
	elif a.kind == HazardAttack.Kind.HARPOON:
		CelArt.poly(p,PackedVector2Array([Vector2(-27,-3),Vector2(9,-4),Vector2(15,-10),Vector2(29,0),Vector2(15,10),Vector2(9,4),Vector2(-27,3)]),FOAM,2.5)
	elif a.source == 2:
		CelArt.ellipse(p,Vector2.ZERO,Vector2.ONE*a.radius,WATER,3)
		p.draw_arc(Vector2.ZERO,a.radius*.75,p.age*5,p.age*5+PI*1.4,20,FOAM,4)
		if a.kind == HazardAttack.Kind.WATER_BLADE:
			for i: int in range(4):
				var d: Vector2 = Vector2.from_angle(i*PI*.5)
				CelArt.line(p,d*14,d*30,FOAM,5)
	else:
		flame(p,Vector2(0,a.radius*.6),a.radius*2,a.radius,p.age*13,EMBER)
		if a.kind == HazardAttack.Kind.METEOR:
			CelArt.poly(p,PackedVector2Array([Vector2(-15,-12),Vector2(8,-19),Vector2(20,2),Vector2(9,17),Vector2(-17,13)]),COAL,3)
			p.draw_line(Vector2(-9,-5),Vector2(11,6),HOT,4)
	p.draw_set_transform(Vector2.ZERO)
	p.draw_circle(Vector2.ZERO,3.5,Color("fff6d5"))
