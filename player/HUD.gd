extends Control


const POPUP_SPEED = 5

onready var scoreout = $Margin/HBox/VBox/HBox/Score
onready var scoremax = $Margin/HBox/VBox/HBox/ScoreMax
onready var healthout = $Margin/HBox/VBox/HBox2/Health
onready var popupout = $Margin/HBox/Popup
onready var tween = $Tween

var score = 0


func _ready() -> void:
	scoreout.set_text(str( score) )
	
	EventJug.connect("score_add", self, "_on_score_add")
	EventJug.connect("score_set_max", self, "_on_score_set_max")
	EventJug.connect("health_update", self, "_on_health_update")
	EventJug.connect("open_exit", self, "_on_open_exit")
	EventJug.connect("not_enough_fuel", self, "_on_not_enough_fuel")


func _exit_tree() -> void:
	EventJug.disconnect("score_add", self, "_on_score_add")
	EventJug.disconnect("score_set_max", self, "_on_score_set_max")
	EventJug.disconnect("health_update", self, "_on_health_update")
	EventJug.disconnect("open_exit", self, "_on_open_exit")
	EventJug.disconnect("not_enough_fuel", self, "_on_not_enough_fuel")


func _on_score_add(value):
	score += value
	scoreout.set_text( str(score) )
	EventJug.emit_signal("score_show", score)


func _on_health_update(value):
	healthout.set_text( str(value) )


func _on_score_set_max(value):
	scoremax.set_text( str(value) )


func _on_open_exit():
	show_popup("The generator is running! Get to the elevator")


func _on_not_enough_fuel():
	show_popup("Not enough fuel!")


func show_popup(text):
	if tween.is_active():
		yield(tween, "tween_all_completed")
	
	popupout.set_text(text)
	
	tween.interpolate_property(popupout, "modulate",
		Color.white, Color.transparent, POPUP_SPEED,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
