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
		
		var action = InputMap.get_action_list(control_list[each_name])[0]
		var action_string = ""
		if action.has_method("get_scancode"): #Key (not physical key?)
			action_string = OS.get_scancode_string(action.get_scancode())
		elif action.has_method("get_button_index"): #mouse button
			action_string = get_mouse_string( action.get_button_index() )
		
		new_setting.set_control(each_name, action_string)
		
		new_setting.connect("change_control", self, "_on_change_control")
		ControlBox.add_child(new_setting)


func _on_change_control(name, action):
	ControlPopup.set_visible(true)


func get_mouse_string(mouse_button_index) -> String:
	match mouse_button_index:
		1:
			return "Left Mouse Button"
		2:
			return "Right Mouse Button"
		3:
			return "Middle Mouse Button"
		4:
			return "Mouse Wheel Up"
		5:
			return "Mouse Wheel Down"
		6:
			return "Mouse Wheel Left"
		7:
			return "Mouse Wheel Right"
		8:
			return "Extra Mouse Button 1"
		9:
			return "Extra Mouse Button 2"
		_:
			return "mouse_string_error"
	
