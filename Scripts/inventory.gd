class_name InventoryMenu extends Control
@export var numSlots:int = 20;
@export var inv_contents:InvContents;
var slots:Array[ItemSlot] = [];
var hovered_index:int = 0;

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
		slot.index_stored = ind;
		slot.menu = self;
		slots.append(slot);
		if inv_contents != null:
			_update_cell(ind);

##Updates the contents of a cell so it displays objects
##properly.
func _update_cell(index:int):
	slots[index].set_item(inv_contents.contents[index],inv_contents.multiplicity[index]);
	return;
	
var dragging:bool = false;
var drag_sprite:Sprite2D = null;

var dragged_slot:ItemSlot = null;

var last_hovered:int;

##Start dragging an item. Dragging an item to a different
##slot switches the slots, dragging it out of the menu
##uses the item.
func _drag(index:int):
	if dragging:
		return;
	dragged_slot = slots[index];
	dragging = true;
	if inv_contents.contents[index] == null:
		return;
	var item:ItemResource = inv_contents.contents[index];
	drag_sprite = Sprite2D.new()
	drag_sprite.texture = item.image;
	var item_texture:TextureRect = slots[index].item_texture
	var dims:Vector2 = item_texture.get_rect().size;
	var tex_size:Vector2 = item_texture.texture.get_size();
	##Since the scale keeps aspect ratio, both height and width
	##are scaled down the same amount. To fit in the bounding box, it must
	##be scaled by the smallest of the two scale values
	var scaled_dims:Vector2 = dims/tex_size;
	var min_edge_scale:float = min(scaled_dims.x,scaled_dims.y);
	drag_sprite.scale = Vector2.ONE*min_edge_scale;
	get_parent().add_child(drag_sprite);

func _process(_delta: float) -> void:
	if(dragging):
		var mousePos:Vector2 = get_global_mouse_position()
		drag_sprite.global_position = mousePos;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if !dragging:
			#If we're clicking on an item and not already
			#dragging, create a drag item
			if slots[last_hovered].hovered && !slots[last_hovered].empty():
				_drag(last_hovered);
				slots[last_hovered].drag();
			else:
				#Otherwise, do nothing
				return;
		else:
			#If we're already dragging something,
			#If we're clicking out of the inventory,
			#then use the item, else move it
			if slots[last_hovered].hovered:
				#If we're hovering over a slot
				inv_contents.switch(last_hovered,dragged_slot.index_stored);
			else:
				inv_contents.use(last_hovered);
			get_parent().remove_child(drag_sprite);
			dragging = false;
			drag_sprite.queue_free();
			drag_sprite = null;
			dragged_slot = null
