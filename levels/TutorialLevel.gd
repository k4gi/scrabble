extends Node


onready var Player = $TopDownPlayer


func _ready():
	Player.set_light_mode("full")


func _on_FullLightTrigger_body_entered(body):
	if body.has_method("set_light_mode"):
		body.set_light_mode("full")


func _on_ConeLightTrigger_body_entered(body):
	if body.has_method("set_light_mode"):
		body.set_light_mode("cone")
