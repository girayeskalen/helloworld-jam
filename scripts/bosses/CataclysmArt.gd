class_name CataclysmArt
extends RefCounted
## Three disasters fused into one silhouette: storm, earthquake and flood.
## back():   basalt body, storm-vortex left arm, rock right claw and tide base
##           (drawn behind the apartment, so only parts outside the facade show).
## front():  pauldrons, roaring basalt head and foam/lightning crown over the roof.
## fusion(): the 2.8-second entry in which three energies collide.

const INK: Color = Color("111518")
const BASALT: Color = Color("4b504a")
const BASALT_LIGHT: Color = Color("6e7266")
const BASALT_DARK: Color = Color("2f3532")
const FLOW: Color = Color("51c4d5")
const FOAM_LIGHT: Color = Color("d6fff7")
const ELECTRIC: Color = Color("8fd8ff")
const STORM_DARK: Color = Color("2b3a46")
const STORM_MID: Color = Color("3a4d5a")
const QUAKE: Color = Color("d8a46a")
## Storm, quake and flood: the order of attack sources.
const ELEMENTS: Array[Color] = [Color("8fd8ff"), Color("a4b2b5"), Color("55f2e2")]
## Crown tips rise at most this far above the head centre (framing tests use it).
const CROWN_TOP: float = 140.0
const HEAD_SCALE: float = 1.35
const FUSION_CENTER: Vector2 = Vector2(0, -600)
## Storm arrives from the left sky, quake from the right, flood from below.
const FUSION_STARTS: Array[Vector2] = [Vector2(-1420, -1000), Vector2(1420, -330), Vector2(0, 180)]

static func back(c: DisasterBoss, rig: Dictionary, root: Vector2) -> void:
	var t: float = rig["time"]
	var over: float = rig["overload"]
	var flow: Color = FLOW.lerp(Color("fff1d0"), over * .55)
	c.draw_set_transform(root + Vector2(rig["anchor"]))
	_swell(c, t)
	c.draw_set_transform(root)
	_torso(c, rig, flow)
	_vortex_arm(c, rig, root, t, over)
	_rock_arm(c, rig, root, t, flow)
	_crests(c, rig, root + Vector2(rig["anchor"]), t)
	c.draw_set_transform(Vector2.ZERO)

static func front(c: Node2D, rig: Dictionary, root: Vector2) -> void:
	var t: float = rig["time"]
	var over: float = rig["overload"]
	var flow: Color = FLOW.lerp(Color("fff1d0"), over * .55)
	c.draw_set_transform(root)
	_pauldron(c, rig["shoulder_l"], -1.0, t, flow)
	_pauldron(c, rig["shoulder_r"], 1.0, t, flow)
	_head(c, rig, root, t, flow, over)
	c.draw_set_transform(root + Vector2(rig["anchor"]))
	# Foam licks along the plinth: the tide also besieges the base line.
	for i: int in range(9):
		var x: float = -820.0 + i * 204.75
		var h: float = 9.0 + sin(t * 2.4 + i * 1.3) * 5.0
		c.draw_arc(Vector2(x, -2), 16.0 + h * .4, PI * 1.05, TAU - .1, 10, INK, 6.0)
		c.draw_arc(Vector2(x, -2), 16.0 + h * .4, PI * 1.05, TAU - .1, 10, Color("d8fff4"), 3.0)
	c.draw_set_transform(Vector2.ZERO)

# ------------------------------------------------------------------ back ----

## Two ocean swells rise and fall beside the facade, plus spray behind the roof.
static func _swell(c: CanvasItem, t: float) -> void:
	for side: float in [-1.0, 1.0]:
		var top: PackedVector2Array = PackedVector2Array()
		for i: int in range(8):
			top.append(Vector2(side * (785.0 + i * (480.0/7.0)), -250.0 - sin(t * 1.3 + i * .6 + side) * 42.0 - (i % 3) * 14.0))
		var body: PackedVector2Array = top.duplicate()
		body.append(Vector2(side * 1290.0, 10))
		body.append(Vector2(side * 785.0, 10))
		CelArt.poly(c, body, MarathonArt.OCEAN, 4.0)
		var band: PackedVector2Array = PackedVector2Array()
		for p: Vector2 in top: band.append(p + Vector2(0, 26))
		c.draw_polyline(band, MarathonArt.WATER, 18.0, false)
		c.draw_polyline(top, MarathonArt.FOAM.darkened(.2), 4.0, false)
		for i: int in range(4):
			var flow: PackedVector2Array = PackedVector2Array()
			for step: int in range(4):
				flow.append(Vector2(side * (805.0 + step * 120.0), -170.0 + i * 50.0 + sin(step * .9 + t * 2.0 + i) * 7.0))
			c.draw_polyline(flow, Color("287d8f") if i % 2 == 0 else Color("46baaf"), 2.5)
	# Spray fans behind the roof coping: only their crests clear the parapet.
	for i: int in range(5):
		var x: float = -620.0 + i * 310.0
		var h: float = 34.0 + sin(t * 2.1 + i * 1.7) * 22.0
		c.draw_arc(Vector2(x, -940), 26.0 + h * .5, PI * 1.1, TAU - .2, 12, INK, 9.0)
		c.draw_arc(Vector2(x, -940), 26.0 + h * .5, PI * 1.1, TAU - .2, 12, MarathonArt.FOAM, 4.0)

## Basalt chest behind the roof: its rim-lit collar clears the parapet and both
## flanks show between the facade and the arms, tying the limbs to one body.
static func _torso(c: CanvasItem, rig: Dictionary, flow: Color) -> void:
	var head: Vector2 = rig["head"]
	var l: Vector2 = rig["shoulder_l"]
	var r: Vector2 = rig["shoulder_r"]
	var outline: PackedVector2Array = PackedVector2Array([l + Vector2(-80, -36), head + Vector2(-170, 18), head + Vector2(170, 18), r + Vector2(80, -36), Vector2(905, -860), Vector2(925, -640), Vector2(885, -420), Vector2(720, -300), Vector2(-720, -300), Vector2(-885, -420), Vector2(-925, -640), Vector2(-905, -860)])
	CelArt.poly(c, outline, BASALT_DARK, 5.0)
	# Cel split: a lit left flank (storm glow) and a dark right flank (magma glow).
	CelArt.poly(c, PackedVector2Array([Vector2(-905, -860), Vector2(-925, -640), Vector2(-885, -420), Vector2(-800, -380), Vector2(-820, -700), Vector2(-815, -900)]), Color("3d4542"), 0.0)
	for side: float in [-1.0, 1.0]:
		for i: int in range(6):
			var p: Vector2 = Vector2(side * (842.0 + (i % 2) * 44.0), -860.0 + i * 90.0)
			CelArt.poly(c, PackedVector2Array([p + Vector2(-side * 34, -30), p + Vector2(side * 22, -38), p + Vector2(side * 40, -4), p + Vector2(side * 24, 32), p + Vector2(-side * 30, 28)]), BASALT if i % 3 == 0 else (Color("3f4540") if i % 3 == 1 else Color("454b45")), 3.0)
			c.draw_line(p + Vector2(-side * 22, -22), p + Vector2(side * 18, -28), BASALT_LIGHT, 2.5)
			if i % 2 == 1:
				c.draw_polyline(PackedVector2Array([p + Vector2(-side * 10, -10), p + Vector2(side * 4, 4), p + Vector2(-side * 6, 18)]), flow, 2.0, false)
		var rim: PackedVector2Array = PackedVector2Array([Vector2(side * 905, -860), Vector2(side * 925, -640), Vector2(side * 885, -420)])
		c.draw_polyline(rim, Color(ELECTRIC if side < 0.0 else flow, .35), 14.0, false)
		c.draw_polyline(rim, ELECTRIC if side < 0.0 else flow, 3.0, false)
		var vein: PackedVector2Array = PackedVector2Array([Vector2(side * 840, -900), Vector2(side * 878, -760), Vector2(side * 846, -640), Vector2(side * 890, -520), Vector2(side * 860, -400)])
		c.draw_polyline(vein, INK, 7.0, false)
		c.draw_polyline(vein, flow, 3.0, false)
	for i: int in range(5):
		var x: float = -540.0 + i * 270.0
		var p: Vector2 = Vector2(x, -978.0 + absf(i - 3) * 5.0)
		CelArt.poly(c, PackedVector2Array([p + Vector2(-70, 4), p + Vector2(-48, -24), p + Vector2(46, -26), p + Vector2(72, 2), p + Vector2(54, 30), p + Vector2(-56, 30)]), BASALT if i % 2 == 0 else Color("3f4540"), 3.0)
		c.draw_line(p + Vector2(-40, -16), p + Vector2(38, -18), BASALT_LIGHT, 3.0)
	var collar: PackedVector2Array = PackedVector2Array([l + Vector2(-80, -36), head + Vector2(-170, 18), head + Vector2(170, 18), r + Vector2(80, -36)])
	c.draw_polyline(collar, Color(flow, .4), 12.0, false)
	c.draw_polyline(collar, FOAM_LIGHT, 2.5, false)
	var crack: PackedVector2Array = PackedVector2Array([l + Vector2(-60, -10), Vector2(-430, -968), Vector2(-250, -952), Vector2(-90, -972), head + Vector2(0, 40), Vector2(110, -970), Vector2(280, -950), Vector2(460, -969), r + Vector2(60, -10)])
	c.draw_polyline(crack, Color(flow, .28), 16.0, false)
	c.draw_polyline(crack, INK, 7.0, false)
	c.draw_polyline(crack, flow, 3.0, false)

## Left arm: a storm funnel spine of spinning cloud rings with lightning blades.
static func _vortex_arm(c: CanvasItem, rig: Dictionary, root: Vector2, t: float, over: float) -> void:
	var rings: Array = rig["vortex"]
	var wind: float = rig["wind"]
	# Continuous cloud sleeve preserves the arm silhouette with six large rings.
	var sleeve: PackedVector2Array = PackedVector2Array()
	for ring: Dictionary in rings: sleeve.append(Vector2(ring["center"])+Vector2(-float(ring["width"]),0))
	for i: int in range(rings.size()-1,-1,-1): sleeve.append(Vector2(rings[i]["center"])+Vector2(float(rings[i]["width"]),0))
	CelArt.poly(c,sleeve,STORM_DARK,3.0)
	for i: int in range(rings.size()):
		var center: Vector2 = rings[i]["center"]
		var w: float = rings[i]["width"]
		var color: Color = STORM_DARK if i % 2 == 0 else STORM_MID
		CelArt.poly(c, PackedVector2Array([center + Vector2(-w, -14), center + Vector2(-w * .72, -34), center + Vector2(w * .63, -38), center + Vector2(w, -16), center + Vector2(w * .86, 10), center + Vector2(-w * .5, 22)]), color, 3.0)
		CelArt.ellipse(c, center + Vector2(0, -18), Vector2(w * .9, 14), color.lightened(.14), 2.0)
		var ribbon: float = sin(float(rings[i]["spin"])) * w * .7
		c.draw_line(center + Vector2(ribbon - 14, -20), center + Vector2(ribbon + 16, -23), Color("9fb4bd"), 3.0)
		c.draw_line(center + Vector2(-w * .7, 4), center + Vector2(w * .66, -3), Color("6f8995"), 3.0)
		for side: float in [-1.0, 1.0]:
			CelArt.poly(c, PackedVector2Array([center + Vector2(side * w * .7, -8), center + Vector2(side * (w + 16), -22), center + Vector2(side * (w - 6), 4)]), Color("809eaa"), 1.5)
		if wind > .05 or over > 0.0:
			c.draw_arc(center + Vector2(0, -18), w * .9, PI, TAU, 14, Color(ELECTRIC, .55 * maxf(wind, over)), 2.0)
	# Electric arcs crawl between funnel rings.
	var frame: int = int(t * 14.0)
	for k: int in range(3 + int(over * 2.0)):
		var a: int = (frame * 7 + k * 5) % (rings.size() - 3) + 1
		var from: Vector2 = Vector2(rings[a]["center"]) + Vector2(float(rings[a]["width"]) * .7, -12)
		var to: Vector2 = Vector2(rings[a + 2]["center"]) + Vector2(-float(rings[a + 2]["width"]) * .5, -14)
		var bolt: PackedVector2Array = PackedVector2Array([from])
		for step: int in range(1, 5):
			bolt.append(from.lerp(to, step / 5.0) + Vector2(sin(frame * 3.1 + step * 2.3 + k) * 14.0, cos(frame * 2.7 + step) * 7.0))
		bolt.append(to)
		c.draw_polyline(bolt, Color(.35, .65, 1.0, .35), 9.0, false)
		c.draw_polyline(bolt, Color(.88, .97, 1.0, .95), 2.5, false)
	# Lightning blades orbit the vortex fist.
	var tip: Vector2 = rig["tip"]
	for i: int in range(3):
		c.draw_circle(tip + Vector2(0, -20), 52.0 - i * 15.0, Color(ELECTRIC, .08 + i * .1))
	for k: int in range(3):
		var a: float = t * 4.2 + k * TAU / 3.0
		var p: Vector2 = tip + Vector2(cos(a) * 78.0, sin(a) * 36.0 - 20.0)
		var d: Vector2 = Vector2.from_angle(a + PI * .5)
		var n: Vector2 = d.orthogonal()
		CelArt.poly(c, PackedVector2Array([p - d * 34 + n * 4, p - d * 6 - n * 12, p + d * 38 - n * 3, p + d * 4 + n * 5]), Color("d9f4ff"), 2.0)
		c.draw_line(p - d * 18, p + d * 26, ELECTRIC, 2.0)
	c.draw_arc(tip + Vector2(0, -20), 24.0, t * 3.0, t * 3.0 + PI * 1.6, 18, ELECTRIC, 3.0)
	CelArt.ellipse(c, tip + Vector2(0, -20), Vector2(9, 13), Color("dbf8ff"), 1.5)
	for i: int in range(5):
		var a: float = t * (1.8 + i % 3 * .2) + i * 2.4
		var center: Vector2 = Vector2(rings[(i * 3) % rings.size()]["center"])
		var w: float = float(rings[(i * 3) % rings.size()]["width"]) + 14.0
		c.draw_set_transform(root + Vector2(center.x + cos(a) * w, center.y - 16 + sin(a) * 12), a)
		CelArt.poly(c, PackedVector2Array([Vector2(-8, 0), Vector2(0, -5), Vector2(10, 1), Vector2(1, 5)]), Color("7d6d48") if i % 2 == 0 else Color("566b5e"), 2.0)
	c.draw_set_transform(root)

## Right arm: charred basalt bones with magma veins, a talon claw and flow balls.
static func _rock_arm(c: CanvasItem, rig: Dictionary, root: Vector2, t: float, flow: Color) -> void:
	var s: Vector2 = rig["shoulder_r"]
	var e: Vector2 = rig["elbow"]
	var w: Vector2 = rig["claw"]
	CelArt.line(c, s, e, INK, 108.0)
	CelArt.line(c, s, e, BASALT_DARK, 92.0)
	CelArt.line(c, s + Vector2(-6, -14), e + Vector2(-6, -14), Color("3f4540"), 30.0)
	CelArt.line(c, e, w, INK, 90.0)
	CelArt.line(c, e, w, Color("293e47"), 76.0)
	for i: int in range(3):
		_rock(c, s.lerp(e, .3 + i * .25) + Vector2(0, -20), Vector2(30, 24), BASALT if i % 2 == 0 else Color("45515a"))
	var vein: PackedVector2Array = PackedVector2Array([s.lerp(e, .1) + Vector2(0, -8), s.lerp(e, .4) + Vector2(7, 7), s.lerp(e, .72) + Vector2(-6, -4), e, e.lerp(w, .35) + Vector2(6, 6), e.lerp(w, .7) + Vector2(-5, -3), w])
	c.draw_polyline(vein, Color(flow, .3), 15.0, false)
	c.draw_polyline(vein, INK, 7.0, false)
	c.draw_polyline(vein, flow, 3.5, false)
	for i: int in range(4):
		_spray(c, e.lerp(w, .15 + i * .2) + Vector2(0, -24), 48.0 + sin(t * 6.0 + i) * 12.0, 15.0, t * 7.0 + i, flow)
	_rock(c, e, Vector2(48, 40), BASALT)
	_rock(c, s + Vector2(30, 70), Vector2(40, 34), Color("3f4540"))
	c.draw_set_transform(root + w, (w - e).angle() - PI * .5)
	CelArt.poly(c, PackedVector2Array([Vector2(-46, -30), Vector2(-20, -50), Vector2(28, -48), Vector2(50, -22), Vector2(44, 26), Vector2(-40, 30)]), Color("293e47"), 4.0)
	c.draw_polyline(PackedVector2Array([Vector2(-26, -34), Vector2(-6, -8), Vector2(-16, 18)]), flow, 3.0, false)
	for f: int in range(4):
		var base: Vector2 = Vector2(-36 + f * 24, 22)
		var hook: float = -1.0 if f < 2 else 1.0
		var talon: PackedVector2Array = PackedVector2Array([base + Vector2(-10, 0), base + Vector2(10, 0), base + Vector2(8 + hook * 6, 34), base + Vector2(hook * 16, 58), base + Vector2(-4 + hook * 4, 36)])
		CelArt.poly(c, talon, Color("4d626c"), 3.0)
		c.draw_line(base + Vector2(0, 6), base + Vector2(hook * 12, 50), FOAM_LIGHT, 3.0)
	c.draw_set_transform(root)
	for ball: Vector2 in rig["flow"]:
		c.draw_circle(ball, 26.0, Color(flow, .22))
		CelArt.ellipse(c, ball, Vector2(17, 17), Color("257f9c"), 3.0)
		c.draw_circle(ball + Vector2(-4, -4), 7.0, FOAM_LIGHT)
		c.draw_rect(Rect2(ball + Vector2(4, 3), Vector2(6, 4)), Color("5a2318"))

## Curling crests and two whirlpools ride the swells.
static func _crests(c: CanvasItem, rig: Dictionary, root: Vector2, t: float) -> void:
	for crest: Vector3 in rig["crests"]:
		var p: Vector2 = Vector2(crest.x, crest.y)
		var side: float = signf(crest.x)
		CelArt.ellipse(c, p, Vector2(56, 26), MarathonArt.WATER, 3.0)
		c.draw_arc(p + Vector2(0, -6), 44.0, PI * 1.05, TAU - .05, 14, MarathonArt.FOAM, 5.0)
		CelArt.poly(c, PackedVector2Array([p + Vector2(-side * 30, -22), p + Vector2(side * 4, -40), p + Vector2(side * 36, -30), p + Vector2(side * 22, -16), p + Vector2(side * 4, -24)]), Color("e9fff6"), 1.5)
	for side: float in [-1.0, 1.0]:
		var eye: Vector2 = Vector2(side * 1015.0, -105.0 + sin(t * 1.5 + side) * 14.0)
		for i: int in range(4):
			c.draw_set_transform(root + eye, 0, Vector2(1, .38))
			c.draw_arc(Vector2.ZERO, 26.0 + i * 24.0, t * 4.0 * side + i, t * 4.0 * side + i + PI * 1.3, 22, INK, 8.0)
			c.draw_arc(Vector2.ZERO, 26.0 + i * 24.0, t * 4.0 * side + i, t * 4.0 * side + i + PI * 1.3, 22, MarathonArt.FOAM if i % 2 == 0 else Color("46baaf"), 4.0)
		c.draw_set_transform(root)
		for i: int in range(10):
			var d: Vector2 = Vector2(side * (820.0 + fposmod(t * 90.0 + i * 47.0, 400.0)), -fposmod(t * 140.0 + i * 61.0, 330.0))
			c.draw_rect(Rect2(d, Vector2(4 + i % 3, 5 + i % 2 * 3)), Color(MarathonArt.FOAM, .75))

# ----------------------------------------------------------------- front ----

static func _pauldron(c: CanvasItem, shoulder: Vector2, side: float, t: float, flow: Color) -> void:
	var p: Vector2 = shoulder + Vector2(0, -10)
	CelArt.poly(c, PackedVector2Array([p + Vector2(-side * 112, 18), p + Vector2(-side * 88, -26), p + Vector2(-side * 20, -44), p + Vector2(side * 70, -34), p + Vector2(side * 118, 0), p + Vector2(side * 96, 30), p + Vector2(-side * 70, 34)]), BASALT, 4.0)
	CelArt.poly(c, PackedVector2Array([p + Vector2(-side * 88, -26), p + Vector2(-side * 20, -44), p + Vector2(side * 70, -34), p + Vector2(side * 20, -12), p + Vector2(-side * 60, -8)]), BASALT_LIGHT, 2.0)
	c.draw_polyline(PackedVector2Array([p + Vector2(-side * 60, 20), p + Vector2(-side * 16, 0), p + Vector2(side * 30, 14), p + Vector2(side * 84, -4)]), INK, 7.0, false)
	c.draw_polyline(PackedVector2Array([p + Vector2(-side * 60, 20), p + Vector2(-side * 16, 0), p + Vector2(side * 30, 14), p + Vector2(side * 84, -4)]), flow, 3.0, false)
	if side < 0.0:
		# Storm shoulder: cloud lobes and crackling static.
		for i: int in range(4):
			CelArt.ellipse(c, p + Vector2(-100 + i * 48, -44 - i % 2 * 10 + sin(t * 2.0 + i) * 4.0), Vector2(30, 15), STORM_MID if i % 2 == 0 else STORM_DARK, 2.0)
		var frame: int = int(t * 12.0)
		var spark: PackedVector2Array = PackedVector2Array([p + Vector2(-90, -50)])
		for step: int in range(1, 6):
			spark.append(p + Vector2(-90 + step * 32, -54 + sin(frame * 2.3 + step * 1.9) * 10.0))
		c.draw_polyline(spark, Color(ELECTRIC, .3), 8.0, false)
		c.draw_polyline(spark, Color("e6f8ff"), 2.0, false)
	else:
		for i: int in range(3):
			_spray(c, p + Vector2(-50 + i * 50, -32 + absf(i - 1) * 6.0), 46.0 + sin(t * 6.0 + i) * 10.0, 17.0, t * 7.0 + i, flow)

static func _head(c: CanvasItem, rig: Dictionary, root: Vector2, t: float, flow: Color, over: float) -> void:
	var h: Vector2 = rig["head"]
	var jaw: float = rig["jaw"]
	var wind: float = rig["wind"]
	# Crown of short flames and lightning spikes along the skull ridge.
	for i: int in range(7):
		var x: float = -42.0 + i * 14.0
		var base: Vector2 = h + Vector2(x, -84.0 + absf(x) * .12) * HEAD_SCALE
		var height: float = 14.0 + (1.0 - absf(i - 3) / 3.0) * 6.0
		if i % 2 == 0:
			_spray(c, base, height + sin(t * 7.0 + i) * 4.0, 9.0, t * 8.0 + i, flow)
		else:
			var spike: PackedVector2Array = PackedVector2Array([base, base + Vector2(5, -height * .4), base + Vector2(-4, -height * .65), base + Vector2(2, -height - 2)])
			c.draw_polyline(spike, Color(ELECTRIC, .35), 8.0, false)
			c.draw_polyline(spike, Color("e8f9ff"), 2.5, false)
	c.draw_set_transform(root + h, sin(t * .9) * .03, Vector2.ONE * HEAD_SCALE)
	# Swept horns: lightning-cracked on the storm side, burning on the fire side.
	for side: float in [-1.0, 1.0]:
		var horn: PackedVector2Array = PackedVector2Array([Vector2(side * 40, -50), Vector2(side * 60, -72), Vector2(side * 84, -86), Vector2(side * 106, -88), Vector2(side * 92, -76), Vector2(side * 74, -56), Vector2(side * 62, -36)])
		CelArt.poly(c, horn, Color("4a4f49") if side < 0.0 else Color("32464b"), 3.0)
		c.draw_line(Vector2(side * 52, -58), Vector2(side * 92, -82), BASALT_LIGHT if side < 0.0 else Color("64a8b0"), 2.5)
		if side < 0.0:
			var frame: int = int(t * 14.0)
			var crackle: PackedVector2Array = PackedVector2Array([Vector2(-104, -88), Vector2(-90, -96 + sin(frame * 2.3) * 5.0), Vector2(-78, -86), Vector2(-66, -94 + cos(frame * 1.7) * 5.0)])
			c.draw_polyline(crackle, Color(ELECTRIC, .4), 6.0, false)
			c.draw_polyline(crackle, Color("eefaff"), 1.6, false)
		else:
			_spray(c, Vector2(100, -84), 22.0 + sin(t * 8.0) * 5.0, 8.0, t * 9.0, flow)
	var drop: Vector2 = Vector2(0, 8.0 + jaw * 18.0)
	# Roaring maw: flow throat, fang rows, hinged lower jaw.
	CelArt.poly(c, PackedVector2Array([Vector2(-46, 22), Vector2(46, 22), Vector2(40, 30) + drop, Vector2(-40, 30) + drop]), Color("1a0d0c"), 2.0)
	for i: int in range(3):
		CelArt.ellipse(c, Vector2(0, 28) + drop * .55, Vector2(32 - i * 9, 4 + jaw * 7 - i * 1.5), Color(flow, .3 + i * .22), 0)
	CelArt.poly(c, PackedVector2Array([Vector2(-50, 24) + drop, Vector2(50, 24) + drop, Vector2(44, 48) + drop, Vector2(20, 60) + drop, Vector2(-20, 60) + drop, Vector2(-44, 48) + drop]), BASALT_DARK, 3.0)
	c.draw_line(Vector2(-40, 30) + drop, Vector2(36, 28) + drop, BASALT, 3.0)
	for i: int in range(6):
		var x: float = -34.0 + i * 13.6
		CelArt.poly(c, PackedVector2Array([Vector2(x - 5, 26) + drop, Vector2(x + 5, 26) + drop, Vector2(x, 16) + drop]), Color("d8cfb0"), 1.0)
	# Angular skull, two-tone cel planes.
	var skull: PackedVector2Array = PackedVector2Array([Vector2(-74, -14), Vector2(-64, -42), Vector2(-50, -68), Vector2(-22, -82), Vector2(0, -88), Vector2(22, -82), Vector2(50, -68), Vector2(64, -42), Vector2(74, -14), Vector2(66, 12), Vector2(48, 26), Vector2(-48, 26), Vector2(-66, 12)])
	CelArt.poly(c, skull, Color("62665c"), 3.5)
	CelArt.poly(c, PackedVector2Array([Vector2(-64, -42), Vector2(-50, -68), Vector2(-22, -82), Vector2(0, -88), Vector2(-6, -52), Vector2(-40, -36)]), Color("7c8073"), 0.0)
	CelArt.poly(c, PackedVector2Array([Vector2(22, -82), Vector2(50, -68), Vector2(64, -42), Vector2(74, -14), Vector2(66, 12), Vector2(48, 26), Vector2(30, 10), Vector2(40, -40)]), Color("474c45"), 0.0)
	c.draw_polyline(skull + PackedVector2Array([skull[0]]), INK, 3.5, false)
	for i: int in range(6):
		var x: float = -35.0 + i * 14.0
		var length: float = 17.0 if i in [1, 4] else 9.0
		CelArt.poly(c, PackedVector2Array([Vector2(x - 5, 22), Vector2(x + 5, 22), Vector2(x, 22 + length)]), Color("e6ddc0"), 1.2)
	# Magma bleeds through the skull cracks.
	for crack: PackedVector2Array in [PackedVector2Array([Vector2(-6, -86), Vector2(-18, -60), Vector2(-2, -46), Vector2(-12, -30)]), PackedVector2Array([Vector2(42, -70), Vector2(30, -50), Vector2(50, -30), Vector2(40, -10)]), PackedVector2Array([Vector2(-58, -40), Vector2(-46, -22), Vector2(-62, 0)])]:
		c.draw_polyline(crack, Color(flow, .3), 9.0, false)
		c.draw_polyline(crack, INK, 5.0, false)
		c.draw_polyline(crack, flow.lerp(FOAM_LIGHT, .4), 2.2, false)
	# Heavy V brow over two slit eyes: storm-blue left, magma right.
	CelArt.poly(c, PackedVector2Array([Vector2(-70, -36), Vector2(-10, -16), Vector2(0, -24), Vector2(10, -16), Vector2(70, -36), Vector2(66, -22), Vector2(8, -2), Vector2(-8, -2), Vector2(-66, -22)]), Color("262b29"), 2.5)
	var glow: float = .5 + .2 * sin(t * 3.0) + .6 * wind + .4 * over
	for side: float in [-1.0, 1.0]:
		var tint: Color = ELECTRIC if side < 0.0 else FOAM_LIGHT
		var eye: PackedVector2Array = PackedVector2Array([Vector2(side * 56, -18), Vector2(side * 14, -6), Vector2(side * 18, 3), Vector2(side * 52, -6)])
		c.draw_circle(Vector2(side * 34, -8), 22.0 * (.6 + glow * .4), Color(tint, .22 * glow))
		CelArt.poly(c, eye, tint.lerp(Color(1, 1, .95), clampf(glow - .7, 0, 1)), 2.0)
		c.draw_line(Vector2(side * 44, -12), Vector2(side * 26, -6), Color(1, 1, .95, .9), 2.0)
	c.draw_line(Vector2(-6, 6), Vector2(-3, 14), INK, 3.0)
	c.draw_line(Vector2(6, 6), Vector2(3, 14), INK, 3.0)
	if over > 0.0:
		var frame: int = int(t * 18.0)
		for k: int in range(2):
			var arc: PackedVector2Array = PackedVector2Array([Vector2(-70 + k * 90, -62)])
			for step: int in range(1, 5): arc.append(Vector2(-70 + k * 90 + step * 12, -62 + sin(frame * 2.1 + step * 2.7 + k) * 14.0))
			c.draw_polyline(arc, Color("f4fbff"), 2.0, false)
	c.draw_set_transform(root)

# ---------------------------------------------------------------- fusion ----

## Storm (top-left sky), fire (top-right sky), flood (left) and quake (right, from
## the ground) are pulled into the facade, collide at 55% and feed the new body.
static func fusion(c: Node2D, progress: float, clock: float) -> void:
	var starts: Array[Vector2] = FUSION_STARTS
	var order: Array[int] = [0, 1, 2]
	var gather: float = clampf(progress / DisasterWaveManager.FUSION_IMPACT, 0.0, 1.0)
	# Accelerating pull: the energies are dragged in, then slam together.
	var e: float = pow(gather, 1.6)
	if progress < .62:
		for i: int in order:
			var start: Vector2 = starts[i]
			var control: Vector2 = start.lerp(FUSION_CENTER, .5) + Vector2(0, -280)
			var color: Color = ELEMENTS[i]
			for k: int in range(12):
				var q: Vector2 = _bezier(start, control, FUSION_CENTER, maxf(0.0, e - k * .03))
				c.draw_circle(q, 44.0 - k * 3.2, Color(color, .5 - k * .04))
			var p: Vector2 = _bezier(start, control, FUSION_CENTER, e)
			c.draw_circle(p, 78.0, Color(color, .14))
			c.draw_circle(p, 58.0, Color(color, .22))
			CelArt.ellipse(c, p, Vector2(40, 40), color.darkened(.35), 5.0)
			c.draw_circle(p, 22.0, color.lightened(.55))
			match i:
				0: c.draw_arc(p, 20.0, clock * 9.0, clock * 9.0 + PI * 1.5, 16, Color("e8f9ff"), 3.0)
				1: CelArt.poly(c, PackedVector2Array([p + Vector2(-16, -8), p + Vector2(4, -18), p + Vector2(18, -2), p + Vector2(6, 16), p + Vector2(-14, 10)]), Color("8f8370"), 2.0)
				2: c.draw_arc(p + Vector2(0, 2), 19.0, PI, TAU, 12, Color("e9fff6"), 4.0)
	# Sky bolts strike while the energies gather and at the impact.
	if progress > .18 and progress < .8:
		var frame: int = int(clock * 16.0)
		for k: int in range(3):
			var from: Vector2 = Vector2(-900 + k * 900 + sin(frame * 1.7 + k) * 160.0, -1380)
			var to: Vector2 = FUSION_CENTER if progress > .5 else _bezier(starts[k], starts[k].lerp(FUSION_CENTER, .5) + Vector2(0, -280), FUSION_CENTER, e)
			var bolt: PackedVector2Array = PackedVector2Array([from])
			for step: int in range(1, 7):
				bolt.append(from.lerp(to, step / 7.0) + Vector2(sin(frame * 3.3 + step * 2.1 + k) * 38.0, 0))
			bolt.append(to)
			c.draw_polyline(bolt, Color(.45, .7, 1.0, .35), 14.0, false)
			c.draw_polyline(bolt, Color(.92, .98, 1.0, .95), 3.5, false)
	if progress >= DisasterWaveManager.FUSION_IMPACT:
		var q: float = clampf((progress - DisasterWaveManager.FUSION_IMPACT) / .3, 0.0, 1.0)
		c.draw_circle(FUSION_CENTER, 140.0 + q * 1100.0, Color(1, .97, .9, .5 * (1.0 - q)))
		for i: int in range(3):
			c.draw_arc(FUSION_CENTER, 60.0 + q * (700.0 + i * 140.0), 0, TAU, 72, Color(INK, .5 * (1.0 - q)), 16.0)
			c.draw_arc(FUSION_CENTER, 60.0 + q * (700.0 + i * 140.0), 0, TAU, 72, Color(ELEMENTS[i], 1.0 - q), 8.0)
	if progress >= .6:
		# Element streams feed the condensing anatomy: head, vortex, claw, tides.
		var f: float = clampf((progress - .6) / .4, 0.0, 1.0)
		var targets: Array[Vector2] = [Vector2(-1000, -470), Vector2(0, -1010), Vector2(-1010, -150), Vector2(1000, -470), Vector2(1010, -150)]
		var tints: Array[Color] = [ELEMENTS[0], ELEMENTS[1], ELEMENTS[2], ELEMENTS[1], ELEMENTS[2]]

		for i: int in range(targets.size()):
			var stream: PackedVector2Array = PackedVector2Array()
			for step: int in range(13):
				var s: float = step / 12.0
				stream.append(FUSION_CENTER.lerp(targets[i], s) + Vector2(0, sin(s * 9.0 + clock * 14.0 + i) * 26.0 * (1.0 - s)))
			c.draw_polyline(stream, Color(tints[i], .35 * (1.0 - f)), 18.0 * (1.0 - f) + 2.0, false)
			c.draw_polyline(stream, Color(tints[i].lightened(.4), 1.0 - f), 4.0, false)

## A curling jet with a foam crest, replacing every flame in the final anatomy.
static func _spray(c: CanvasItem, p: Vector2, height: float, width: float, t: float, color: Color) -> void:
	var curl: float = sin(t*.45)*width*.65
	var shape: PackedVector2Array = PackedVector2Array([p+Vector2(-width,0),p+Vector2(-width*.6,-height*.6),p+Vector2(curl-width*.8,-height),p+Vector2(curl+width*.7,-height*.93),p+Vector2(curl+width*.3,-height*.68),p+Vector2(width*.65,-height*.3),p+Vector2(width,0)])
	CelArt.poly(c,shape,Color("277d96"),2.5)
	c.draw_polyline(PackedVector2Array([shape[1],shape[2],shape[3],shape[4]]),color.lightened(.25),3.0,true)

static func _bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	return a.lerp(b, t).lerp(b.lerp(c, t), t)

static func _rock(c: CanvasItem, center: Vector2, size: Vector2, color: Color) -> void:
	CelArt.poly(c, PackedVector2Array([center + Vector2(-size.x, -size.y * .6), center + Vector2(-size.x * .5, -size.y), center + Vector2(size.x * .65, -size.y * .9), center + Vector2(size.x, -size.y * .1), center + Vector2(size.x * .73, size.y * .85), center + Vector2(-size.x * .65, size.y)]), color, 3.0)
	CelArt.poly(c, PackedVector2Array([center + Vector2(-size.x, -size.y * .6), center + Vector2(-size.x * .5, -size.y), center + Vector2(size.x * .65, -size.y * .9), center + Vector2(size.x * .3, -size.y * .35)]), color.lightened(.18), 1.5)
