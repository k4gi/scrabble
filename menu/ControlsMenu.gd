extends NinePatchRect


signal close_menu()


const CONTROL_SETTING = preload("res://menu/ControlSetting.tscn")


onready var ControlBox = $Margin/VBox/ScrollContainer/VBox
onready var ControlPopup = $StopMouse
onready var ResetPopup = $StopMouse2


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

var default_controls = {
	"move_up": null,
	"move_down": null,
	"move_left": null,
	"move_right": null,
	"shoot": null,
	"aim": null,
	"interact": null,
	"print_screen": null
}


var control_settings = []

var active_setting = null


func _ready():
	#populate control list and default controls
	for each_name in control_list.keys():
		var new_setting = CONTROL_SETTING.instance()
		
		var action = InputMap.get_action_list(control_list[each_name])[0]
		
		default_controls[control_list[each_name]] = action
		
		var action_string = get_event_string(action)
		
		new_setting.set_control(each_name, action_string)
		
		new_setting.connect("change_control", self, "_on_change_control")
		control_settings.append(new_setting)
		ControlBox.add_child(new_setting)


func _input(event):
	if active_setting != null:
		if event.has_method("get_relative"): #one of the properties InputEventMouseMotion has
			pass
		else:
			remap_control(event)


func _on_change_control(node):
	active_setting = node
	ControlPopup.set_visible(true)


func remap_control(event):
	InputMap.action_erase_events( control_list[active_setting.action_label] )
	InputMap.action_add_event( control_list[active_setting.action_label], event )
	active_setting.Action.set_text( get_event_string(event) )
	active_setting = null
	ControlPopup.set_visible(false)


func get_event_string(event) -> String:
	var output = ""
	if event.has_method("get_scancode"): #Key (not physical key?)
		output = OS.get_scancode_string(event.get_scancode())
	elif event.has_method("get_button_index"): #mouse button
		output = get_mouse_string( event.get_button_index() )
	return output
	

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
	


func _on_ResetButton_pressed():
	ResetPopup.set_visible(true)


func _on_ResetNoButton_pressed():
	ResetPopup.set_visible(false)


func _on_ResetYesButton_pressed():
	var i = 0
	for each_name in control_list.keys():
		InputMap.action_erase_events( control_list[each_name] )
		InputMap.action_add_event( control_list[each_name], default_controls[control_list[each_name]] )
		control_settings[i].Action.set_text( get_event_string(default_controls[control_list[each_name]]) )
		i += 1
	
	ResetPopup.set_visible(false)


func _on_BackButton_pressed():
	emit_signal("close_menu")
