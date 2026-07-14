class_name ArchiveSoundscape
extends Node

var _ambient: AudioStreamPlayer
var _event_players: Array[AudioStreamPlayer] = []
var _event_cursor: int = 0
var _cast_sound: AudioStreamWAV
var _collect_sound: AudioStreamWAV
var _hurt_sound: AudioStreamWAV
var _resonance_sound: AudioStreamWAV
var _verdict_sound: AudioStreamWAV
var _disperse_sound: AudioStreamWAV


@override
func _ready() -> void:
	_ambient = AudioStreamPlayer.new()
	_ambient.name = "ArchiveAmbience"
	_ambient.stream = _build_ambient()
	_ambient.volume_db = -16.0
	add_child(_ambient)
	_ambient.play()
	for index: int in range(6):
		var player := AudioStreamPlayer.new()
		player.name = "MemoryVoice%d" % index
		add_child(player)
		_event_players.append(player)
	_cast_sound = _build_chime(0.11, 520.0, 910.0, 0.28)
	_collect_sound = _build_chime(0.5, 420.0, 1260.0, 0.36)
	_hurt_sound = _build_chime(0.24, 115.0, 72.0, 0.42)
	_resonance_sound = _build_chime(0.65, 180.0, 760.0, 0.45)
	_verdict_sound = _build_chime(1.15, 240.0, 980.0, 0.4)
	_disperse_sound = _build_chime(0.32, 310.0, 120.0, 0.3)


func play_cast() -> void:
	_play_event(_cast_sound, -13.0, randf_range(0.96, 1.04))


func play_collect() -> void:
	_play_event(_collect_sound, -7.0, randf_range(0.96, 1.03))


func play_hurt() -> void:
	_play_event(_hurt_sound, -8.0, randf_range(0.92, 1.0))


func play_resonance() -> void:
	_play_event(_resonance_sound, -6.0, 1.0)


func play_verdict() -> void:
	_play_event(_verdict_sound, -5.0, 1.0)


func play_disperse(large: bool = false) -> void:
	_play_event(_disperse_sound, -6.0 if large else -10.0, 0.72 if large else randf_range(0.94, 1.08))


func set_combat_intensity(intensity: float) -> void:
	if is_instance_valid(_ambient):
		_ambient.pitch_scale = lerpf(0.98, 1.04, clampf(intensity, 0.0, 1.0))
		_ambient.volume_db = lerpf(-17.0, -12.5, clampf(intensity, 0.0, 1.0))


@private
func _play_event(stream: AudioStreamWAV, volume: float, pitch: float) -> void:
	if _event_players.is_empty():
		return
	var player := _event_players[_event_cursor]
	_event_cursor = (_event_cursor + 1) % _event_players.size()
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()


@private
func _build_ambient() -> AudioStreamWAV:
	var sample_rate := 16000
	var duration := 12.0
	var sample_count := floori(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for index: int in range(sample_count):
		var time := float(index) / float(sample_rate)
		var tide := 0.52 + 0.48 * sin(time * TAU / duration)
		var drone := sin(time * TAU * 55.0) * 0.16 + sin(time * TAU * 82.5) * 0.09
		var choir := sin(time * TAU * 110.0 + sin(time * 0.37) * 0.7) * 0.055
		var bell_envelope := pow(maxf(0.0, 1.0 - fmod(time + 0.4, 3.0) / 3.0), 5.0)
		var bell := sin(time * TAU * 660.0) * bell_envelope * 0.055
		var sample := (drone * (0.72 + tide * 0.28) + choir + bell) * 0.65
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	var wave := AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = sample_rate
	wave.stereo = false
	wave.data = data
	wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wave.loop_begin = 0
	wave.loop_end = sample_count
	return wave


@private
func _build_chime(duration: float, start_frequency: float, end_frequency: float, gain: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := floori(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for index: int in range(sample_count):
		var progress := float(index) / float(sample_count)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / float(sample_rate)
		var envelope := pow(1.0 - progress, 2.4) * sin(minf(1.0, progress * 14.0) * PI * 0.5)
		var sample := (sin(phase) + sin(phase * 2.01) * 0.24) * envelope * gain
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	var wave := AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = sample_rate
	wave.stereo = false
	wave.data = data
	return wave
