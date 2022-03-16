extends Node


const WALL_ID = 0
const FLOOR_ID = 1
const ELEVATOR_ID = 5
const GENERATOR_ID = 9
const SPAWNPOINT_ID = 10
const BLOCK_SIZE = [6,6]


var CORRIDOR_LENGTH = 5
var ROOM_LENGTH = 5
var FUEL_CAN_CHANCE = 8
var desired_fuel_cans = 5


onready var corridors = $Corridors.get_children()
onready var rooms = $Rooms.get_children()
onready var elevators = $Elevators.get_children()
onready var generators = $Generators.get_children()


signal set_elevator_position(pos)
signal set_generator_position(pos)
signal spawn_fuel_can(pos)
signal place_spawnpoint(pos)


var filler = { #first two for 1-tile walls, all four for 2-tile walls. maybe this is silly but oh well
	"north": [ [2,0], [3,0], [2,1], [3,1] ],
	"south": [ [2,5], [3,5], [2,4], [3,4] ],
	"west": [ [0,2], [0,3], [1,2], [1,3] ],
	"east": [ [5,2], [5,3], [4,2], [4,3] ]
}


func generate_level(level_tilemap):
	var room_spots = [ [0,0] ]
	var filled_rooms = []
	var filled_corridors = []
	var next_room = null
	var next_spot = null
	
	#elevator can be the first room
	next_room = elevators[randi()%elevators.size()]
	next_spot = room_spots[randi()%room_spots.size()]
	place_block(level_tilemap, next_room, next_spot, "elevator")
	filled_rooms.append(next_spot)
	
	#then a long snaking corridor with no branches (to keep it simple to start with)
	for i in range(CORRIDOR_LENGTH):
		room_spots = find_adjacent_gaps(filled_rooms, [next_spot])
		if room_spots.size() == 0:
			room_spots = find_adjacent_gaps(filled_rooms, filled_rooms)
		
		next_room = corridors[randi()%corridors.size()]
		next_spot = room_spots[randi()%room_spots.size()]
		place_block(level_tilemap, next_room, next_spot, "corridor")
		filled_rooms.append(next_spot)
		filled_corridors.append(next_spot)
	
	#then at the end there's the generator.
	room_spots = find_adjacent_gaps(filled_rooms, [next_spot])
	
	next_room = generators[randi()%generators.size()]
	next_spot = room_spots[randi()%room_spots.size()]
	place_block(level_tilemap, next_room, next_spot, "generator")
	filled_rooms.append(next_spot)
	#in between sprinkle some rooms
	for i in range(ROOM_LENGTH):
		room_spots = find_adjacent_gaps(filled_rooms, filled_corridors)
		if room_spots.size() == 0:
			room_spots = find_adjacent_gaps(filled_rooms, filled_rooms)
		
		next_room = rooms[randi()%rooms.size()]
		next_spot = room_spots[randi()%room_spots.size()]
		place_block(level_tilemap, next_room, next_spot, "room")
		filled_rooms.append(next_spot)
	
	#fill in gaps in the walls now. similar to find_adjacent_gaps
	fill_adjacent_gaps(level_tilemap, filled_rooms, filled_corridors)
	#and we have basic, probably boring, world gen! yay
	#get the autotiling working nice
	level_tilemap.update_bitmask_region(level_tilemap.get_used_rect().position, level_tilemap.get_used_rect().end)
	#new item spawning down here
	spawn_desired_fuel_cans(level_tilemap)
	#should probably get out of the way of the real level
	queue_free()


func place_block(level_tilemap, block, coords, variant):
	var special = false
	for tile in block.get_used_cells():
		var tile_id = block.get_cellv( tile )
		var tile_x = tile.x+coords[0]*BLOCK_SIZE[0]
		var tile_y = tile.y+coords[1]*BLOCK_SIZE[1]
		
		if tile_id == SPAWNPOINT_ID:
			tile_id = FLOOR_ID
			emit_signal("place_spawnpoint", level_tilemap.map_to_world(Vector2(tile_x,tile_y))*level_tilemap.get_scale() + level_tilemap.get_cell_size()*level_tilemap.get_scale()/2 )
		
		level_tilemap.set_cell(tile_x, tile_y, tile_id)
		
		match variant:
			"elevator":
				if tile_id == ELEVATOR_ID:
					emit_signal("set_elevator_position", level_tilemap.map_to_world(Vector2(tile_x, tile_y))*level_tilemap.get_scale())
			"generator":
				if tile_id == GENERATOR_ID:
					emit_signal("set_generator_position", level_tilemap.map_to_world(Vector2(tile_x, tile_y))*level_tilemap.get_scale())
			"corridor":
				pass
			"room":
				pass
#				if !special and tile_id == FLOOR_ID and \
#					tile.x != 0 and tile.x != BLOCK_SIZE[0]-1 and \
#					tile.y != 0 and tile.y != BLOCK_SIZE[1]-1 and \
#					randi()%FUEL_CAN_CHANCE == 0:
#						emit_signal("spawn_fuel_can", level_tilemap.map_to_world(Vector2(tile_x, tile_y))*level_tilemap.get_scale())
#						special = true


func spawn_desired_fuel_cans(level_tilemap):
	print(level_tilemap.get_used_rect())
	var placed_cans = []
	var topleft = level_tilemap.get_used_rect().position
	var bottomright = level_tilemap.get_used_rect().end
	var rect_range = bottomright - topleft
	for each_can in range(desired_fuel_cans):
		var can_pos_x = randi()%int(rect_range.x) - int(topleft.x)
		var can_pos_y = randi()%int(rect_range.y) - int(topleft.y)
		while level_tilemap.get_cell(can_pos_x, can_pos_y) != FLOOR_ID:
			can_pos_x = randi()%int(rect_range.x) - int(topleft.x)
			can_pos_y = randi()%int(rect_range.y) - int(topleft.y)
		emit_signal("spawn_fuel_can", level_tilemap.map_to_world(Vector2(can_pos_x, can_pos_y))*level_tilemap.get_scale())


func find_adjacent_gaps(filled_rooms, viewpoint_rooms): #?
	var room_spots = []
	for each_view in viewpoint_rooms:
		#check up, down, left, right
		#if not in filled_rooms, add to room_spots
		if not filled_rooms.has( [each_view[0]-1, each_view[1]] ):
			room_spots.append( [each_view[0]-1, each_view[1]] )
		if not filled_rooms.has( [each_view[0]+1, each_view[1]] ):
			room_spots.append( [each_view[0]+1, each_view[1]] )
		if not filled_rooms.has( [each_view[0], each_view[1]-1] ):
			room_spots.append( [each_view[0], each_view[1]-1] )
		if not filled_rooms.has( [each_view[0], each_view[1]+1] ):
			room_spots.append( [each_view[0], each_view[1]+1] )
	return room_spots


func fill_adjacent_gaps(level_tilemap, filled_rooms, filled_corridors):
	for each_view in filled_rooms:
		#check up, down, left, right
		#if theres a gap fill it. one wide for rooms. two for corridors.
		if not filled_rooms.has( [each_view[0], each_view[1]-1] ):
			if filled_corridors.has( each_view ):
				_fill_gaps(level_tilemap, each_view, filler["north"])
			else:
				_fill_gaps(level_tilemap, each_view, [filler["north"][0], filler["north"][1]])
		if not filled_rooms.has( [each_view[0], each_view[1]+1] ):
			if filled_corridors.has( each_view ):
				_fill_gaps(level_tilemap, each_view, filler["south"])
			else:
				_fill_gaps(level_tilemap, each_view, [filler["south"][0], filler["south"][1]])
		if not filled_rooms.has( [each_view[0]-1, each_view[1]] ):
			if filled_corridors.has( each_view ):
				_fill_gaps(level_tilemap, each_view, filler["west"])
			else:
				_fill_gaps(level_tilemap, each_view, [filler["west"][0], filler["west"][1]])
		if not filled_rooms.has( [each_view[0]+1, each_view[1]] ):
			if filled_corridors.has( each_view ):
				_fill_gaps(level_tilemap, each_view, filler["east"])
			else:
				_fill_gaps(level_tilemap, each_view, [filler["east"][0], filler["east"][1]])

func _fill_gaps(level_tilemap, room_coord, spots):
	for tile in spots:
		level_tilemap.set_cell(tile[0]+room_coord[0]*BLOCK_SIZE[0], tile[1]+room_coord[1]*BLOCK_SIZE[1], WALL_ID)
