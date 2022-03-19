extends VBoxContainer


signal change_control(name, action)


onready var Name = $ControlSetting/ControlName


var action_label = ""
var action_name = ""


func set_control(name, action):
	action_label = name
	action_name = action


func _ready():
	Name.set_text(action_label)


func _on_ChangeButton_pressed():
	emit_signal("change_control", Name.get_text(), action_name)
