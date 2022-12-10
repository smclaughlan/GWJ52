extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("build"):
		# spawn a tower in the target location
		var tower = preload("res://Scenes/Towers/PlaceholderTower.tscn").instance()
		var towerPosition = $Sprite/TargetPosition.get_global_position()

		# this should be a signal to ask the map to spawn the tower
		Global.current_map.add_child(tower )
		tower.set_global_position(towerPosition)


func _process(_delta):
	$Sprite.look_at(get_global_mouse_position())
