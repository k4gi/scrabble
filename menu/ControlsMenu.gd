extends NinePatchRect


const CONTROL_SETTING = preload("res://menu/ControlSetting.tscn")


onready var ControlBox = $Margin/VBox/ScrollContainer/VBox
onready var ControlPopup = $StopMouse


var control_list = {
	"Move Up": "move_up",
	"Move Down": "move_down",
	"Move Left": "move_left",
	"Move Right": "move_right",
	"Shoot": "shoot",
	"Aim": "aim",
	"Interact": "interact",
	"Screenshot": "print_screen"
}


func _ready():
	#populate control list
	for each_name in control_list.keys():
		var new_setting = CONTROL_SETTING.instance()
		new_setting.set_control(each_name, InputMap.get_action_list(control_list[each_name])[0].as_text())
		new_setting.connect("change_control", self, "_on_change_control")
		ControlBox.add_child(new_setting)


func _on_change_control(name, action):
	ControlPopup.set_visible(true)
