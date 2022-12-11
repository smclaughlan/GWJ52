extends PopupDialog


export var audio_bus_name := "Master"
onready var _bus := AudioServer.get_bus_index(audio_bus_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	find_node("VolumeSlider").value = db2linear(AudioServer.get_bus_volume_db(_bus))


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	


func _on_ResumeButton_pressed():
	Global.resume()
	self.hide()


func _on_QuitButton_pressed():
	Global.resume()
	Global.stage_manager.return_to_main()


func _on_FreeMoneyButton_pressed():
	Global.currency_tracker.update_amount(100)
