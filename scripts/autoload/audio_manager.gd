extends Node

const MIX_RATE := 12000

var ambience_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var _tones: Dictionary = {}

func _ready() -> void:
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "Ambience"
	ambience_player.volume_db = -24.0
	add_child(ambience_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFX"
	sfx_player.volume_db = -13.0
	add_child(sfx_player)
	ambience_player.stream = _make_ambience()
	_tones["ui"] = _make_tone(0.08, 310.0, 0.18)
	_tones["discover"] = _make_tone(0.22, 230.0, 0.20)
	_tones["success"] = _make_tone(0.34, 180.0, 0.18)
	_tones["fail"] = _make_tone(0.18, 120.0, 0.12)
	_tones["step"] = _make_tone(0.07, 85.0, 0.08)

func play_ambience() -> void:
	if ambience_player.stream != null and not ambience_player.playing:
		ambience_player.play()

func play_ui() -> void:
	_play_tone("ui")

func play_discovery() -> void:
	_play_tone("discover")

func play_success() -> void:
	_play_tone("success")

func play_fail() -> void:
	_play_tone("fail")

func play_step() -> void:
	_play_tone("step", -8.0)

func _play_tone(kind: String, extra_db := 0.0) -> void:
	if not _tones.has(kind):
		return
	sfx_player.stop()
	sfx_player.stream = _tones[kind]
	sfx_player.volume_db = -13.0 + extra_db
	sfx_player.play()

func _make_ambience() -> AudioStreamWAV:
	var sample_count: int = int(4.0 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(MIX_RATE)
		var hum: float = sin(TAU * 54.0 * t) * 0.045 + sin(TAU * 108.0 * t) * 0.018
		var texture: float = sin(float(i) * 0.173) * sin(float(i) * 0.071) * 0.012
		samples[i] = hum + texture
	var wav: AudioStreamWAV = _samples_to_wav(samples)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

func _make_tone(seconds: float, frequency: float, amplitude: float) -> AudioStreamWAV:
	var sample_count: int = maxi(1, int(seconds * MIX_RATE))
	var samples := PackedFloat32Array()
	samples.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(MIX_RATE)
		var envelope: float = 1.0 - (float(i) / float(sample_count))
		samples[i] = (sin(TAU * frequency * t) + sin(TAU * frequency * 0.5 * t) * 0.35) * amplitude * envelope
	return _samples_to_wav(samples)

func _samples_to_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in range(samples.size()):
		var value: int = int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		if value < 0:
			value += 65536
		bytes[i * 2] = value & 0xff
		bytes[i * 2 + 1] = (value >> 8) & 0xff
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = bytes
	return wav
