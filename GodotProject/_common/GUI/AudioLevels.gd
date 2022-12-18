extends HBoxContainer
export var audio_bus_name := "Master"
onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready():
	var start_volume = db2linear(AudioServer.get_bus_volume_db(_bus)) / 2
	find_node("VolumeSlider").value = start_volume


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	
