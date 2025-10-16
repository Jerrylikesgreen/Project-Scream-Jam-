# SFX.gd
class_name SFX
extends AudioStreamPlayer2D

# Map of track name -> AudioStream (ogg/wav/etc.)
@export var tracks: Dictionary[String, AudioStream] = {}

@export var pool_size: int = 8
@export var pitch_variance: float = 0.05
@export var volume_variance_db: float = 1.0
@export var default_volume_db: float = 0.0

# Per-track minimum interval (seconds). Example default for footsteps.
@export var min_intervals: Dictionary = {"Moving": 0.45}

var _pool: Array[AudioStreamPlayer2D] = []
var _pool_index: int = -1
var _last_played: Dictionary = {} # track -> last played time (seconds)

var active_sfx: Array = []

func _ready() -> void:
	_init_pool()
	Events.play_sfx_signal.connect(_on_play_sfx_signal)

func _init_pool() -> void:
	_pool.clear()
	for i in range(pool_size):
		var p := AudioStreamPlayer2D.new()
		p.bus = "SFX"
		p.volume_db = default_volume_db
		p.pitch_scale = 1.0
		p.stop()
		add_child(p)
		_pool.append(p)

func _get_next_player() -> AudioStreamPlayer2D:
	if _pool.size() == 0:
		push_error("SFX pool is empty.")
		return null
	_pool_index = (_pool_index + 1) % _pool.size()
	return _pool[_pool_index]


func _on_play_sfx_signal(track: String, pos: Vector2 = Vector2(), overlap: bool = true, restart_same: bool = true) -> void:
	print("Signal Receive to play:  ", track)
	if track == "Idle":
		stop_sfx("Moving")
		return
		
	for sfx in active_sfx:
		if is_instance_valid(sfx):
			sfx.stop()
			sfx.queue_free()
			
	active_sfx.clear()

	
	var stream := tracks[track] as AudioStream
	if stream == null:
		return

	# --- rate-limiter (per-track cooldown) ---
	var now: float = Time.get_ticks_usec() / 1_000_000.0

	var min_i := 0.0
	if min_intervals.has(track):
		min_i = float(min_intervals[track])
	if _last_played.has(track):
		var last := float(_last_played[track])
		if now - last < min_i:
			# too soon, skip
			return
	_last_played[track] = now

	if not overlap:
		var main := _pool[0]
		if main == null:
			return
		if main.stream == stream and main.is_playing():
			if restart_same:
				main.stop()
			else:
				return
		main.stream = stream
		main.global_position = pos
		main.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
		main.volume_db = default_volume_db + randf_range(-volume_variance_db, volume_variance_db)
		main.play()
		return

	var p := _get_next_player()
	if p == null:
		return
	p.stream = stream
	p.global_position = pos
	p.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	p.volume_db = default_volume_db + randf_range(-volume_variance_db, volume_variance_db)
	p.play()


func play_sfx_overlap(track: String, pos: Vector2 = Vector2.ZERO) -> void:
	if not tracks.has(track):
		return
	var stream := tracks[track] as AudioStream
	if stream == null:
		return

	var p := AudioStreamPlayer2D.new()
	p.stream = stream
	p.global_position = pos
	add_child(p)
	active_sfx.append(p)  # track it
	p.play()
	p.finished.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free()
			active_sfx.erase(p)
	)

func stop_sfx(track: String) -> void:
	for sfx in active_sfx:
		if is_instance_valid(sfx) and sfx.stream == tracks.get(track, null):
			sfx.stop()
			sfx.queue_free()
	active_sfx = active_sfx.filter(func(sfx):
		return is_instance_valid(sfx) and sfx.stream != tracks.get(track, null)
	)


func set_min_interval(track: String, secs: float) -> void:
	min_intervals[track] = secs

func force_play(track: String, pos: Vector2 = Vector2(), overlap: bool = true) -> void:
	_last_played[track] = Time.get_ticks_usec() / 1_000_000.0
	_on_play_sfx_signal(track, pos, overlap, true)
