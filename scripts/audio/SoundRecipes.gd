class_name SoundRecipes
extends RefCounted
## Every game sound as a SoundSynth recipe. Dark, low-passed, soft-attack design:
## no raw square/saw edges (additive partials stop at 3.6 kHz), noise is always
## filtered, every layer has an ADSR envelope. Order = bake priority.

const ORDER: Array[String] = [
	"rain", "drone", "siege_pad", "kick", "tick", "clank", "warn",
	"ui_open", "ui_confirm", "ui_pause", "ui_resume", "ui_toggle",
	"storm_in", "storm_out", "quake_in", "quake_out", "tremor", "flood_in", "flood_out",
	"fire_in", "fire_out", "titan_in", "titan_fuse", "titan_out",
	"cast_storm", "cast_quake", "cast_flood", "cast_fire",
	"whoosh", "impact_glass", "impact_wood", "impact_stone", "impact_metal", "impact_water", "impact_fire", "block",
	"jump", "floor_up", "drop_land", "dash", "dodge", "graze", "hurt", "heartbeat",
	"loot_drop", "pickup", "heal", "safety", "repair", "secure", "cover", "alarm",
	"collapse_room", "topple", "collapse_building", "victory", "defeat", "safe", "karne_ok", "karne_miss",
]
const LOOPS: Array[String] = ["rain", "drone", "siege_pad"]

static func all() -> Dictionary:
	return {
		"safe": {"length": .45, "peak": .5, "lp": 1800.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 392.0, "dur": .28, "gain": .65, "env": [.008, .08, .25, .14]},
			{"type": "tone", "wave": "bell", "f0": 587.0, "start": .13, "dur": .32, "gain": .5, "env": [.008, .1, .2, .16]},
		]},
		"karne_ok": {"length": .25, "peak": .45, "lp": 1800.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 392.0, "f1": 523.25, "gain": .65, "env": [.006, .07, .12, .12]},
			{"type": "tone", "wave": "bell", "f0": 659.25, "start": .05, "dur": .2, "gain": .2, "env": [.006, .06, .12, .1]},
		]},
		"karne_miss": {"length": .3, "peak": .45, "lp": 1100.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 164.81, "f1": 130.81, "gain": .8, "env": [.008, .09, .16, .14]},
			{"type": "noise", "color": "brown", "f0": 500.0, "dur": .1, "gain": .08, "env": [.008, .04, .0, .05]},
		]},
		# ------------------------------------------------ ambience / music ----
		"rain": {"length": 6.4, "loop": true, "xfade": 0.6, "peak": 0.55, "lp": 3000.0, "layers": [
			{"type": "noise", "color": "pink", "f0": 2000.0, "q": 0.9, "gain": 0.55, "am_rate": 0.31, "am_depth": 0.22, "env": [0.01, 0.1, 1.0, 0.01]},
			{"type": "noise", "color": "brown", "f0": 420.0, "q": 1.0, "gain": 0.55, "env": [0.01, 0.1, 1.0, 0.01]},
			{"type": "crackle", "rate": 26.0, "decay": 0.005, "f_lp": 2600.0, "gain": 0.22, "env": [0.01, 0.1, 1.0, 0.01]},
		]},
		"drone": {"length": 6.9, "loop": true, "xfade": 0.5, "peak": 0.6, "lp": 900.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 36.75, "chord": [1.0, 1.4966, 2.0, 2.3741], "lp": 420.0, "am_rate": 0.125, "am_depth": 0.35, "gain": 0.75, "env": [0.01, 0.1, 1.0, 0.01]},
			{"type": "noise", "color": "brown", "f0": 150.0, "q": 1.1, "gain": 0.3, "env": [0.01, 0.1, 1.0, 0.01]},
		]},
		"siege_pad": {"length": 6.9, "loop": true, "xfade": 0.5, "peak": 0.55, "lp": 1100.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 55.0, "chord": [1.0, 1.0595, 1.5], "lp": 620.0, "am_rate": 0.25, "am_depth": 0.5, "gain": 0.7, "env": [0.01, 0.1, 1.0, 0.01]},
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 700.0, "q": 0.6, "gain": 0.14, "am_rate": 0.5, "am_depth": 0.6, "env": [0.01, 0.1, 1.0, 0.01]},
		]},
		"kick": {"length": 0.42, "peak": 0.82, "lp": 2400.0, "layers": [
			{"type": "tone", "f0": 92.0, "f1": 44.0, "glide": 0.12, "gain": 1.0, "env": [0.004, 0.3, 0.0, 0.08]},
			{"type": "tone", "wave": "warm", "f0": 46.0, "gain": 0.35, "env": [0.01, 0.28, 0.0, 0.1]},
			{"type": "noise", "f0": 900.0, "gain": 0.16, "dur": 0.05, "env": [0.002, 0.02, 0.0, 0.02]},
		]},
		"tick": {"length": 0.09, "peak": 0.45, "lp": 3000.0, "layers": [
			{"type": "noise", "filter": "bp", "f0": 2100.0, "q": 0.6, "gain": 0.7, "env": [0.002, 0.05, 0.0, 0.03]},
		]},
		"clank": {"length": 0.36, "peak": 0.55, "lp": 2600.0, "layers": [
			{"type": "tone", "wave": "bell", "f0": 176.0, "lp": 2200.0, "gain": 0.7, "env": [0.003, 0.26, 0.0, 0.08]},
			{"type": "noise", "filter": "bp", "f0": 1200.0, "q": 0.7, "gain": 0.3, "dur": 0.08, "env": [0.002, 0.04, 0.0, 0.03]},
		]},
		"heartbeat": {"length": 0.72, "peak": 0.78, "lp": 1200.0, "layers": [
			{"type": "tone", "f0": 64.0, "f1": 40.0, "glide": 0.1, "dur": 0.26, "gain": 1.0, "env": [0.004, 0.18, 0.0, 0.06]},
			{"type": "tone", "f0": 58.0, "f1": 38.0, "glide": 0.1, "start": 0.24, "dur": 0.3, "gain": 0.75, "env": [0.004, 0.2, 0.0, 0.07]},
		]},
		# -------------------------------------------------------------- UI ----
		"ui_open": {"length": 0.42, "peak": 0.5, "lp": 2000.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 220.0, "f1": 226.0, "chord": [1.0, 1.5], "lp": 1600.0, "gain": 0.8, "env": [0.012, 0.16, 0.3, 0.16]},
			{"type": "noise", "filter": "bp", "f0": 600.0, "f1": 1400.0, "q": 0.6, "gain": 0.12, "env": [0.05, 0.2, 0.0, 0.1]},
		]},
		"ui_confirm": {"length": 0.5, "peak": 0.5, "lp": 2400.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 330.0, "dur": 0.22, "lp": 1900.0, "gain": 0.7, "env": [0.006, 0.12, 0.2, 0.08]},
			{"type": "tone", "wave": "warm", "f0": 440.0, "start": 0.08, "dur": 0.3, "lp": 1900.0, "gain": 0.7, "env": [0.006, 0.14, 0.25, 0.12]},
			{"type": "tone", "f0": 660.0, "start": 0.16, "dur": 0.32, "lp": 2000.0, "gain": 0.3, "env": [0.01, 0.16, 0.2, 0.14]},
		]},
		"ui_pause": {"length": 0.32, "peak": 0.45, "lp": 1500.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 196.0, "f1": 147.0, "lp": 1200.0, "gain": 0.8, "env": [0.01, 0.16, 0.2, 0.12]},
		]},
		"ui_resume": {"length": 0.32, "peak": 0.45, "lp": 1500.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 147.0, "f1": 220.0, "lp": 1200.0, "gain": 0.8, "env": [0.01, 0.16, 0.2, 0.12]},
		]},
		"ui_toggle": {"length": 0.14, "peak": 0.4, "lp": 2400.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 494.0, "lp": 1800.0, "gain": 0.7, "env": [0.004, 0.07, 0.0, 0.04]},
			{"type": "noise", "filter": "bp", "f0": 1800.0, "q": 0.7, "gain": 0.12, "dur": 0.04, "env": [0.002, 0.02, 0.0, 0.015]},
		]},
		# --------------------------------------------------- boss entries ----
		"storm_in": {"length": 2.3, "peak": 0.85, "lp": 3200.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 220.0, "f1": 1350.0, "q": 0.35, "gain": 0.85, "am_rate": 2.5, "am_depth": 0.35, "env": [1.3, 0.2, 0.8, 0.6]},
			{"type": "noise", "color": "brown", "f0": 260.0, "gain": 0.55, "env": [0.8, 0.3, 0.7, 0.8]},
			{"type": "noise", "color": "brown", "f0": 900.0, "f1": 120.0, "start": 1.45, "dur": 0.85, "gain": 1.0, "env": [0.005, 0.5, 0.3, 0.3]},
			{"type": "crackle", "rate": 130.0, "decay": 0.008, "f_lp": 2400.0, "start": 1.45, "dur": 0.3, "gain": 0.5, "env": [0.003, 0.2, 0.2, 0.08]},
		]},
		"storm_out": {"length": 1.7, "peak": 0.7, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1200.0, "f1": 200.0, "q": 0.4, "gain": 0.85, "am_rate": 3.0, "am_depth": 0.3, "env": [0.05, 0.6, 0.4, 0.9]},
			{"type": "noise", "color": "brown", "f0": 300.0, "gain": 0.4, "env": [0.05, 1.0, 0.2, 0.5]},
		]},
		"quake_in": {"length": 2.3, "peak": 0.88, "lp": 1600.0, "layers": [
			{"type": "tone", "f0": 38.0, "f1": 30.0, "am_rate": 7.0, "am_depth": 0.4, "lp": 200.0, "gain": 1.0, "env": [0.6, 0.4, 0.8, 0.8]},
			{"type": "noise", "color": "brown", "f0": 140.0, "gain": 0.8, "env": [0.5, 0.5, 0.8, 0.7]},
			{"type": "crackle", "rate": 42.0, "decay": 0.02, "f_lp": 1500.0, "start": 0.4, "gain": 0.5, "env": [0.4, 0.4, 0.7, 0.5]},
			{"type": "thuds", "count": 4, "fa": 60.0, "fb": 110.0, "start": 0.9, "dur": 1.2, "gain": 0.6},
		]},
		"quake_out": {"length": 1.9, "peak": 0.85, "lp": 1600.0, "layers": [
			{"type": "thuds", "count": 9, "fa": 70.0, "fb": 130.0, "dur": 1.5, "gain": 0.8},
			{"type": "noise", "color": "brown", "f0": 200.0, "f1": 90.0, "gain": 0.7, "env": [0.02, 1.2, 0.0, 0.5]},
			{"type": "crackle", "rate": 70.0, "decay": 0.015, "f_lp": 1800.0, "dur": 1.3, "gain": 0.45, "env": [0.01, 0.8, 0.2, 0.4]},
		]},
		# Tremor warning + shake (1.0 s announce, 1.4 s shake): a deep swell, then thuds.
		"tremor": {"length": 2.6, "peak": 0.85, "lp": 1400.0, "layers": [
			{"type": "tone", "f0": 880.0, "dur": .12, "gain": .9, "env": [.005,.035,.35,.04]},
			{"type": "tone", "f0": 1174.66, "start": .20, "dur": .12, "gain": .9, "env": [.005,.035,.35,.04]},
			{"type": "tone", "f0": 34.0, "f1": 28.0, "am_rate": 9.0, "am_depth": 0.45, "lp": 180.0, "gain": 1.0, "env": [0.8, 0.4, 0.85, 0.7]},
			{"type": "noise", "color": "brown", "f0": 120.0, "gain": 0.75, "am_rate": 6.0, "am_depth": 0.3, "env": [0.9, 0.4, 0.8, 0.7]},
			{"type": "crackle", "rate": 55.0, "decay": 0.02, "f_lp": 1300.0, "start": 1.0, "dur": 1.3, "gain": 0.45, "env": [0.1, 0.5, 0.6, 0.4]},
			{"type": "thuds", "count": 5, "fa": 55.0, "fb": 100.0, "start": 1.0, "dur": 1.2, "gain": 0.55},
		]},
		"flood_in": {"length": 2.4, "peak": 0.85, "lp": 2400.0, "layers": [
			{"type": "noise", "color": "pink", "f0": 300.0, "f1": 1600.0, "q": 0.7, "gain": 0.9, "am_rate": 0.7, "am_depth": 0.3, "env": [1.3, 0.4, 0.7, 0.6]},
			{"type": "noise", "color": "brown", "f0": 220.0, "gain": 0.6, "env": [1.0, 0.5, 0.8, 0.6]},
			{"type": "blips", "rate": 14.0, "fa": 180.0, "fb": 520.0, "blip": 0.05, "start": 0.6, "gain": 0.22},
		]},
		"flood_out": {"length": 1.9, "peak": 0.75, "lp": 2000.0, "layers": [
			{"type": "noise", "color": "pink", "f0": 1400.0, "f1": 200.0, "q": 0.8, "gain": 0.8, "am_rate": 4.5, "am_depth": 0.45, "env": [0.05, 1.0, 0.3, 0.6]},
			{"type": "blips", "rate": 10.0, "fa": 500.0, "fb": 180.0, "blip": 0.06, "gain": 0.2},
			{"type": "tone", "f0": 160.0, "f1": 60.0, "lp": 400.0, "gain": 0.25, "env": [0.1, 1.0, 0.2, 0.5]},
		]},
		"fire_in": {"length": 2.1, "peak": 0.85, "lp": 3000.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 300.0, "f1": 2300.0, "q": 0.5, "gain": 0.9, "env": [0.35, 0.5, 0.6, 0.7]},
			{"type": "noise", "color": "brown", "f0": 300.0, "gain": 0.7, "env": [0.4, 0.6, 0.7, 0.6]},
			{"type": "crackle", "rate": 35.0, "decay": 0.004, "f_lp": 3200.0, "start": 0.3, "gain": 0.45, "env": [0.2, 0.4, 0.8, 0.5]},
		]},
		"fire_out": {"length": 1.7, "peak": 0.65, "lp": 2400.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1900.0, "f1": 900.0, "q": 0.7, "gain": 0.6, "env": [0.03, 1.0, 0.2, 0.5]},
			{"type": "crackle", "rate": 12.0, "decay": 0.004, "f_lp": 2500.0, "gain": 0.3, "env": [0.02, 0.8, 0.3, 0.5]},
			{"type": "noise", "color": "brown", "f0": 200.0, "gain": 0.4, "env": [0.02, 1.0, 0.1, 0.4]},
		]},
		"titan_in": {"length": 2.7, "peak": 0.9, "lp": 2400.0, "layers": [
			{"type": "tone", "wave": "horn", "f0": 55.0, "chord": [1.0, 1.5, 2.0], "vibrato": [5.0, 0.08], "lp": 900.0, "gain": 0.85, "env": [0.5, 0.6, 0.8, 0.9]},
			{"type": "tone", "f0": 120.0, "f1": 32.0, "glide": 1.4, "start": 0.9, "gain": 0.9, "env": [0.05, 1.2, 0.4, 0.4]},
			{"type": "noise", "color": "brown", "f0": 1200.0, "f1": 150.0, "start": 0.3, "dur": 1.1, "gain": 0.8, "env": [0.005, 0.6, 0.3, 0.3]},
			{"type": "crackle", "rate": 150.0, "decay": 0.008, "f_lp": 2400.0, "start": 0.3, "dur": 0.25, "gain": 0.45, "env": [0.003, 0.15, 0.2, 0.08]},
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 400.0, "f1": 1200.0, "q": 0.5, "gain": 0.35, "env": [1.0, 0.5, 0.5, 0.6]},
		]},
		"titan_fuse": {"length": 1.7, "peak": 0.92, "lp": 2400.0, "layers": [
			{"type": "tone", "f0": 72.0, "f1": 30.0, "glide": 0.5, "gain": 1.0, "env": [0.003, 0.9, 0.0, 0.5]},
			{"type": "noise", "color": "brown", "f0": 1500.0, "f1": 120.0, "gain": 0.9, "env": [0.002, 0.8, 0.2, 0.5]},
			{"type": "crackle", "rate": 200.0, "decay": 0.01, "f_lp": 2800.0, "dur": 0.45, "gain": 0.5, "env": [0.002, 0.3, 0.2, 0.1]},
			{"type": "tone", "wave": "horn", "f0": 82.5, "lp": 800.0, "dur": 0.9, "gain": 0.3, "env": [0.02, 0.5, 0.2, 0.3]},
		]},
		"titan_out": {"length": 2.7, "peak": 0.88, "lp": 1800.0, "layers": [
			{"type": "thuds", "count": 14, "fa": 55.0, "fb": 120.0, "dur": 2.1, "gain": 0.85},
			{"type": "noise", "color": "brown", "f0": 300.0, "f1": 80.0, "gain": 0.8, "env": [0.05, 1.8, 0.2, 0.6]},
			{"type": "tone", "wave": "horn", "f0": 82.5, "f1": 41.0, "lp": 700.0, "gain": 0.4, "env": [0.2, 1.8, 0.0, 0.5]},
			{"type": "crackle", "rate": 60.0, "decay": 0.015, "f_lp": 1800.0, "gain": 0.4, "env": [0.05, 1.6, 0.2, 0.6]},
		]},
		# ---------------------------------------------- telegraph / casts ----
		"warn": {"length": 0.3, "peak": 0.5, "lp": 2600.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 740.0, "lp": 2200.0, "dur": 0.24, "gain": 0.6, "env": [0.006, 0.18, 0.0, 0.05]},
			{"type": "tone", "f0": 1110.0, "lp": 2200.0, "start": 0.07, "dur": 0.2, "gain": 0.28, "env": [0.006, 0.15, 0.0, 0.04]},
		]},
		"cast_storm": {"length": 0.4, "peak": 0.75, "lp": 3800.0, "layers": [
			{"type": "noise", "filter": "bp", "f0": 900.0, "f1": 3000.0, "q": 0.45, "gain": 0.8, "env": [0.01, 0.28, 0.0, 0.06]},
			{"type": "noise", "color": "brown", "f0": 300.0, "gain": 0.35, "env": [0.01, 0.2, 0.0, 0.08]},
		]},
		"cast_quake": {"length": 0.56, "peak": 0.85, "lp": 1800.0, "layers": [
			{"type": "tone", "f0": 80.0, "f1": 38.0, "glide": 0.1, "gain": 1.0, "env": [0.003, 0.45, 0.0, 0.08]},
			{"type": "noise", "color": "brown", "f0": 600.0, "gain": 0.6, "dur": 0.3, "env": [0.002, 0.15, 0.0, 0.1]},
			{"type": "crackle", "rate": 60.0, "decay": 0.012, "f_lp": 1600.0, "dur": 0.22, "gain": 0.25, "env": [0.003, 0.12, 0.2, 0.06]},
		]},
		"cast_flood": {"length": 0.5, "peak": 0.75, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1800.0, "f1": 600.0, "q": 0.6, "gain": 0.8, "env": [0.004, 0.35, 0.0, 0.1]},
			{"type": "blips", "rate": 30.0, "fa": 300.0, "fb": 900.0, "blip": 0.04, "gain": 0.22},
			{"type": "noise", "color": "brown", "f0": 400.0, "gain": 0.4, "dur": 0.25, "env": [0.004, 0.15, 0.0, 0.08]},
		]},
		"cast_fire": {"length": 0.56, "peak": 0.8, "lp": 2800.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 400.0, "f1": 1600.0, "q": 0.55, "gain": 0.9, "env": [0.02, 0.35, 0.2, 0.15]},
			{"type": "noise", "color": "brown", "f0": 260.0, "gain": 0.6, "env": [0.02, 0.35, 0.1, 0.15]},
			{"type": "crackle", "rate": 40.0, "decay": 0.004, "f_lp": 3000.0, "gain": 0.3, "env": [0.02, 0.3, 0.3, 0.1]},
		]},
		# ------------------------------------------- projectiles / impacts ----
		"whoosh": {"length": 0.24, "peak": 0.6, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 500.0, "f1": 1300.0, "q": 0.6, "gain": 0.75, "env": [0.03, 0.12, 0.0, 0.06]},
		]},
		"impact_glass": {"length": 0.32, "peak": 0.55, "lp": 4200.0, "layers": [
			{"type": "crackle", "rate": 90.0, "decay": 0.003, "f_lp": 3800.0, "dur": 0.18, "gain": 0.55, "env": [0.002, 0.12, 0.0, 0.04]},
			{"type": "tone", "wave": "bell", "f0": 1180.0, "lp": 3000.0, "gain": 0.18, "env": [0.002, 0.2, 0.0, 0.06]},
			{"type": "noise", "filter": "bp", "f0": 2400.0, "q": 0.8, "gain": 0.3, "dur": 0.08, "env": [0.002, 0.05, 0.0, 0.02]},
		]},
		"impact_wood": {"length": 0.26, "peak": 0.65, "lp": 2200.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 180.0, "f1": 120.0, "lp": 1200.0, "gain": 0.8, "env": [0.002, 0.13, 0.0, 0.06]},
			{"type": "noise", "filter": "bp", "f0": 700.0, "q": 0.7, "gain": 0.5, "dur": 0.1, "env": [0.002, 0.06, 0.0, 0.03]},
		]},
		"impact_stone": {"length": 0.36, "peak": 0.7, "lp": 1900.0, "layers": [
			{"type": "tone", "f0": 110.0, "f1": 70.0, "gain": 0.8, "env": [0.002, 0.22, 0.0, 0.08]},
			{"type": "noise", "color": "brown", "f0": 800.0, "gain": 0.6, "dur": 0.18, "env": [0.002, 0.1, 0.0, 0.05]},
			{"type": "crackle", "rate": 60.0, "decay": 0.01, "f_lp": 1800.0, "dur": 0.16, "gain": 0.35, "env": [0.002, 0.1, 0.0, 0.04]},
		]},
		"impact_metal": {"length": 0.36, "peak": 0.55, "lp": 3000.0, "layers": [
			{"type": "tone", "wave": "bell", "f0": 320.0, "lp": 2800.0, "gain": 0.55, "env": [0.002, 0.26, 0.0, 0.08]},
			{"type": "noise", "filter": "bp", "f0": 1800.0, "q": 0.7, "gain": 0.3, "dur": 0.07, "env": [0.002, 0.04, 0.0, 0.02]},
		]},
		"impact_water": {"length": 0.32, "peak": 0.6, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1200.0, "f1": 500.0, "q": 0.6, "gain": 0.7, "env": [0.004, 0.2, 0.0, 0.08]},
			{"type": "blips", "rate": 9.0, "fa": 260.0, "fb": 700.0, "blip": 0.04, "gain": 0.2},
		]},
		"impact_fire": {"length": 0.32, "peak": 0.5, "lp": 2500.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1700.0, "q": 0.8, "gain": 0.55, "env": [0.005, 0.22, 0.0, 0.06]},
			{"type": "crackle", "rate": 50.0, "decay": 0.004, "f_lp": 3000.0, "gain": 0.35, "env": [0.003, 0.2, 0.0, 0.06]},
		]},
		"block": {"length": 0.42, "peak": 0.65, "lp": 2600.0, "layers": [
			{"type": "tone", "wave": "bell", "f0": 220.0, "lp": 2400.0, "gain": 0.55, "env": [0.002, 0.3, 0.0, 0.08]},
			{"type": "tone", "f0": 96.0, "f1": 62.0, "gain": 0.6, "env": [0.002, 0.18, 0.0, 0.06]},
			{"type": "noise", "filter": "bp", "f0": 1500.0, "q": 0.7, "gain": 0.25, "dur": 0.06, "env": [0.002, 0.03, 0.0, 0.02]},
		]},
		# ---------------------------------------------------------- player ----
		"jump": {"length": 0.2, "peak": 0.55, "lp": 2000.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 180.0, "f1": 320.0, "lp": 1400.0, "gain": 0.6, "env": [0.004, 0.12, 0.0, 0.05]},
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 900.0, "q": 0.7, "gain": 0.25, "dur": 0.1, "env": [0.004, 0.05, 0.0, 0.03]},
		]},
		"floor_up": {"length": 0.44, "peak": 0.6, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 400.0, "f1": 1700.0, "q": 0.5, "gain": 0.7, "env": [0.04, 0.3, 0.0, 0.08]},
			{"type": "tone", "wave": "warm", "f0": 220.0, "f1": 440.0, "lp": 1500.0, "gain": 0.28, "env": [0.01, 0.3, 0.0, 0.08]},
		]},
		"drop_land": {"length": 0.24, "peak": 0.7, "lp": 1600.0, "layers": [
			{"type": "tone", "f0": 120.0, "f1": 70.0, "gain": 0.8, "env": [0.002, 0.1, 0.0, 0.06]},
			{"type": "noise", "color": "brown", "f0": 500.0, "gain": 0.5, "dur": 0.1, "env": [0.002, 0.05, 0.0, 0.03]},
		]},
		"dash": {"length": 0.28, "peak": 0.65, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1400.0, "f1": 500.0, "q": 0.55, "gain": 0.9, "env": [0.01, 0.15, 0.0, 0.06]},
		]},
		"dodge": {"length": 0.62, "peak": 0.45, "lp": 3800.0, "layers": [
			{"type": "tone", "f0": 1046.5, "chord": [1.0, 1.4983], "lp": 3200.0, "gain": 0.7, "env": [0.004, 0.45, 0.0, 0.1]},
			{"type": "tone", "wave": "warm", "f0": 523.25, "lp": 2000.0, "gain": 0.25, "env": [0.004, 0.3, 0.0, 0.1]},
			{"type": "noise", "filter": "bp", "f0": 3200.0, "q": 0.9, "gain": 0.05, "env": [0.01, 0.3, 0.0, 0.1]},
		]},
		# Graze: a short, soft electric tick with a rising sparkle (never harsh).
		"graze": {"length": 0.22, "peak": 0.42, "lp": 3400.0, "layers": [
			{"type": "tone", "f0": 1174.7, "f1": 1568.0, "lp": 3000.0, "gain": 0.5, "env": [0.003, 0.1, 0.0, 0.05]},
			{"type": "noise", "filter": "bp", "f0": 2400.0, "q": 1.1, "gain": 0.22, "dur": 0.05, "env": [0.003, 0.03, 0.0, 0.02]},
			{"type": "crackle", "rate": 55.0, "decay": 0.003, "f_lp": 2800.0, "gain": 0.1, "env": [0.003, 0.08, 0.0, 0.04]},
		]},
		"hurt": {"length": 0.34, "peak": 0.8, "lp": 1600.0, "layers": [
			{"type": "tone", "f0": 140.0, "f1": 60.0, "gain": 0.9, "env": [0.002, 0.2, 0.0, 0.08]},
			{"type": "noise", "color": "brown", "f0": 700.0, "gain": 0.6, "dur": 0.15, "env": [0.002, 0.08, 0.0, 0.04]},
		]},
		# ------------------------------------------------------------ loot ----
		"loot_drop": {"length": 0.22, "peak": 0.55, "lp": 1800.0, "layers": [
			{"type": "tone", "f0": 160.0, "f1": 100.0, "gain": 0.6, "env": [0.002, 0.12, 0.0, 0.05]},
			{"type": "noise", "f0": 900.0, "gain": 0.3, "dur": 0.08, "env": [0.002, 0.04, 0.0, 0.02]},
		]},
		"pickup": {"length": 0.42, "peak": 0.5, "lp": 2400.0, "layers": [
			{"type": "noise", "filter": "bp", "f0": 2200.0, "q": 0.7, "gain": 0.2, "dur": 0.04, "env": [0.002, 0.02, 0.0, 0.015]},
			{"type": "tone", "wave": "warm", "f0": 392.0, "dur": 0.2, "lp": 1800.0, "gain": 0.6, "env": [0.006, 0.12, 0.2, 0.06]},
			{"type": "tone", "wave": "warm", "f0": 523.25, "start": 0.09, "dur": 0.3, "lp": 1800.0, "gain": 0.6, "env": [0.006, 0.16, 0.2, 0.1]},
		]},
		"heal": {"length": 0.95, "peak": 0.5, "lp": 2000.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 261.6, "chord": [1.0, 1.26, 1.4983], "lp": 1600.0, "gain": 0.75, "env": [0.06, 0.4, 0.5, 0.4]},
			{"type": "noise", "filter": "bp", "f0": 2600.0, "q": 0.9, "gain": 0.05, "env": [0.1, 0.4, 0.3, 0.3]},
		]},
		"safety": {"length": 0.62, "peak": 0.5, "lp": 2600.0, "layers": [
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 1900.0, "f1": 1200.0, "q": 0.8, "gain": 0.45, "env": [0.01, 0.4, 0.0, 0.15]},
			{"type": "tone", "wave": "bell", "f0": 260.0, "lp": 2200.0, "gain": 0.4, "dur": 0.3, "env": [0.002, 0.2, 0.0, 0.06]},
		]},
		"repair": {"length": 1.15, "peak": 0.65, "lp": 2800.0, "layers": [
			{"type": "tone", "wave": "bell", "f0": 300.0, "lp": 2600.0, "dur": 0.3, "gain": 0.55, "env": [0.002, 0.22, 0.0, 0.06]},
			{"type": "tone", "wave": "bell", "f0": 285.0, "lp": 2600.0, "start": 0.2, "dur": 0.3, "gain": 0.5, "env": [0.002, 0.22, 0.0, 0.06]},
			{"type": "crackle", "rate": 45.0, "decay": 0.006, "f_lp": 2400.0, "start": 0.36, "dur": 0.26, "gain": 0.35, "env": [0.01, 0.1, 0.8, 0.05]},
			{"type": "noise", "color": "pink", "filter": "bp", "f0": 600.0, "f1": 200.0, "q": 0.6, "start": 0.6, "dur": 0.26, "gain": 0.45, "env": [0.01, 0.15, 0.3, 0.08]},
			{"type": "tone", "f0": 92.0, "f1": 60.0, "start": 0.8, "dur": 0.2, "gain": 0.6, "env": [0.002, 0.12, 0.0, 0.05]},
			{"type": "tone", "wave": "warm", "f0": 523.25, "chord": [1.0, 1.26], "start": 0.84, "dur": 0.3, "lp": 2000.0, "gain": 0.5, "env": [0.01, 0.12, 0.4, 0.12]},
		]},
		# ----------------------------------------------------------- state ----
		# Bolting an L-bracket: two ratchet clinks and a short metal tick.
		"secure": {"length": 0.5, "peak": 0.6, "lp": 2600.0, "layers": [
			{"type": "tone", "wave": "bell", "f0": 220.0, "lp": 2200.0, "gain": 0.6, "env": [0.003, 0.2, 0.0, 0.08]},
			{"type": "tone", "wave": "bell", "f0": 262.0, "start": 0.16, "lp": 2200.0, "gain": 0.6, "env": [0.003, 0.22, 0.0, 0.1]},
			{"type": "noise", "filter": "bp", "f0": 1400.0, "q": 0.7, "gain": 0.25, "dur": 0.06, "env": [0.002, 0.03, 0.0, 0.02]},
		]},
		# A room just got damaged: a short two-tone alert ping.
		"alarm": {"length": 0.42, "peak": 0.55, "lp": 2400.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 660.0, "dur": 0.16, "lp": 2000.0, "gain": 0.7, "env": [0.004, 0.1, 0.2, 0.05]},
			{"type": "tone", "wave": "warm", "f0": 523.0, "start": 0.15, "dur": 0.22, "lp": 2000.0, "gain": 0.7, "env": [0.004, 0.14, 0.2, 0.08]},
		]},
		# Dropping into Çök-Kapan-Tutun: a soft cloth rustle and knee thump.
		"cover": {"length": 0.22, "peak": 0.5, "lp": 1600.0, "layers": [
			{"type": "noise", "color": "pink", "f0": 500.0, "q": 0.8, "gain": 0.6, "env": [0.01, 0.1, 0.0, 0.06]},
			{"type": "tone", "f0": 90.0, "f1": 60.0, "glide": 0.08, "gain": 0.5, "env": [0.004, 0.1, 0.0, 0.05]},
		]},
		# A tall cabinet slams onto the floor.
		"topple": {"length": 0.8, "peak": 0.8, "lp": 2000.0, "layers": [
			{"type": "noise", "color": "brown", "f0": 300.0, "f1": 120.0, "gain": 0.8, "env": [0.005, 0.35, 0.0, 0.3]},
			{"type": "tone", "f0": 70.0, "f1": 42.0, "glide": 0.2, "gain": 0.9, "env": [0.004, 0.3, 0.0, 0.15]},
			{"type": "crackle", "rate": 90.0, "decay": 0.01, "f_lp": 1800.0, "dur": 0.4, "gain": 0.4, "env": [0.003, 0.25, 0.1, 0.1]},
		]},
		"collapse_room": {"length": 1.5, "peak": 0.82, "lp": 1600.0, "layers": [
			{"type": "thuds", "count": 7, "fa": 60.0, "fb": 120.0, "dur": 1.1, "gain": 0.8},
			{"type": "noise", "color": "brown", "f0": 260.0, "f1": 90.0, "gain": 0.7, "env": [0.02, 1.0, 0.1, 0.4]},
			{"type": "crackle", "rate": 60.0, "decay": 0.012, "f_lp": 1800.0, "dur": 1.0, "gain": 0.4, "env": [0.01, 0.7, 0.1, 0.3]},
		]},
		"collapse_building": {"length": 2.9, "peak": 0.9, "lp": 1500.0, "layers": [
			{"type": "thuds", "count": 18, "fa": 45.0, "fb": 110.0, "dur": 2.4, "gain": 0.9},
			{"type": "tone", "f0": 60.0, "f1": 28.0, "glide": 2.0, "gain": 0.8, "env": [0.05, 2.2, 0.2, 0.6]},
			{"type": "noise", "color": "brown", "f0": 400.0, "f1": 70.0, "gain": 0.8, "env": [0.02, 2.0, 0.2, 0.7]},
			{"type": "crackle", "rate": 70.0, "decay": 0.015, "f_lp": 1700.0, "gain": 0.4, "env": [0.02, 1.8, 0.2, 0.7]},
		]},
		"victory": {"length": 2.3, "peak": 0.55, "lp": 2000.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 196.0, "chord": [1.0, 1.26, 1.4983], "dur": 1.2, "lp": 1500.0, "gain": 0.7, "env": [0.1, 0.4, 0.6, 0.3]},
			{"type": "tone", "wave": "warm", "f0": 261.6, "chord": [1.0, 1.26, 1.4983, 2.0], "start": 0.95, "lp": 1600.0, "gain": 0.75, "env": [0.12, 0.5, 0.6, 0.6]},
		]},
		"defeat": {"length": 1.9, "peak": 0.6, "lp": 1200.0, "layers": [
			{"type": "tone", "wave": "warm", "f0": 146.8, "f1": 110.0, "chord": [1.0, 1.1892], "lp": 900.0, "gain": 0.75, "env": [0.08, 0.9, 0.4, 0.6]},
			{"type": "noise", "color": "brown", "f0": 200.0, "gain": 0.4, "env": [0.1, 1.0, 0.3, 0.5]},
		]},
	}
