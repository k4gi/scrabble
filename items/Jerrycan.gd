extends Area2D


onready var Anim = $AnimatedSprite
onready var Sound = $PickupSound


var fuel_value = 1
var is_active = true


func pick_up():
	if is_active:
		EventJug.emit_signal("score_add", fuel_value)
		Sound.play()
		_remove()


func _remove():
	is_active = false
	Anim.play("fade_away")
	yield(Anim, "animation_finished")
	queue_free()
