extends Area2D


var is_open = false


func auto_interact():
	if is_open:
		EventJug.emit_signal("win_game")
