extends Node2D


onready var texture_progress = $TextureProgress


func _ready():
	pass # Replace with function body.


func set_range(new_max):
	texture_progress.max_value = new_max


func set_value(_value):
	texture_progress.value = _value
