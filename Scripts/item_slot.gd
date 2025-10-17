class_name ItemSlot extends ColorRect
var item:ItemResource;

var num_stored:int = 0:
	set(val):
		num_stored = val;
		num_label.text = str(val);
		return;

var menu:InventoryMenu;
##Which index in the inventory is being stored in this item slot?
var index_stored:int;
@onready var num_label:Label = $%NumItems;
@onready var item_texture:TextureRect = $%ItemTexture;
@onready var default_colour:Color = color;
var hover_colour:Color = Color.WHITE;
var num_items:int = 0;
func _ready()->void:
	mouse_entered.connect(_on_hover);
	mouse_exited.connect(_on_release_hover);
	set_item(item);

func set_item(i:ItemResource,n:int = 1)->bool:
	if i == null:
		num_stored = 0;
		item = null;
		item_texture.texture = null;
		num_label.hide();
		return false;
	else:
		if(i.max_in_inv_slot < n):
			#cannot have more
			return false
		num_label.show()
		if i.max_in_inv_slot == 1:
			num_label.hide();
		num_stored = n;
		item = i;
		if item.sprite == null:
			item_texture.texture = i.image;
			return true;
		else:
			item_texture.texture = i.sprite;

			return true;

func empty()->bool:
	return item == null || num_stored == 0;
func full()->bool:
	if empty():
		return false;
	return item.max_in_inv_slot == num_items;

##Keeps track of whether this item slot is hovered.
var hovered:bool = false;
##What to do when being hovered over
func _on_hover():
	hovered = true
	menu.last_hovered = index_stored;
	color = hover_colour;
	
##What to do when no longer being hovered over
func _on_release_hover():
	hovered = false;
	color = default_colour;



func drag():
	num_label.hide();
	item_texture.texture= null;
