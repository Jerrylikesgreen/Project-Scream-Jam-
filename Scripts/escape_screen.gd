extends Control
@onready var score_label:Label = %ScoreLabel;
@onready var return_button:Button = %ReturnButton;
@onready var quit_button:Button = %QuitButton;
@onready var game_over_container:VBoxContainer = %GameOverContainer;
func _ready() -> void:
	if Globals.player_data != null:
		score_label.text = "Score: {}".format([Globals.player_data.player_score]);
	score_label.visible_characters = 0;
	game_over_container.scale = Vector2.ONE*0.1;
	game_over_container.modulate = Color(game_over_container.modulate,0.0);
	var tween:Tween = create_tween();
	tween.tween_property(game_over_container,"scale",Vector2.ONE,1.0).set_trans(Tween.TRANS_QUAD);
	tween.tween_property(game_over_container,"modulate",Color(game_over_container.modulate,1.0),1.0);
	await tween.finished;
	return_button.pressed.connect(_on_return_button_pressed);
	quit_button.pressed.connect(_on_quit_button_pressed);
	for i in range(0,len(score_label.text) + 1):
		score_label.visible_characters = i;
		await get_tree().create_timer(0.1).timeout;
	
func _on_return_button_pressed()->void:
	Events.game_restart();
	queue_free();
func _on_quit_button_pressed()->void:
	get_tree().quit();
