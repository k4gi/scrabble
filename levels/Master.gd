extends Node


var corridor_length = 5
var room_length = 5
var fuel_can_chance = 8
var initial_zombie_chance = 9
var zombie_spawn_time = 1.0
var zombie_spawn_chance = 2

var current_level = 1
var zombies_killed = 0

onready var Level = preload("res://levels/GeneratedLevel.tscn")

onready var MainMenu = $CanvasLayer/NinePatchRect
var CurrentLevel


func _ready():
	OS.set_window_position(OS.get_screen_size() / 2 - OS.get_window_size() / 2)
	randomize()
	
	EventJug.connect("load_next_level", self, "level_up")
	EventJug.connect("lose_game", self, "_on_lose_game")
	EventJug.connect("zombie_killed", self, "_on_zombie_killed")


func _on_PlayButton_pressed():
	MainMenu.queue_free()
	load_level()


func load_level():
	CurrentLevel = Level.instance()
	CurrentLevel.set_variables( corridor_length, room_length, fuel_can_chance, initial_zombie_chance, zombie_spawn_time, zombie_spawn_chance )
	add_child(CurrentLevel)


func level_up():
	corridor_length += 1
	room_length += 2
	fuel_can_chance += 1
	current_level += 1
	
	CurrentLevel.queue_free()
	
	load_level()


func _on_lose_game():
	EventJug.emit_signal("show_stats", current_level, zombies_killed)


func _on_zombie_killed():
	zombies_killed += 1

# here I am thinking again.
# haven't touched this project in 7 months but I want to use it to build my 7 Day Roguelike

# planning is going here so i don't forget and so i don't need to memorize it and so i can sleep
# gameplay. think teleglitch. maybe a bit easier lol.
# punch / slash / stab / whatever with left click
# aim with right click then fire with left click
# move with wasd, run with shift. stamina bar for running so you can't do it all the time.
# dialog boxes. advance with left click or space bar.
# pause menu with escape
# and the most important thing. i want controls to be reconfigurable. going to learn how to do that.

# you open your eyes. you're in your bedroom that also doubles as a gameplay tutorial.
# control prompts in the walls and targets to hit. a computer to talk to and ask questions of.

# you walk outside your bedroom and your buddy is in the hallway.
# you run a shop together but you have no money! oh no! you can't sell stuff if you can't afford any stuff!
# your buddy asks you to check out the basement. there might be some old crap down there to sell.
# the basement is the dungeon!

# the dungeon procedurally generated. it's made up of premade tiles placed randomly.
# corridors. rooms. enemy spawn points. and things.
# the goal in each level is to find the elevator to go to the next level.
# also collect treasure for upgrading your character in subsequent runs. (the stuff put out to sell)
# i guess it could also be like, you're collecting for a museum. idk. i like the shop idea
# ok so. the elevator needs power. so you need to find the generator on each level.
# and the generator needs fuel so you gotta find the fuel pickup. maybe there's more than one?
# as in maybe fuel is easier to find bc there's a few of it and you only need one

# so you find a fuel can, start the generator, get to the elevator, repeat
# somewhere in this loop there's a miniboss. perhaps you get swarmed when you turn the generator on
# oh right the enemies. they're probably zombies. weird basement zombies.
# eventually i suppose there should be a big, final boss level. and then you win!

# challenges
# so uh what makes this game worth playing. what are you up against
# obviously the enemies will kill you if they hit you too many times.
# if you are too trigger happy you will run out of ammo. ammo pickups will be. somewhere.
# i want to make it easy to get more ammo so probably enemies will have a chance to drop some
# there might be crates of it around too
# there ought to be two or three types of normal enemy that you need to play differently against
# for instance hiding and shooting around corners when you fight an enemy with a gun
# maybe there's an enemy that tries to sneak up quietly behind you
# i would like for the dungeon to be pretty dark. you can see in a small circle around you.
# maybe you can find light sticks or flares to throw and light up the place
# then you start the generator and all the lights go on and you have to rush to the exit
# that would be so sick
# ok so there are closed / locked rooms around that are off the main path.
# and you can find nice things in them like treasure and guns and buffs but it's dangerous
# because there's going to be a bunch of zombies locked up inside
# and because the noise of breaking open the door is going to attract them from elsewhere
# like, behind you and down the hall to your right and all that. maybe it spawns more.


