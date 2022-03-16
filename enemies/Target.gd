extends KinematicBody2D

var active = true

var score = 1

func bullet_hit(_damage):
	if active:
		print("target hit!")
		EventJug.emit_signal("score_add", score)
		active = false
		queue_free()
	
