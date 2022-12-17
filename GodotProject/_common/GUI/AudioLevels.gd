extends HBoxContainer
export var audio_bus_name := "Master"
onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready():
	find_node("VolumeSlider").value = db2linear(AudioServer.get_bus_volume_db(_bus))


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	
