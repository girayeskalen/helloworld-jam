class_name SoundSynth
extends RefCounted
## Offline procedural synthesis (no audio files). Every sound is a recipe of layers:
## filtered coloured noise, warm harmonic tones, sparse crackle, bubbles and debris
## thuds, each under a soft ADSR envelope. Output is low-passed, DC-free, soft-
## saturated, peak-normalised and click-free, then packed as 16-bit mono PCM.
## Pure functions only: safe to run on a worker thread.

const RATE: int = 22050
## Highest harmonic allowed in additive tones; keeps everything dark, never fizzy.
const HARMONIC_CEILING: float = 3600.0

static func render(recipe: Dictionary, seed_value: int) -> PackedFloat32Array:
	var n: int = int(float(recipe["length"]) * RATE)
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(n)
	out.fill(0.0)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for layer: Dictionary in recipe["layers"]:
		match String(layer["type"]):
			"noise": _noise(out, layer, rng)
			"tone": _tone(out, layer)
			"crackle": _crackle(out, layer, rng)
			"blips": _blips(out, layer, rng)
			"thuds": _thuds(out, layer, rng)
	_finish(out, recipe)
	return out

static func to_pcm16(samples: PackedFloat32Array) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i: int in range(samples.size()):
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	return bytes

static func from_pcm16(bytes: PackedByteArray) -> PackedFloat32Array:
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(bytes.size() / 2)
	for i: int in range(samples.size()):
		samples[i] = bytes.decode_s16(i * 2) / 32767.0
	return samples

static func make_stream(bytes: PackedByteArray, loop: bool) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = bytes.size() / 2
	return stream

# ---------------------------------------------------------------- layers ----

## Soft ADSR: sin² attack, exponential-ish decay to sustain, smooth release.
static func envelope(t: float, duration: float, env: Array) -> float:
	var attack: float = maxf(0.003, float(env[0]))
	var decay: float = maxf(0.001, float(env[1]))
	var sustain: float = float(env[2])
	var release: float = maxf(0.004, float(env[3]))
	if t < 0.0 or t > duration: return 0.0
	var level: float
	if t < attack:
		var a: float = sin(t / attack * PI * 0.5)
		level = a * a
	elif t < attack + decay:
		var k: float = (t - attack) / decay
		level = sustain + (1.0 - sustain) * pow(1.0 - k, 2.2)
	else:
		level = sustain
	var tail: float = duration - t
	if tail < release:
		var r: float = sin(tail / release * PI * 0.5)
		level *= r * r
	return level

static func _span(out: PackedFloat32Array, layer: Dictionary) -> Vector2i:
	var start: int = int(float(layer.get("start", 0.0)) * RATE)
	var duration: float = float(layer.get("dur", float(out.size()) / RATE - float(layer.get("start", 0.0))))
	return Vector2i(clampi(start, 0, out.size()), clampi(start + int(duration * RATE), 0, out.size()))

static func _sweep(f0: float, f1: float, k: float) -> float:
	return f0 * pow(f1 / f0, clampf(k, 0.0, 1.0))

## Coloured noise through a Chamberlin state-variable filter with a cutoff sweep.
## The filter coefficient is refreshed every 16 samples (inaudible, much cheaper).
static func _noise(out: PackedFloat32Array, layer: Dictionary, rng: RandomNumberGenerator) -> void:
	var span: Vector2i = _span(out, layer)
	var count: int = span.y - span.x
	if count <= 0: return
	var duration: float = float(count) / RATE
	var env: Array = layer.get("env", [0.01, 0.1, 1.0, 0.05])
	var gain: float = float(layer.get("gain", 1.0))
	var color: int = ["white", "pink", "brown"].find(String(layer.get("color", "white")))
	var bandpass: bool = String(layer.get("filter", "lp")) == "bp"
	var f0: float = float(layer.get("f0", 1200.0))
	var f1: float = float(layer.get("f1", f0))
	var damping: float = float(layer.get("q", 0.9))
	var band_gain: float = 0.8 + damping * 0.4
	var am_rate: float = float(layer.get("am_rate", 0.0))
	var am_depth: float = float(layer.get("am_depth", 0.0))
	var low: float = 0.0
	var band: float = 0.0
	var brown: float = 0.0
	var b0: float = 0.0
	var b1: float = 0.0
	var b2: float = 0.0
	var f: float = 0.0
	for i: int in range(count):
		var t: float = float(i) / RATE
		if i % 16 == 0:
			f = 2.0 * sin(PI * minf(_sweep(f0, f1, t / duration), 3400.0) / RATE)
		var white: float = rng.randf() * 2.0 - 1.0
		var x: float = white
		if color == 1:
			# Paul Kellet economy pink filter.
			b0 = 0.99765 * b0 + white * 0.0990460
			b1 = 0.96300 * b1 + white * 0.2965164
			b2 = 0.57000 * b2 + white * 1.0526913
			x = (b0 + b1 + b2 + white * 0.1848) * 0.22
		elif color == 2:
			brown = (brown + white * 0.02) * 0.997
			x = brown * 3.2
		low += f * band
		var high: float = x - low - damping * band
		band += f * high
		var value: float = band * band_gain if bandpass else low
		if am_rate > 0.0:
			value *= 1.0 - am_depth * (0.5 + 0.5 * sin(TAU * am_rate * t))
		out[span.x + i] += value * gain * envelope(t, duration, env)

## Warm additive tone(s) with pitch glide, vibrato, AM, chords and a one-pole
## low-pass. Harmonic waves use the Chebyshev sine recurrence (one sin + one cos
## per sample for all partials); partials above HARMONIC_CEILING are dropped.
static func _tone(out: PackedFloat32Array, layer: Dictionary) -> void:
	var span: Vector2i = _span(out, layer)
	var count: int = span.y - span.x
	if count <= 0: return
	var duration: float = float(count) / RATE
	var env: Array = layer.get("env", [0.01, 0.1, 1.0, 0.05])
	var gain: float = float(layer.get("gain", 1.0))
	var wave: String = layer.get("wave", "sine")
	var f0: float = float(layer.get("f0", 220.0))
	var f1: float = float(layer.get("f1", f0))
	var glides: bool = not is_equal_approx(f0, f1)
	var glide: float = maxf(0.001, float(layer.get("glide", duration)))
	var ratios: Array = layer.get("chord", [1.0])
	var vibrato: Array = layer.get("vibrato", [0.0, 0.0])
	var vib_rate: float = float(vibrato[0])
	var vib_depth: float = float(vibrato[1]) / 12.0
	var am_rate: float = float(layer.get("am_rate", 0.0))
	var am_depth: float = float(layer.get("am_depth", 0.0))
	var alpha: float = 1.0 - exp(-TAU * float(layer.get("lp", 2600.0)) / RATE)
	var voice_gain: float = 1.0 / sqrt(float(ratios.size()))
	var bell: bool = wave == "bell"
	var amps: PackedFloat32Array = _harmonics(wave)
	for v: int in range(ratios.size()):
		var ratio: float = float(ratios[v])
		var phase: float = float(v) * 1.7
		var smooth: float = 0.0
		var freq: float = f0 * ratio
		var top: int = mini(amps.size(), int(HARMONIC_CEILING / maxf(freq, 1.0)))
		for i: int in range(count):
			var t: float = float(i) / RATE
			if glides:
				freq = _sweep(f0, f1, t / glide) * ratio
				top = mini(amps.size(), int(HARMONIC_CEILING / maxf(freq, 1.0)))
			var current: float = freq
			if vib_depth > 0.0: current *= pow(2.0, vib_depth * sin(TAU * vib_rate * t))
			phase += TAU * current / RATE
			var sample: float = 0.0
			if bell:
				sample = sin(phase)
				if current * 2.76 < HARMONIC_CEILING: sample += sin(phase * 2.76) * 0.42
				if current * 5.4 < HARMONIC_CEILING: sample += sin(phase * 5.4) * 0.18
			else:
				var c2: float = 2.0 * cos(phase)
				var previous: float = 0.0
				var now: float = sin(phase)
				for k: int in range(top):
					sample += amps[k] * now
					var next: float = c2 * now - previous
					previous = now
					now = next
			if am_rate > 0.0:
				sample *= 1.0 - am_depth * (0.5 + 0.5 * sin(TAU * am_rate * t + float(v) * 2.1))
			smooth += alpha * (sample - smooth)
			out[span.x + i] += smooth * gain * voice_gain * envelope(t, duration, env)

## Amplitude of harmonic k+1 for each harmonic wave shape.
static func _harmonics(wave: String) -> PackedFloat32Array:
	match wave:
		"warm": return PackedFloat32Array([1.0, 0.32, 0.16, 0.07])
		"saw":
			var saw: PackedFloat32Array = PackedFloat32Array()
			for k: int in range(1, 11): saw.append(0.62 / k)
			return saw
		"horn": return PackedFloat32Array([1.0, 0.7, 0.5, 0.32, 0.2, 0.12])
	return PackedFloat32Array([1.0])

## Sparse decaying noise grains: rain drops, embers, gravel and ratchets.
static func _crackle(out: PackedFloat32Array, layer: Dictionary, rng: RandomNumberGenerator) -> void:
	var span: Vector2i = _span(out, layer)
	var count: int = span.y - span.x
	if count <= 0: return
	var duration: float = float(count) / RATE
	var env: Array = layer.get("env", [0.01, 0.1, 1.0, 0.05])
	var gain: float = float(layer.get("gain", 1.0))
	var chance: float = float(layer.get("rate", 30.0)) / RATE
	var decay: float = exp(-1.0 / (maxf(0.001, float(layer.get("decay", 0.006))) * RATE))
	var alpha: float = 1.0 - exp(-TAU * float(layer.get("f_lp", 2500.0)) / RATE)
	var grain: float = 0.0
	var smooth: float = 0.0
	for i: int in range(count):
		if rng.randf() < chance: grain = rng.randf_range(0.35, 1.0)
		grain *= decay
		smooth += alpha * (grain * (rng.randf() * 2.0 - 1.0) - smooth)
		out[span.x + i] += smooth * gain * envelope(float(i) / RATE, duration, env)

## Bubble chirps: short smooth sine sweeps at random moments.
static func _blips(out: PackedFloat32Array, layer: Dictionary, rng: RandomNumberGenerator) -> void:
	var span: Vector2i = _span(out, layer)
	var count: int = span.y - span.x
	if count <= 0: return
	var amount: int = int(float(layer.get("rate", 10.0)) * float(count) / RATE)
	var length: int = int(float(layer.get("blip", 0.05)) * RATE)
	var gain: float = float(layer.get("gain", 0.3))
	for b: int in range(amount):
		var at: int = span.x + rng.randi_range(0, maxi(0, count - length))
		var fa: float = float(layer.get("fa", 220.0)) * rng.randf_range(0.8, 1.25)
		var fb: float = float(layer.get("fb", 520.0)) * rng.randf_range(0.8, 1.25)
		var phase: float = 0.0
		var level: float = gain * rng.randf_range(0.5, 1.0)
		for i: int in range(length):
			var k: float = float(i) / length
			phase += TAU * lerpf(fa, fb, k) / RATE
			var shape: float = sin(k * PI)
			out[mini(at + i, out.size() - 1)] += sin(phase) * shape * shape * level

## Debris impacts: low sine knock plus a short dark noise burst, randomly timed.
static func _thuds(out: PackedFloat32Array, layer: Dictionary, rng: RandomNumberGenerator) -> void:
	var span: Vector2i = _span(out, layer)
	var count: int = span.y - span.x
	if count <= 0: return
	var amount: int = int(layer.get("count", 6))
	var length: int = int(0.16 * RATE)
	var gain: float = float(layer.get("gain", 0.7))
	var alpha: float = 1.0 - exp(-TAU * float(layer.get("f_lp", 900.0)) / RATE)
	for b: int in range(amount):
		var at: int = span.x + rng.randi_range(0, maxi(0, count - length))
		var freq: float = rng.randf_range(float(layer.get("fa", 70.0)), float(layer.get("fb", 130.0)))
		var level: float = gain * rng.randf_range(0.45, 1.0)
		var phase: float = 0.0
		var smooth: float = 0.0
		for i: int in range(length):
			var t: float = float(i) / RATE
			var shape: float = minf(1.0, t / 0.003) * exp(-t / 0.045)
			phase += TAU * freq * (1.0 - t * 2.0) / RATE
			smooth += alpha * ((rng.randf() * 2.0 - 1.0) - smooth)
			out[mini(at + i, out.size() - 1)] += (sin(phase) * 0.8 + smooth * 0.9) * shape * level

# ---------------------------------------------------------------- master ----

## Final low-pass, DC blocker, soft saturation, normalisation and click guards.
## Loops are crossfaded end-into-start instead of faded.
static func _finish(out: PackedFloat32Array, recipe: Dictionary) -> void:
	var n: int = out.size()
	if n == 0: return
	var alpha: float = 1.0 - exp(-TAU * float(recipe.get("lp", 5200.0)) / RATE)
	var smooth: float = 0.0
	var dc_in: float = 0.0
	var dc_out: float = 0.0
	for i: int in range(n):
		smooth += alpha * (out[i] - smooth)
		# One-pole DC blocker (~20 Hz).
		dc_out = smooth - dc_in + 0.9943 * dc_out
		dc_in = smooth
		out[i] = dc_out
	var peak: float = 0.0
	for i: int in range(n): peak = maxf(peak, absf(out[i]))
	if peak < 0.000001: return
	var drive: float = 1.35 / peak
	var norm: float = 1.0 / (1.35 / (1.0 + 1.35))
	var target: float = float(recipe.get("peak", 0.8))
	var after: float = 0.0
	for i: int in range(n):
		var x: float = out[i] * drive
		out[i] = x / (1.0 + absf(x)) * norm
		after = maxf(after, absf(out[i]))
	var scale: float = target / maxf(after, 0.000001)
	for i: int in range(n): out[i] *= scale
	if bool(recipe.get("loop", false)):
		_crossfade_loop(out, int(float(recipe.get("xfade", 0.4)) * RATE))
		return
	var fade_in: int = mini(n, int(0.004 * RATE))
	for i: int in range(fade_in):
		var k: float = sin(float(i) / fade_in * PI * 0.5)
		out[i] *= k * k
	var fade_out: int = mini(n, int(0.015 * RATE))
	for i: int in range(fade_out):
		var k: float = sin(float(i) / fade_out * PI * 0.5)
		out[n - 1 - i] *= k * k

## Equal-power crossfade of the tail into the head; the result loops seamlessly.
static func _crossfade_loop(out: PackedFloat32Array, fade: int) -> void:
	var n: int = out.size()
	fade = clampi(fade, 1, n / 3)
	var body: int = n - fade
	for i: int in range(fade):
		var k: float = float(i) / fade
		out[i] = out[i] * sin(k * PI * 0.5) + out[body + i] * cos(k * PI * 0.5)
	out.resize(body)
