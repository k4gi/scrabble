extends Node

func _ready():
	OS.set_window_position(OS.get_screen_size() / 2 - OS.get_window_size() / 2)
	build_paths()


# pathfinding stuff...
var path = AStar2D.new()
onready var Map = $TileMap
const FLOOR = 1

func build_paths():
	var valid_tiles = Map.get_used_cells_by_id(FLOOR)
	
	var i = 0
	for tile in valid_tiles:
		path.add_point( i, (Map.map_to_world(tile) + Map.get_cell_size()/2) * Map.get_scale() )
		
		if valid_tiles.has( Vector2(tile.x+1, tile.y) ):
			i += 1
			path.add_point( i, (Map.map_to_world(tile) + Vector2(Map.get_cell_size().x, Map.get_cell_size().y/2)) * Map.get_scale() )
		
		if valid_tiles.has( Vector2(tile.x+1, tile.y+1) ):
			i += 1
			path.add_point( i, (Map.map_to_world(tile) + Map.get_cell_size()) * Map.get_scale() )
		
		if valid_tiles.has( Vector2(tile.x, tile.y+1) ):
			i += 1
			path.add_point( i, (Map.map_to_world(tile) + Vector2(Map.get_cell_size().x/2, Map.get_cell_size().y)) * Map.get_scale() )
		
		i += 1
	
	for node_one in path.get_points():
		for node_two in path.get_points():
			var x_diff = abs(path.get_point_position(node_one).x - path.get_point_position(node_two).x)
			var y_diff = abs(path.get_point_position(node_one).y - path.get_point_position(node_two).y)
			if x_diff <= Map.get_cell_size().x * Map.get_scale().x /2 and \
				y_diff <= Map.get_cell_size().y * Map.get_scale().y /2:
					path.connect_points(node_one, node_two)

