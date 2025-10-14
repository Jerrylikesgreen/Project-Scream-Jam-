##Base class for all emiting light points in game. 
class_name Pointlight extends PointLight2D


## If toogled, lights will flicker on and off. 
@export var flicker_enabled: bool = false


## time interval in float between each flicker (Determins how fast it will turn off and on)
var _flicker_interval: float = 0.0
## range of brightness of the light in float between each flicker (Determins how bright light will shine)
var _light_bright_range: float = 1.0


## hidden refrence to timer node. 
var _flicker: Timer = null

## set up
func _ready() -> void:
	randomize()
	_pick_new_randoms()
	if flicker_enabled:
		call_deferred("light_flicker_logic")
		
		
# ----------------------------------------[Hidden Helpers]----------------------------------------------------------------------


## Helper function re-sets the values 
func _pick_new_randoms() -> void:
	_flicker_interval = randf_range(0.2, 2.0)
	_light_bright_range = randf_range(0.1, 0.5)


## Helper function sets off the logic of the flickering once flicker_enabled is set to true
func light_flicker_logic() -> void:
	if not flicker_enabled:
		return

	if _flicker == null:
		_flicker = Timer.new()
		_flicker.one_shot = true
		add_child(_flicker)
		_flicker.timeout.connect(Callable(self, "_on_timeout"))

	_pick_new_randoms()
	_flicker.start(_flicker_interval)


## Called when timer goes off to enable or disable the light. 
func _on_timeout() -> void:
	if enabled:
		set_enabled(false)
	else:
		energy = _light_bright_range
		set_enabled(true)

	light_flicker_logic()

	print("flicker interval:", _flicker_interval, " brightness:", _light_bright_range)
