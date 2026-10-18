class_name MusicScore
extends RefCounted
## Five original stems, baked together ONCE. No synthesis in ordinary frames.
## 120 BPM, eight 4/4 bars, 16 s, 22,050 Hz mono PCM, D minor.
const RATE: int = 22050
const BPM: float = 120.0
const BEAT: float = 60.0/BPM
const BARS: int = 8
const LENGTH: float = BARS*4.0*BEAT
const SAMPLE_COUNT: int = int(RATE*LENGTH)
const STEMS: Array[String] = ["pad_bass", "drums", "lead_arp", "climax", "tension"]
const ROOTS: Array[int] = [38,41,43,45,46,45,38,45]
const LEAD: Array[int] = [62,65,69,67,62,65,72,69]
const BASS_STEPS: Array[int] = [0,0,12,0,0,7,0,12]
static var _stems: Dictionary = {}
static var bake_usec: int = 0
static var bake_count: int = 0
# Legacy inspection API retained; these now point to real adaptive stems.
static var layer_bake_count: int = 0
static var layer_bake_usec: int = 0

static func make_stems() -> Dictionary:
	if _stems.is_empty(): _bake()
	return _stems.duplicate()

static func make_stream() -> AudioStreamWAV:
	return make_stems()["pad_bass"]

static func make_layer_stream() -> AudioStreamWAV:
	return make_stems()["climax"]

static func _bake() -> void:
	var started: int = Time.get_ticks_usec()
	var frequencies: PackedFloat64Array = PackedFloat64Array()
	for note: int in range(128): frequencies.append(440.0*pow(2.0,(note-69.0)/12.0))
	var pad_data: PackedFloat32Array = PackedFloat32Array()
	var drums_data: PackedFloat32Array = PackedFloat32Array()
	var lead_data: PackedFloat32Array = PackedFloat32Array()
	var climax_data: PackedFloat32Array = PackedFloat32Array()
	var tension_data: PackedFloat32Array = PackedFloat32Array()
	pad_data.resize(SAMPLE_COUNT)
	drums_data.resize(SAMPLE_COUNT)
	lead_data.resize(SAMPLE_COUNT)
	climax_data.resize(SAMPLE_COUNT)
	tension_data.resize(SAMPLE_COUNT)
	var noise: int = 923714
	var previous_noise: float = 0.0
	var low: PackedFloat64Array = PackedFloat64Array([0,0,0,0,0])
	for i: int in range(SAMPLE_COUNT):
		var t: float = float(i)/RATE
		var step: int = int(t/(BEAT*.5))
		var beat: int = step/2
		var root: int = ROOTS[step/8]
		var eighth: float = fmod(t, BEAT*.5)
		var bt: float = fmod(t, BEAT)
		var env: float = minf(1.0,eighth/.008)*minf(1.0,(BEAT*.5-eighth)/.035)
		var phase: float = TAU*frequencies[root+BASS_STEPS[step%8]]*eighth
		var bass: float = (sin(phase)*.78+sin(phase*2)*.16+sin(phase*3)*.06)*env*.32
		var bar_time: float = fmod(t,BEAT*4)
		var pad_env: float = minf(1.0,bar_time/.12)*minf(1.0,(BEAT*4-bar_time)/.18)
		var pad: float = (sin(TAU*frequencies[root+12]*t)+sin(TAU*frequencies[root+19]*t))*.055*pad_env
		var arp: float = (sin(TAU*frequencies[LEAD[step%8]]*eighth)+.15*sin(TAU*frequencies[LEAD[step%8]]*2*eighth))*env*exp(-eighth*7)*.30
		var kick: float = sin(TAU*(42*bt+68*.035*(1-exp(-bt/.035))))*exp(-bt*17)*minf(1.0,bt/.004)
		noise = (noise*1664525+1013904223)&0x7fffffff
		var white: float = float(noise)/1073741824.0-1
		var snare: float = (white*.72+sin(TAU*175*bt)*.28)*exp(-bt*28)*minf(1.0,bt/.004) if beat%4 in [1,3] else 0.0
		var hat: float = (white-previous_noise)*exp(-eighth*85)*minf(1.0,eighth/.003)*.11
		previous_noise = white
		var urgency: float = (sin(TAU*73.4162*eighth)*.30 + sin(TAU*frequencies[[74,77,81][step%3]]*eighth)*.065)*env
		var heartbeat: float = sin(TAU*55*bt)*exp(-bt*24)*minf(1.0,bt/.006)*.26
		var clock_tick: float = sin(TAU*1760*eighth)*exp(-eighth*120)*minf(1.0,eighth/.004)*.10
		var pedal: float = (sin(TAU*146.8324*t)*.08+sin(TAU*155.5635*t)*.025)*(0.75+.25*sin(TAU*.5*t))
		low[0] = lerpf(low[0], bass+pad, .57)
		low[1] = lerpf(low[1], (kick+snare+hat)*.40, .57)
		low[2] = lerpf(low[2], arp, .57)
		low[3] = lerpf(low[3], urgency+hat*.08, .40)
		low[4] = lerpf(low[4], heartbeat+clock_tick+pedal, .35)
		pad_data[i] = low[0]
		drums_data[i] = low[1]
		lead_data[i] = low[2]
		climax_data[i] = low[3]
		tension_data[i] = low[4]
	var arrays: Array = [pad_data, drums_data, lead_data, climax_data, tension_data]
	for index: int in range(STEMS.size()): _stems[STEMS[index]] = _encode(arrays[index])
	bake_count += 1
	layer_bake_count = bake_count
	bake_usec = Time.get_ticks_usec()-started
	layer_bake_usec = bake_usec

static func _encode(samples: PackedFloat32Array) -> AudioStreamWAV:
	var mean: float = 0.0
	for value: float in samples: mean += value
	mean /= SAMPLE_COUNT
	var peak: float = .000001
	for i: int in range(SAMPLE_COUNT):
		var edge: float = minf(1.0,minf(float(i),float(SAMPLE_COUNT-1-i))/(RATE*.008))
		samples[i] = (samples[i]-mean)*edge
		peak = maxf(peak,absf(samples[i]))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(SAMPLE_COUNT*2)
	for i: int in range(SAMPLE_COUNT): bytes.encode_s16(i*2,int(samples[i]*.55/maxf(.55,peak)*32767))
	return SoundSynth.make_stream(bytes,true)
