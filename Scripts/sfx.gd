# SFX.gd
class_name SFX
extends AudioStreamPlayer2D

@export var tracks: Dictionary[String, AudioStream] = {}
@export var pool_size: int = 8
@export var pitch_variance: float = 0.05
@export var volume_variance_db: float = 1.0
@export var default_volume_db: float = 0.0
@export var min_intervals: Dictionary = {"Moving": 0.45}

var _pool: Array[AudioStreamPlayer2D] = []
var _pool_index: int = -1
var _last_played: Dictionary = {} # track -> last played time (seconds)
var active_sfx: Array = []        # transient players created by play_sfx_overlap()

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_init_pool()
	# Connect to Events' signal if Events autoload exists and has the signal
	Events.play_sfx_signal.connect(_on_play_sfx_signal)
	print_debug("[SFX] default_volume_db:", default_volume_db, "pool_size:", pool_size)

func _init_pool() -> void:
	# remove any previously created pooled children safely
	for child in _pool:
		if is_instance_valid(child) and child.get_parent() == self:
			child.queue_free()
	_pool.clear()
	_pool_index = -1
	for i in range(max(pool_size, 0)):
		var p := AudioStreamPlayer2D.new()
		p.bus = "SFX"
		p.volume_db = default_volume_db
		p.pitch_scale = 1.0
		p.autoplay = false
		p.stop()
		add_child(p)
		_pool.append(p)

func _get_next_player() -> AudioStreamPlayer2D:
	if _pool.size() == 0:
		push_error("SFX pool is empty.")
		return null
	_pool_index = (_pool_index + 1) % _pool.size()
	return _pool[_pool_index]

func _rand_variation(min_v: float, max_v: float) -> float:
	return _rng.randf_range(min_v, max_v)

func _on_play_sfx_signal(track: String, pos: Vector2 = Vector2(), overlap: bool = true, restart_same: bool = true) -> void:
	# debug entry
	print_debug("[SFX] signal:", track, "pos:", pos, "overlap:", overlap, "restart_same:", restart_same)

	# quick validation
	if not tracks.has(track):
		print_debug("[SFX] track not found in tracks dict:", track)
		return

	if track == "Idle":
		stop_sfx("Moving")
		return

	var stream := tracks[track] as AudioStream
	if stream == null:
		print_debug("[SFX] stream is null for track:", track)
		return

	# rate limiter
	var now: float = Time.get_ticks_usec() / 1_000_000.0
	var min_i := 0.0
	if min_intervals.has(track):
		min_i = float(min_intervals[track])
	if _last_played.has(track):
		var last := float(_last_played[track])
		if now - last < min_i:
			print_debug("[SFX] rate-limited:", track, "time since last:", now - last, "min:", min_i)
			return
	_last_played[track] = now

	if not overlap:
		var main := _pool[0] if _pool.size() > 0 else null
		if main == null:
			print_debug("[SFX] no main player in pool")
			return
		# if same stream already playing
		if main.stream == stream and main.is_playing():
			if restart_same:
				main.stop()
			else:
				print_debug("[SFX] main already playing same track, skipping:", track)
				return
		main.stop()
		main.stream = stream
		main.global_position = pos
		main.pitch_scale = 1.0 + _rand_variation(-pitch_variance, pitch_variance)
		main.volume_db = default_volume_db + _rand_variation(-volume_variance_db, volume_variance_db)
		main.play()
		print_debug("[SFX] playing non-overlap on main:", track)
		return

	# overlap -> use pooled player
	var p := _get_next_player()
	if p == null:
		print_debug("[SFX] no pooled player available")
		return
	p.stop()
	p.stream = stream
	p.global_position = pos
	p.pitch_scale = 1.0 + _rand_variation(-pitch_variance, pitch_variance)
	p.volume_db = default_volume_db + _rand_variation(-volume_variance_db, volume_variance_db)
	p.play()
	print_debug("[SFX] playing (pooled) track:", track, "pool_index:", _pool_index)

func play_sfx_overlap(track: String, pos: Vector2 = Vector2.ZERO) -> void:
	if not tracks.has(track):
		print_debug("[SFX] play_sfx_overlap: track not present:", track)
		return
	var stream := tracks[track] as AudioStream
	if stream == null:
		print_debug("[SFX] play_sfx_overlap: stream null for:", track)
		return

	var p := AudioStreamPlayer2D.new()
	p.bus = "SFX"
	p.stream = stream
	p.global_position = pos
	add_child(p)
	active_sfx.append(p)
	p.play()
	# free when finished
	p.finished.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free()
			active_sfx.erase(p)
	)

func stop_sfx(track: String) -> void:
	var the_stream = tracks.get(track, null)
	# stop/destroy active transient players matching the stream
	for sfx in active_sfx.duplicate():
		if is_instance_valid(sfx) and sfx.stream == the_stream:
			sfx.stop()
			sfx.queue_free()
			active_sfx.erase(sfx)
	# stop pooled players playing that stream, don't free them
	for p in _pool:
		if is_instance_valid(p) and p.stream == the_stream and p.is_playing():
			p.stop()
			# clear stream to avoid lingering equality matches
			p.stream = null
	print_debug("[SFX] stop_sfx called for:", track)

func set_min_interval(track: String, secs: float) -> void:
	min_intervals[track] = secs

func force_play(track: String, pos: Vector2 = Vector2(), overlap: bool = true) -> void:
	_last_played[track] = Time.get_ticks_usec() / 1_000_000.0
	_on_play_sfx_signal(track, pos, overlap, true)
