class_name GameSoundscape
extends Node

var target: WayfarerController

var _wind: AudioStreamPlayer
var _wildlife: AudioStreamPlayer
var _harmony: AudioStreamPlayer
var _event_players: Array[AudioStreamPlayer] = []
var _event_cursor: int = 0
var _region_timer: float = 0.0
var _last_health: float = 100.0

var _sword_sound: AudioStreamWAV
var _hurt_sound: AudioStreamWAV
var _collect_sound: AudioStreamWAV
var _craft_sound: AudioStreamWAV
var _memory_sound: AudioStreamWAV
var _interaction_sound: AudioStreamWAV


func configure(target_value: WayfarerController) -> void:
	target = target_value


@override
func _ready() -> void:
	name = "GameSoundscape"
	_wind = _make_loop_player("WindLayer", _build_wind_loop(37.0, 91421), -22.0)
	_wildlife = _make_loop_player("WildlifeLayer", _build_wildlife_loop(43.0), -24.0)
	_harmony = _make_loop_player("MemoryHarmony", _build_harmony_loop(31.0), -27.0)
	for index: int in range(8):
		var event_player := AudioStreamPlayer.new()
		event_player.name = "WorldVoice_%d" % index
		add_child(event_player)
		_event_players.append(event_player)
	_sword_sound = _build_tone(0.22, 920.0, 180.0, 0.34, 0.32)
	_hurt_sound = _build_tone(0.34, 130.0, 62.0, 0.5, 0.2)
	_collect_sound = _build_tone(0.62, 410.0, 1180.0, 0.34, 0.35)
	_craft_sound = _build_tone(1.1, 170.0, 760.0, 0.42, 0.5)
	_memory_sound = _build_tone(1.45, 260.0, 980.0, 0.3, 0.62)
	_interaction_sound = _build_tone(0.16, 360.0, 480.0, 0.2, 0.18)
	if is_instance_valid(target):
		_last_health = target.current_health


@override
func _process(delta: float) -> void:
	_region_timer += delta
	if _region_timer < 1.0 or not is_instance_valid(target):
		return
	_region_timer = 0.0
	_update_region_mix(target.global_position)


@override
func _exit_tree() -> void:
	for player: AudioStreamPlayer in [_wind, _wildlife, _harmony] as Array[AudioStreamPlayer]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	for player: AudioStreamPlayer in _event_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_event_players.clear()
	_sword_sound = null
	_hurt_sound = null
	_collect_sound = null
	_craft_sound = null
	_memory_sound = null
	_interaction_sound = null


func play_sword() -> void:
	_play_event(_sword_sound, -8.0, randf_range(0.92, 1.08))


func play_collect() -> void:
	_play_event(_collect_sound, -7.0, randf_range(0.94, 1.06))


func play_craft() -> void:
	_play_event(_craft_sound, -5.0, randf_range(0.98, 1.02))


func play_memory() -> void:
	_play_event(_memory_sound, -5.0, randf_range(0.96, 1.04))


func play_interaction() -> void:
	_play_event(_interaction_sound, -15.0, randf_range(0.92, 1.08))


func on_health_changed(current: float, _maximum: float) -> void:
	if current < _last_health:
		_play_event(_hurt_sound, -6.0, randf_range(0.94, 1.04))
	_last_health = current


@private
func _make_loop_player(node_name: String, stream: AudioStreamWAV, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.stream = stream
	player.volume_db = volume
	add_child(player)
	player.play()
	return player


@private
func _update_region_mix(position: Vector3) -> void:
	var wind_target := -22.0
	var wildlife_target := -23.0
	var harmony_target := -27.0
	if position.z < -85.0:
		wind_target = -27.0
		wildlife_target = -30.0
		harmony_target = -17.5
	elif position.x > 105.0:
		wind_target = -18.0
		wildlife_target = -25.0
		harmony_target = -23.0
	elif position.z > 125.0:
		wind_target = -16.0
		wildlife_target = -38.0
		harmony_target = -20.0
	_wind.volume_db = lerpf(_wind.volume_db, wind_target, 0.12)
	_wildlife.volume_db = lerpf(_wildlife.volume_db, wildlife_target, 0.12)
	_harmony.volume_db = lerpf(_harmony.volume_db, harmony_target, 0.12)


@private
func _play_event(stream: AudioStreamWAV, volume: float, pitch: float) -> void:
	if _event_players.is_empty() or not is_instance_valid(stream):
		return
	var player := _event_players[_event_cursor]
	_event_cursor = (_event_cursor + 1) % _event_players.size()
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()


@private
func _build_wind_loop(duration: float, seed_value: int) -> AudioStreamWAV:
	var rate := 12000
	var count := floori(duration * rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var smooth_noise := 0.0
	for index: int in range(count):
		var time := float(index) / rate
		smooth_noise = lerpf(smooth_noise, random.randf_range(-1.0, 1.0), 0.008)
		var breath := 0.45 + sin(time * TAU / 13.7) * 0.2 + sin(time * TAU / 7.3) * 0.12
		var sample := smooth_noise * breath * 0.21 + sin(time * TAU * 73.0) * 0.012
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	return _wave(data, rate, count, true)


@private
func _build_wildlife_loop(duration: float) -> AudioStreamWAV:
	var rate := 12000
	var count := floori(duration * rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	var calls: Array[float] = [2.7, 8.9, 16.4, 27.1, 35.8, 40.2]
	for index: int in range(count):
		var time := float(index) / rate
		var sample := 0.0
		for call_time: float in calls:
			var local := time - call_time
			if local >= 0.0 and local < 0.72:
				var envelope := sin(local / 0.72 * PI) * (1.0 - local / 0.72)
				var frequency := 1380.0 + sin(local * 18.0) * 410.0
				sample += sin(time * TAU * frequency) * envelope * 0.13
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	return _wave(data, rate, count, true)


@private
func _build_harmony_loop(duration: float) -> AudioStreamWAV:
	var rate := 12000
	var count := floori(duration * rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	var notes: Array[float] = [73.42, 110.0, 146.83, 220.0]
	for index: int in range(count):
		var time := float(index) / rate
		var swell := 0.52 + sin(time * TAU / duration) * 0.25 + sin(time * TAU / 11.0) * 0.12
		var sample := 0.0
		for note_index: int in range(notes.size()):
			sample += sin(time * TAU * notes[note_index] + note_index * 0.7) * (0.034 / (note_index + 1.0))
		sample *= swell
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	return _wave(data, rate, count, true)


@private
func _build_tone(duration: float, start_frequency: float, end_frequency: float, gain: float, overtone: float) -> AudioStreamWAV:
	var rate := 22050
	var count := floori(duration * rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	var phase := 0.0
	for index: int in range(count):
		var progress := float(index) / count
		phase += TAU * lerpf(start_frequency, end_frequency, progress) / rate
		var envelope := pow(1.0 - progress, 2.2) * sin(minf(1.0, progress * 12.0) * PI * 0.5)
		var sample := (sin(phase) + sin(phase * 2.013) * overtone) * envelope * gain
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32767, 32767))
	return _wave(data, rate, count, false)


@private
func _wave(data: PackedByteArray, rate: int, count: int, looped: bool) -> AudioStreamWAV:
	var wave := AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = rate
	wave.stereo = false
	wave.data = data
	if looped:
		wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wave.loop_begin = 0
		wave.loop_end = count
	return wave
