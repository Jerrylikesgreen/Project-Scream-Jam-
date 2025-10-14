##General class for tilemaps which serve as the floor layer
##for a given level. Made so killer navication goes around objects
class_name FloorTileMap extends TileMapLayer
var _obstacle_tilemaps:Array[TileMapLayer];
func _ready() -> void:
	for c in get_parent().find_children("*","TileMapLayer",false):
		if c is TileMapLayer && c != self:
			_obstacle_tilemaps.append(c);

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	for tilemap in _obstacle_tilemaps:
		#var tile_size:Vector2i = tilemap.tile_set.tile_size;
		#If the other tilemap has bigger or equal sized
		#tiles, then there's likely only one tile overlapping this
		#one(ignoring that tilemaps can be moved)
		var other_local_coords:Vector2 = tilemap.to_local(to_global(map_to_local(coords)));
		var other_coords:Vector2i = tilemap.local_to_map(other_local_coords);
		if other_coords in tilemap.get_used_cells() && tilemap.get_cell_tile_data(other_coords).get_collision_polygons_count(0) > 0:
			return true;
	return false
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0,null);
		
				
