extends Control


onready var Header = $NinePatchRect/Margin/VBox/Label
onready var WinButton = $NinePatchRect/Margin/VBox/WinButton
onready var LoseButton = $NinePatchRect/Margin/VBox/Button
onready var ZombiesOut = $NinePatchRect/Margin/VBox/HBox/ZombiesOut
onready var LevelOut = $NinePatchRect/Margin/VBox/HBox2/LevelOut
onready var ZombiesText = $NinePatchRect/Margin/VBox/HBox
onready var LevelText = $NinePatchRect/Margin/VBox/HBox2


func _ready():
	EventJug.connect("win_game", self, "_on_win_game")
	EventJug.connect("lose_game", self, "_on_lose_game")
	EventJug.connect("show_stats", self, "_on_show_stats")


func _on_Button_pressed():
	get_tree().set_pause(false)
	get_tree().reload_current_scene()


func _on_win_game():
	if not is_visible():
		Header.set_text("You Win!")
		get_tree().set_pause(true)
		WinButton.set_visible(true)
		set_visible(true)


func _on_lose_game():
	if not is_visible():
		Header.set_text("You Lose...")
		yield(get_tree().create_timer(3), "timeout")
		get_tree().set_pause(true)
		LoseButton.set_visible(true)
		ZombiesText.set_visible(true)
		LevelText.set_visible(true)
		set_visible(true)


func _on_WinButton_pressed():
	get_tree().set_pause(false)
	EventJug.emit_signal("load_next_level")


func _on_show_stats(level, zombies):
	LevelOut.set_text( str(level) )
	ZombiesOut.set_text( str(zombies) )
