extends Node


onready var Player = $TopDownPlayer


func _ready():
	Player.set_light_enabled(false)
