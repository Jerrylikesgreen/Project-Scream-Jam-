class_name ItemResource extends Resource
static var next_id:int = 0;
var id;
@export var name:String;
@export var description:String;
@export var image:Texture2D;
@export var consumable:bool;
#The most items of this type which can be contained in
#one inventory slot
@export var max_in_inv_slot:int = 1;

@export var sprite: AtlasTexture

enum Momento {NONE,  PROTECTION, STAMINA, SPEED, VISION}

@export var momento: Momento = Momento.NONE

## if not empty, player will produce a speech bubble with the String during certain actions. 
@export var player_dialog:String


@export var is_key: bool = false

func _init() -> void:
	id = next_id;
	next_id += 1;
