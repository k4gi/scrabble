extends Node

func _unhandled_input(event):
	if event.is_action_pressed("print_screen"):
		# wait for frame to finish drawing
		yield(VisualServer, "frame_post_draw")
		# grab image
		var image = get_viewport().get_texture().get_data()
		# and flip on y axis because it's upside down for some reason
		image.flip_y()
		
		#get current date and time for filename
		var datetime = OS.get_datetime()
		var year = "%04d" % datetime["year"]
		var month = "%02d" % datetime["month"]
		var day = "%02d" % datetime["day"]
		var hour = "%02d" % datetime["hour"]
		var minute = "%02d" % datetime["minute"]
		var second = "%02d" % datetime["second"]
		var fulltime = year + "-" + month + "-" + day + " " + hour + "." + minute + "." + second
		
		# save to file
		image.save_png("user://" + fulltime + " " + ProjectSettings.get_setting("application/config/name") + " screenshot.png")
