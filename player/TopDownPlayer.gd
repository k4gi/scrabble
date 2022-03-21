# https://www.youtube.com/watch?v=5vYI_mgERBU
# https://pastebin.com/LJtAREKf

# https://www.youtube.com/playlist?list=PLpwc3ughKbZexDyPexHN2MXLliKAovkpl
# https://github.com/josephmbustamante/Godot-Top-down-Shooter-Tutorial

extends KinematicBody2D
 
const MOVE_SPEED = 300

const BULLET_VELOCITY = 1000
const Bullet = preload("res://player/TopDownBullet.tscn")

const KNIFE_DAMAGE = 5
const GUN_DAMAGE = 2
 
onready var raycast = $RayCast2D
onready var gun = $Gun
onready var sprite = $AnimatedSprite
onready var knife = $Knife
onready var interact_area = $Interact
onready var prompt = $TalkPrompt
onready var prompt_pos = prompt.get_position()
onready var shape = $CollisionShape2D
onready var sound_hurt = $HurtSound
onready var sound_gun = $GunSound
onready var sound_knife = $KnifeSound

var move_vec = Vector2.ZERO

var health = 10

var knife_cooldown = false

var is_active = true
 
func _ready():
	EventJug.emit_signal("health_update", health)
	prompt.set_as_toplevel(true)

 
func _physics_process(delta):
	if is_active:
		move_vec = Vector2.ZERO
		if Input.is_action_pressed("move_up"):
			move_vec.y -= 1
		if Input.is_action_pressed("move_down"):
			move_vec.y += 1
		if Input.is_action_pressed("move_left"):
			move_vec.x -= 1
		if Input.is_action_pressed("move_right"):
			move_vec.x += 1
		move_vec = move_vec.normalized()
		move_and_slide(move_vec * MOVE_SPEED)
	 
		var look_vec = get_global_mouse_position() - global_position
		global_rotation = atan2(look_vec.y, look_vec.x)
 
func _process(_delta):
	if is_active:
		if !knife.is_visible():
			if Input.is_action_pressed("aim"):
				sprite.play("aim")
			elif move_vec != Vector2.ZERO:
				sprite.play("walk")
			else:
				sprite.play("idle")
		if prompt.is_visible():
			prompt.set_position(get_position() + prompt_pos)

func _unhandled_input(event):
	if is_active:
		if event.is_action_pressed("shoot"):
			if Input.is_action_pressed("aim"):
				shoot()
			else:
				stab()
		if event.is_action_pressed("interact"):
			if prompt.is_visible():
				for each_area in interact_area.get_overlapping_areas():
					if each_area.has_method("interact"):
						each_area.interact()
	#	if event.is_action_just_pressed("shoot"):
	#		var coll = raycast.get_collider()
	#		if raycast.is_colliding() and coll.has_method("kill"):
	#			coll.kill()


func stab():
	if !knife.is_visible():
		knife_cooldown = false
		knife.set_visible(true)
		knife.set_monitoring(true)
		sprite.play("stab")
		sound_knife.play()
		yield(get_tree().create_timer(0.25), "timeout")
		knife.set_monitoring(false)
		knife.set_visible(false)


func shoot():
	var bullet = Bullet.instance()
	var bullet_direction = gun.global_position.direction_to(get_global_mouse_position()).normalized()
	bullet.apply_central_impulse(bullet_direction * BULLET_VELOCITY)
	bullet.global_position = gun.global_position
	bullet.global_rotation = gun.global_rotation
	bullet.damage = GUN_DAMAGE
	bullet.set_as_toplevel(true)
	add_child(bullet)
	sound_gun.play()
	return true
 
func kill():
	get_tree().reload_current_scene()


func damage_player(damage):
	health -= damage
	sound_hurt.play()
	EventJug.emit_signal("health_update", health)
	if health <= 0:
		EventJug.emit_signal("lose_game")
		die()


func _on_Knife_body_entered(body):
	if body.has_method("bullet_hit") and not knife_cooldown:
		knife_cooldown = true
		body.bullet_hit(KNIFE_DAMAGE)


func _on_Interact_area_entered(area):
	if area.has_method("pick_up"):
		area.pick_up()
	elif area.has_method("interact"):
		prompt.set_visible(true)
	elif area.has_method("auto_interact"):
		area.auto_interact()


func _on_Interact_area_exited(area):
	if area.has_method("interact"):
		prompt.set_visible(false)
		for each_area in interact_area.get_overlapping_areas():
			if each_area.has_method("interact"):
				prompt.set_visible(true)
				break


func die():
	is_active = false
	shape.set_deferred("disabled", true)
	sprite.play("die")
