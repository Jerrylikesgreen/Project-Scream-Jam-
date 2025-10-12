extends Node
@onready var inventory:InvContents = preload("res://Resources/inventory_contents.tres");
@onready var inv_menu_scene:PackedScene = preload("res://Scenes/inventory_menu.tscn");
var menu_shown:bool = false;
var menu_instance:InventoryMenu;
func _ready() -> void:
	inventory.item_used.connect(_on_item_used);

func on_acquire_item(item:Item):
	inventory.add(item);
func _on_item_used():
	pass

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("inventory")):
		_toggle_menu();

func _toggle_menu():
	if !menu_shown:
		var menu:InventoryMenu = inv_menu_scene.instantiate();
		menu.inv_contents = inventory;
		get_tree().root.add_child(menu);
		menu_instance = menu;
		
		menu_shown = true;
	else:
		menu_instance.queue_free();
		menu_shown = false;
	pass
