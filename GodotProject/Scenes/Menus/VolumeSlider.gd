extends VSlider


onready var master_bus = AudioServer.get_bus_index("Master")


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
