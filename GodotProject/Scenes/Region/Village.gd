# note: this is just a placeholder.
# we're hoping to have a more extensive village in the release version,
# complete with NPCs and shops and stuff.


extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.village_location = self.get_global_position()

