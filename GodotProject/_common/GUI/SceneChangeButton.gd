extends Button
export var target_scene : PackedScene

export var return_to_main : bool = false

signal new_scene_requested()

# Called when the node enters the scene tree for the first time.
func _ready():
	# delay init to allow parent scene to load
	var _err = get_tree().create_timer(0.1, false).connect("timeout", self, "delayed_ready")


func delayed_ready():
	var stage_manager = Global.stage_manager
	if not is_connected("new_scene_requested", stage_manager, "_on_scene_change_requested"):
		var err = connect("new_scene_requested", stage_manager, "_on_scene_change_requested")
		if err != OK:
			print("Error connecting to _on_scene_change_requested")
			return


func _on_SceneChangeButton_pressed():
	$ClickNoise.play()
	


		


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_OptionButton_pressed():
	Global.enable_fps_counter = !Global.enable_fps_counter
	Global.show_fps_counter()


func _on_CheckButton_pressed():
	OS.vsync_enabled = !OS.vsync_enabled
	print(OS.vsync_enabled)


func _on_SceneChangeButton_mouse_entered():
	$HoverNoise.play()


func _on_ClickNoise_finished():
	if not return_to_main:
		emit_signal("new_scene_requested", target_scene)
	else:
		Global.stage_manager.return_to_main()
