extends Control


const DIALOG_CHOICE = preload("res://dialog/DialogChoice.tscn")

onready var ChoiceBox = $VBox/VBoxChoices
onready var DialogIcon = $VBox/Dialog/VBox/Header/Icon
onready var DialogName = $VBox/Dialog/VBox/Header/Name
onready var DialogText = $VBox/Dialog/VBox/Content/Text


signal choice_made(result)


func load_dialog(dialog_dict):
	if dialog_dict.has("icon"):
		DialogIcon.set_texture(dialog_dict["icon"])
	if dialog_dict.has("name"):
		DialogName.set_text(dialog_dict["name"])
	DialogText.set_text(dialog_dict["text"])
	
	for each_node in ChoiceBox.get_children():
		each_node.queue_free()
	
	if dialog_dict.has("choices"):
		for each_choice in dialog_dict["choices"]:
			var new_choice = DIALOG_CHOICE.instance()
			new_choice.set_text(each_choice[0])
			new_choice.connect("pressed", self, "_on_Choice_pressed", [each_choice[1]])
			ChoiceBox.add_child(new_choice)
	
	else:
		var new_choice = DIALOG_CHOICE.instance()
		new_choice.set_text("Continue...")
		new_choice.connect("pressed", self, "_on_Choice_pressed", [-1])
		ChoiceBox.add_child(new_choice)


func _unhandled_input(event):
	if is_visible():
		if event.is_action_pressed("move_action"):
			pass


func _on_Choice_pressed(result):
	print("DialogWindow choice_made")
	emit_signal("choice_made", result)
