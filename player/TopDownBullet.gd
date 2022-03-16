extends RigidBody2D

var active = true

onready var sprite = $Sprite
onready var timer = $Timer

var blue_tint = Color(0, 0, 20, 255)

var damage = 0

func _ready() -> void:
	timer.connect("timeout", self, "_on_Timer_timeout")
	connect("body_entered", self, "_on_body_entered")

func _on_Timer_timeout():
	active = false
	queue_free()

func _on_body_entered(bonk):
	print(self.get_name(), " collide: ", bonk.get_name())
	if bonk.has_method("bullet_hit") and active:
		bonk.bullet_hit(damage)
		active = false
		queue_free()
	else:
		sprite.set_modulate(Color.white)
		active = false
