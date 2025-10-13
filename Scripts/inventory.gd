class_name InventoryMenu extends Control
@export var numSlots:int = 20;
@export var inv_contents:InvContents;
var slots:Array[ItemSlot] = [];

func _ready() -> void:
	##When this node enters the scene tree, it creates slots
	##for the inventory items and populates them if it has
	##inventory data
	if inv_contents!=null:
		inv_contents.item_update.connect(_update_cell);
	for i in range(numSlots):
		var slot:ItemSlot = preload("res://Scenes/item_slot.tscn").instantiate();
		%Inventory.add_child(slot);
		var ind = len(slots);
		slots.append(slot);
		if inv_contents != null:
			_update_cell(ind);

##Updates the contents of a cell so it displays objects
##properly.
func _update_cell(index:int):
	slots[index].set_item(inv_contents.contents[index],inv_contents.multiplicity[index]);
	return;

##Testing code to make sure added items show up properly.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("up"):
		#var test = preload("res://Resources/placeholder_item_1.tres");
		#inv_contents.add(test);
	#if event.is_action_pressed("down"):
		#var test = preload("res://Resources/placeholder_item_2.tres");
		#inv_contents.add(test);
	#pass
