class_name MusicScore
extends RefCounted
## Original score baked once into mono PCM. No synthesis on the game/audio frame.
## 120 BPM × eight 4/4 bars = 16 s (12.8 s would require 150 BPM).
const RATE: int = 22050
const BPM: float = 120.0
const BEAT: float = 60.0/BPM
const BARS: int = 8
const LENGTH: float = BARS*4.0*BEAT
const SAMPLE_COUNT: int = int(RATE*LENGTH)
const ROOTS: Array[int] = [38,41,43,45,46,45,38,45]
const LEAD: Array[int] = [62,65,69,67,64,65,62]
const BASS_STEPS: Array[int] = [0,0,12,0,0,7,0,12]
const BASS_GAIN: float = .32
const DRUM_GAIN: float = .25
const LEAD_GAIN: float = .22
static var _pcm: PackedByteArray = PackedByteArray()
static var bake_usec: int = 0

static func make_stream() -> AudioStreamWAV:
	if _pcm.is_empty(): _bake()
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.mix_rate = RATE
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.data = _pcm
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = SAMPLE_COUNT # Frames, never PCM bytes.
	return wav

static func _bake() -> void:
	var started: int = Time.get_ticks_usec()
	var frequencies: PackedFloat64Array = PackedFloat64Array()
	for note: int in range(128): frequencies.append(440.0*pow(2.0,(note-69.0)/12.0))
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(SAMPLE_COUNT)
	var noise: int = 923714
	var low: float = 0.0
	var previous_noise: float = 0.0
	var peak: float = 0.0
	var sum: float = 0.0
	for i: int in range(SAMPLE_COUNT):
		var t: float = float(i)/RATE
		var step: int = int(t/(BEAT*.5))
		var bar: int = step/8
		var beat: int = step/2
		var eighth: float = fmod(t,BEAT*.5)
		var bt: float = fmod(t,BEAT)
		var root: int = ROOTS[bar]
		var env: float = minf(1.0,eighth/.008)*minf(1.0,(BEAT*.5-eighth)/.025)
		var phase: float = TAU*frequencies[root+BASS_STEPS[step%8]]*eighth
		var bass: float = (sin(phase)*.78+sin(phase*2.0)*.16+sin(phase*3.0)*.06)*env*BASS_GAIN
		var lead: float = sin(TAU*frequencies[LEAD[step%LEAD.size()]]*eighth)*env*exp(-eighth*7.0)*LEAD_GAIN
		var kick: float = sin(TAU*(42.0*bt+68.0*.035*(1.0-exp(-bt/.035))))*exp(-bt*17.0)*minf(1.0,bt/.004)
		noise = (noise*1664525+1013904223)&0x7fffffff
		var white: float = float(noise)/1073741824.0-1.0
		var snare: float = (white*.72+sin(TAU*175.0*bt)*.28)*exp(-bt*28.0)*minf(1.0,bt/.003) if beat%4 in [1,3] else 0.0
		var hat: float = (white-previous_noise)*exp(-eighth*85.0)*minf(1.0,eighth/.002)*.11
		previous_noise = white
		var bar_time: float = fmod(t,BEAT*4.0)
		var pad_env: float = minf(1.0,bar_time/.12)*minf(1.0,(BEAT*4.0-bar_time)/.18)
		var pad: float = (sin(TAU*frequencies[root+12]*t)+sin(TAU*frequencies[root+19]*t))*.027*pad_env
		low = lerpf(low,bass+lead+(kick+snare+hat)*DRUM_GAIN+pad,.57)
		var edge: float = minf(1.0,minf(t,LENGTH-t)/.003)
		var sample: float = low/(1.0+absf(low)*.3)*edge
		samples[i] = sample
		peak = maxf(peak,absf(sample))
		sum += sample
	var dc: float = sum/SAMPLE_COUNT
	var gain: float = .82/maxf(.82,peak)
	_pcm.resize(SAMPLE_COUNT*2)
	for i: int in range(SAMPLE_COUNT): _pcm.encode_s16(i*2,int(clampf((samples[i]-dc)*gain,-.95,.95)*32767))
	bake_usec = Time.get_ticks_usec()-started
