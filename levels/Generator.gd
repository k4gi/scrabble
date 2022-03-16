extends Area2D


onready var Sound = $GeneratorSound


var generator_active = false
var sufficient_fuel = false


func interact():
	if sufficient_fuel and not generator_active:
		generator_active = true
		EventJug.emit_signal("open_exit")
		Sound.play()
	elif not sufficient_fuel:
		EventJug.emit_signal("not_enough_fuel")
