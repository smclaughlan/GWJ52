extends Camera2D

var zoomed_in = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(_event):
	if Input.is_action_just_pressed("zoom_toggle"):
		zoomed_in = !zoomed_in
		if zoomed_in:
			set_zoom(Vector2.ONE*1.6)
		else:
			set_zoom(Vector2.ONE*2.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
