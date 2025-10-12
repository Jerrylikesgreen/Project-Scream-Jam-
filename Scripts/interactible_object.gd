class_name InteractibleObject
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var progress_bar: ProgressBar = $ProgressBar

var action_count: float = 0.0
var is_acting: bool = false
var action_speed: float = 0.5  # increase per frame (1 = +1 each frame)

func _ready() -> void:
	# ensure bar is configured
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.visible = false

func _process(_delta: float) -> void:
	if is_acting:
		# Frame-dependent increment: +action_speed each frame
		action_count += action_speed

		# If you prefer time-based (FPS independent), use:
		# action_count += (100.0 / action_duration) * _delta

		if action_count >= 100.0:
			action_count = 100.0
			is_acting = false
			action_complete()

	progress_bar.value = action_count


func action() -> void:
	if not is_acting:
		is_acting = true
		progress_bar.visible = true
		print("Action started (frame-based increment)")


func action_complete() -> void:
	print("Action complete!")
	progress_bar.visible = false
	action_count = 0.0
