extends Node


const FLOOR_ID = 1
const ELEVATOR_ID = [2,3,4,5]
const MAX_SPAWN_ATTEMPTS = 20

const FUEL_CAN = preload("res://items/Jerrycan.tscn")
const SPAWNPOINT = preload("res://levels/SpawnSpot.tscn")
const ZOMBIE = preload("res://enemies/Zombie.tscn")


onready var MapGen = $Blocks
onready var Map = $TileMap
onready var Elevator = $Elevator
onready var Generator = $Generator
onready var ItemFolder = $ItemFolder
onready var SpawnFolder = $SpawnFolder
onready var ZombieFolder = $ZombieFolder
onready var Player = $TopDownPlayer


var path = AStar2D.new()

var fuel_cans_in_level = 0

var spawn_clock = 0

var corridor_length = 5
var room_length = 5
var fuel_can_chance = 8
var initial_zombie_chance = 9
var zombie_spawn_time = 1.0
var zombie_spawn_chance = 2


func _ready():
	MapGen.CORRIDOR_LENGTH = corridor_length
	MapGen.ROOM_LENGTH = room_length
	MapGen.FUEL_CAN_CHANCE = fuel_can_chance
	
	MapGen.generate_level(Map)
	MapGen = null
	fuel_cans_in_level -= 1
	EventJug.emit_signal("score_set_max", fuel_cans_in_level)
	build_paths()
	initial_zombie_spawn()
	
	EventJug.connect("score_show", self, "_on_score_show")
	EventJug.connect("open_exit", self, "_on_open_exit")


func _physics_process(delta):
	spawn_clock += delta
	if spawn_clock >= zombie_spawn_time:
		spawn_clock = 0
		
		if randi()%zombie_spawn_chance == 0:
			spawn_random_zombie()


func set_variables(corridor, room, fuel, initial_zombie, zombie_time, zombie_chance):
	corridor_length = corridor
	room_length = room
	fuel_can_chance = fuel
	initial_zombie_chance = initial_zombie
	zombie_spawn_time = zombie_time
	zombie_spawn_chance = zombie_chance


func initial_zombie_spawn():
	for each_spawnpoint in SpawnFolder.get_children():
		if randi()%initial_zombie_chance == 0:
			spawn_zombie_here(each_spawnpoint.get_position())


func spawn_random_zombie():
	var min_distance = Map.get_cell_size()*Map.get_scale()*5
	var chosen_spawn = SpawnFolder.get_child( randi()%SpawnFolder.get_child_count() )
	var spawn_attempts = 0
	while abs(chosen_spawn.get_position().x - Player.get_position().x) < min_distance.x or \
		abs(chosen_spawn.get_position().y - Player.get_position().y) < min_distance.y and \
		spawn_attempts < MAX_SPAWN_ATTEMPTS:
			chosen_spawn = SpawnFolder.get_child( randi()%SpawnFolder.get_child_count() )
			spawn_attempts += 1
	if spawn_attempts < MAX_SPAWN_ATTEMPTS:
		spawn_zombie_here(chosen_spawn.get_position())


func spawn_zombie_here(pos):
	var new_zombie = ZOMBIE.instance()
	new_zombie.set_position(pos)
	new_zombie.target = Player
	new_zombie.pathfinding = path
	ZombieFolder.add_child(new_zombie)
	

func build_paths():
	var valid_tiles = Map.get_used_cells_by_id(FLOOR_ID)
	for each_id in ELEVATOR_ID:
		valid_tiles.append_array( Map.get_used_cells_by_id(each_id) )
	
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
			if node_one != node_two:
				var x_diff = abs(path.get_point_position(node_one).x - path.get_point_position(node_two).x)
				var y_diff = abs(path.get_point_position(node_one).y - path.get_point_position(node_two).y)
				if x_diff <= Map.get_cell_size().x * Map.get_scale().x /2 and \
					y_diff <= Map.get_cell_size().y * Map.get_scale().y /2:
						path.connect_points(node_one, node_two)


func _on_Blocks_set_elevator_position(pos):
	Elevator.set_position(pos)


func _on_Blocks_set_generator_position(pos):
	Generator.set_position(pos)


func _on_Blocks_spawn_fuel_can(pos):
	var new_can = FUEL_CAN.instance()
	new_can.set_position(pos)
	ItemFolder.add_child(new_can)
	fuel_cans_in_level += 1


func _on_score_show(val):
	if val >= fuel_cans_in_level:
		Generator.sufficient_fuel = true


func _on_open_exit():
	Elevator.is_open = true


func _on_Blocks_place_spawnpoint(pos):
	var new_point = SPAWNPOINT.instance()
	new_point.set_position(pos)
	SpawnFolder.add_child(new_point)
