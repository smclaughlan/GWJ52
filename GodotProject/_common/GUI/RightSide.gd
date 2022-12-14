extends VBoxContainer

var window_sizes = [Vector2(800, 600), Vector2(1024, 600), Vector2(1280, 720), Vector2(1366, 768), Vector2(1600, 900), Vector2(1980, 1080), Vector2(1980, 1020)]

func _ready():
	# set the previous values
	get_node("HBoxContainer2/CheckButton").pressed = Global.enable_fps_counter
	get_node("HBoxContainer3/CheckButton2").pressed = OS.vsync_enabled
	get_node("HBoxContainer5/CheckButton3").pressed = OS.window_fullscreen
	get_node("HBoxContainer4/OptionButton").disabled = OS.window_fullscreen
	get_node("HBoxContainer4/OptionButton").selected = Global.previous_window_index
	get_node("HBoxContainer6/OptionButton2").selected = int(Engine.target_fps / 30) - 1
	
	pass



func _on_CheckButton_pressed():
	Global.enable_fps_counter = !Global.enable_fps_counter
	Global.show_fps_counter()


func _on_CheckButton2_pressed():
	OS.vsync_enabled = !OS.vsync_enabled


func _on_CheckButton3_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	get_node("HBoxContainer4/OptionButton").disabled = OS.window_fullscreen


func _on_OptionButton_item_selected(index):
	OS.window_size = window_sizes[index]
	Global.previous_window_index = index


func _on_OptionButton2_item_selected(index):
	Engine.target_fps = int(get_node("HBoxContainer6/OptionButton2").text)
