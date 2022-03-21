extends VBoxContainer


signal change_control(node)


onready var Name = $ControlSetting/ControlName
onready var Action = $ControlSetting/ControlSet
onready var ChangeButton = $ControlSetting/ChangeButton


var action_label = ""
var action_text = ""


func set_control(name, action):
	action_label = name
	action_text = action


func _ready():
	Name.set_text(action_label)
	Action.set_text(action_text)


func set_button_disabled(boolean):
	ChangeButton.set_disabled(boolean)


func _on_ChangeButton_pressed():
	emit_signal("change_control", self)
