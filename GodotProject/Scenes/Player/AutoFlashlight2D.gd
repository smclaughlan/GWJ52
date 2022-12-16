extends Light2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
