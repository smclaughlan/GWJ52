extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(_event):
	if Input.is_action_just_pressed("zoom_out"):
		set_zoom(Vector2.ONE*4.0)
	elif Input.is_action_just_pressed("zoom_in"):
		set_zoom(Vector2.ONE*1.5)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
