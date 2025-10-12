class_name Item extends Resource
static var next_id:int = 0;
var id;
@export var name:String;
@export var description:String;
@export var image:Texture2D;
@export var consumable:bool;
#The most items of this type which can be contained in
#one inventory slot
@export var max_in_inv_slot:int = 1;

func _init() -> void:
	id = next_id;
	next_id += 1;
