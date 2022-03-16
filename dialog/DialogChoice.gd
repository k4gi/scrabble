extends VBoxContainer

signal pressed()


func _ready():
	$Button.connect("pressed", self, "_on_pressed")


func set_text(string):
	$Button.set_text(string)


func _on_pressed():
	emit_signal("pressed")
