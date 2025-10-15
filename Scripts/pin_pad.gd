class_name PinPad
extends Control

@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit

var _correct_pin: int = 2258
const PIN_LENGTH: int = 4 

signal closed

func _ready() -> void:
	line_edit.text_changed.connect(_on_text_changed)
	if PIN_LENGTH > 0:
		line_edit.max_length = PIN_LENGTH

func _on_close() -> void:
	# emit so parent knows it was closed
	emit_signal("closed")
	hide()


func _on_text_changed(new_text: String) -> void:
	var filtered: String = ""
	for c in new_text:
		if c >= "0" and c <= "9":
			filtered += c

	if filtered != new_text:
		var caret: int = 0
		line_edit.text = filtered

	if PIN_LENGTH > 0:
		if filtered.length() != PIN_LENGTH:
			return
	else:
		if filtered == "":
			return

	if filtered.is_valid_int():
		var pass_check: int = int(filtered)
		if pass_check == _correct_pin:
			Events.display_player_message("It Worked!")
			Events.pin_entered(true)
		else:
			Events.display_player_message("Wrong, pin...")
			Events.pin_entered(false)
			line_edit.clear()
