extends Sprite2D
@export var item:Item;
@onready var area:Area2D = $Area2D;

func _ready() -> void:
	texture = null if item == null else item.image;
	area.body_entered.connect(_body_entered)
	player_acquired_item.connect(InventoryManager.on_acquire_item);

signal player_acquired_item(item:Item);
func _body_entered(body:Node2D):
	if body is PlayerBody:
		player_acquired_item.emit(item);
		queue_free();
	return
