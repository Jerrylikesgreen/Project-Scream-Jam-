class_name InventoryMenu extends Control

@onready var tooltip_panel: Panel = %Tooltip
@onready var tooltip_label: Label = tooltip_panel.get_node("Label")

@export var numSlots:int = 20;
@export var inv_contents:InvContents;

var slots:Array[ItemSlot] = [];
var hovered_index:int = -1;
var dragging:bool = false;
var drag_sprite:Sprite2D = null;
var dragged_slot:ItemSlot = null;
var last_hovered:int;
var tooltip_offset:Vector2 = Vector2(20, 20)

func _ready() -> void:
	# hide tooltip at start
	tooltip_panel.visible = false

	if inv_contents != null:
		inv_contents.item_update.connect(_update_cell)

	for i in range(numSlots):
		var slot:ItemSlot = preload("res://Scenes/item_slot.tscn").instantiate()
		%Inventory.add_child(slot)
		var ind := slots.size()
		slot.index_stored = ind
		slot.menu = self
		slots.append(slot)

		# Ensure the slot Control receives mouse_entered/exited.
		# If it doesn't, uncomment the next line (slot must be a Control):
		# slot.mouse_filter = Control.MOUSE_FILTER_STOP

		# connect hover signals for this slot (assumes slot root is a Control)
		slot.connect("mouse_entered", Callable(self, "_on_slot_mouse_entered").bind(ind))
		slot.connect("mouse_exited", Callable(self, "_on_slot_mouse_exited").bind(ind))

		if inv_contents != null:
			_update_cell(ind)



# Updates the contents of a cell so it displays objects properly.
func _update_cell(index:int):
	slots[index].set_item(inv_contents.contents[index], inv_contents.multiplicity[index])
	return

# ----- tooltip handlers -----
func _on_slot_mouse_entered(index:int) -> void:
	hovered_index = index
	var item:ItemResource = inv_contents.contents[index] if inv_contents != null else null
	if item != null:
		# Use fields on your resource (adjust names if different)
		var name_text := str(item.name)
		var desc_text := str(item.description)
		# Compose tooltip content (multi-line)
		var tip := "%s\n\n%s" % [name_text, desc_text]
		show_tooltip(tip)
	else:
		hide_tooltip()

func _on_slot_mouse_exited(index:int) -> void:
	# if mouse left the currently hovered slot, hide tooltip
	if hovered_index == index:
		hovered_index = -1
		hide_tooltip()

func show_tooltip(text:String) -> void:
	tooltip_label.text = text
	tooltip_panel.visible = true
	_position_tooltip_to_mouse()

func hide_tooltip() -> void:
	tooltip_panel.visible = false

func _process(_delta: float) -> void:
	#If we're clicking on an item and not already
	#dragging, create a drag item
	if(dragging):
		var mousePos:Vector2 = get_global_mouse_position()
		drag_sprite.global_position = mousePos

	# update tooltip position if visible
	if tooltip_panel.visible:
		_position_tooltip_to_mouse()

func _position_tooltip_to_mouse() -> void:
	# position tooltip at mouse (screen coordinates), clamp to viewport
	var vp := get_viewport().get_visible_rect()
	var mouse_pos := get_viewport().get_mouse_position()
	var new_pos := mouse_pos + tooltip_offset

	# get size and clamp so tooltip stays on screen
	var tip_size := tooltip_panel.get_combined_minimum_size()
	new_pos.x = clamp(new_pos.x, 4, vp.size.x - tip_size.x - 4)
	new_pos.y = clamp(new_pos.y, 4, vp.size.y - tip_size.y - 4)

	tooltip_panel.global_position = new_pos



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
