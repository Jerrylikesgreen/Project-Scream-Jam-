extends Node
@onready var inventory:InvContents = preload("res://Resources/Items/inventory_contents.tres");
@onready var inv_menu_scene:PackedScene = preload("res://Scenes/Menus/inventory_menu.tscn");
var menu_shown:bool = false;
var menu_canvas:CanvasLayer;
func _ready() -> void:
	inventory.item_used.connect(_on_item_used);

func use_key(lock_uid:int) -> bool:
	
	if not lock_uid:
		return false
	var index:int = 0;
	for item_stored in inventory.contents:
		if not item_stored:
			continue
		if item_stored.is_key and item_stored.key_uid == lock_uid:
			inventory.use(index);
			return true
		if item_stored.is_key and item_stored.key_uid != lock_uid:
			if item_stored.key_uid == 0:
				inventory.use(index)
				return true
			pass
		index += 1;
	
	return false



func on_acquire_item(item:ItemResource):
	inventory.add(item);

func _on_item_used(item:ItemResource):
	Events.display_player_message("Used " + str(item.name))
	pass

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("inventory")):
		_toggle_menu();

func _toggle_menu():
	if !menu_shown:
		var canvas:CanvasLayer = CanvasLayer.new();
		canvas.name = "Inv_Canvas"
		var menu:InventoryMenu = inv_menu_scene.instantiate();
		menu.inv_contents = inventory;
		canvas.add_child(menu)
		get_tree().root.add_child(canvas)
		
		menu_canvas = canvas;
		
		menu_shown = true;
	else:
		#Best practice would probably be to hide and
		#show instead of delete and reload.
		menu_canvas.queue_free();
		menu_shown = false;
	pass
