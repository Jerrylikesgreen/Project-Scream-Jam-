## Autoload - SceneTransition
extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var darkness_over: Timer = $DarknessOver
@onready var percent_display: Label = $PercentDisplay
var _percentage: int = 0
var _done = false 

func run_transition() -> void:
	animation_player.play("transition") 
	$DarknessOver.start()
	_percentage = 0
	
func _process(delta: float) -> void:
	## ensures percent cannot pass 100
	if _percentage >= 100:
		return
	if _done == true:
		for x in range(1):
			_percentage += 1
	percent_display.text = str(_percentage) + " %" 

# waits for fade in to be over before increasing percent
func _on_darkness_over_timeout() -> void:
	_done = true
