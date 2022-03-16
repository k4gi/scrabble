extends KinematicBody2D


onready var tween = $Tween
onready var hpbar = $HPBar
onready var sprite = $AnimatedSprite
onready var body_collision = $CollisionShape2D
onready var arms_collision = $Attack/CollisionShape2D
onready var sound_hurt = $HurtSound


var target
var pathfinding


var move_speed = 0.2
var move_pause = false
var damage_delay = 0.4

var health = 5
var death_speed = 0.5

var attack_body = null
var attack_damage = 1
var attack_speed = 0.5

var hpbar_position


func _ready():
	hpbar_position = hpbar.get_position()
	hpbar.set_max(health)
	hpbar.set_value(health)
	hpbar.set_as_toplevel(true)
	sprite.play("walk")

func _physics_process(_delta):
	if not tween.is_active() and not move_pause:
		var source = pathfinding.get_closest_point( get_position() )
		var destination = pathfinding.get_closest_point( target.get_position() )
		
		var path = pathfinding.get_point_path(source, destination)
		
		if path.size() > 1:
			var tween_speed = move_speed
			
			tween.interpolate_property(self, "position",
				get_position(), path[1], tween_speed,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()


func _process(_delta):
	if not move_pause:
		look_at(target.get_position())
		hpbar.set_position( get_position() + hpbar_position )


func bullet_hit(damage):
	health -= damage
	sound_hurt.play()
	if health <= 0:
		kill()
	else:
		hpbar.set_value(health)
		move_pause = true
		tween.stop_all()
		yield(get_tree().create_timer(damage_delay), "timeout")
		if health > 0:
			move_pause = false
			tween.resume_all()


func kill():
	EventJug.emit_signal("zombie_killed")
	
	move_pause = true
	tween.remove_all()
	sprite.play("die")
	body_collision.set_deferred("disabled", true)
	arms_collision.set_deferred("disabled", true)
	hpbar.set_visible(false)
	
	tween.interpolate_property(sprite, "modulate",
		sprite.get_modulate(), Color.transparent, death_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	queue_free()


func start_damaging(body):
	attack_body = body
	doing_damage()


func stop_damaging(body):
	if attack_body == body:
		attack_body = null


func doing_damage():
	if attack_body != null:
		attack_body.damage_player(attack_damage)
		yield(get_tree().create_timer(attack_speed), "timeout")
		doing_damage()

func _on_Attack_body_entered(body):
	if body.has_method("damage_player"):
		start_damaging(body)


func _on_Attack_body_exited(body):
	if body.has_method("damage_player"):
		stop_damaging(body)
