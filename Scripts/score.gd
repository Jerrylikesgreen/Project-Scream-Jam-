class_name Score extends Label


func _ready() -> void:
	var score = Globals.player_data.player_score
	set_text(str(score))
