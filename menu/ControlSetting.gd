extends VBoxContainer


signal change_control(name, action)


onready var Name = $ControlSetting/ControlName
onready var Action = $ControlSetting/ControlSet


var action_label = ""
var action_name = ""


func set_control(name, action):
	action_label = name
	action_name = action


func _ready():
	Name.set_text(action_label)
	Action.set_text(action_name)


func _on_ChangeButton_pressed():
	emit_signal("change_control", Name.get_text(), action_name)
