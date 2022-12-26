extends Camera2D

var zoomed_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var delay_let_ancestors_initialize_first = get_tree().create_timer(0.1)
	yield(delay_let_ancestors_initialize_first, "timeout")
	
	toggle_zoom()


func toggle_zoom():
	zoomed_in = !zoomed_in
	if zoomed_in:
		set_zoom(Vector2.ONE*1.6 * Global.player.scale.x)
	else:
		set_zoom(Vector2.ONE*2.0 * Global.player.scale.x)
	

func _unhandled_input(_event):
	if Input.is_action_just_pressed("zoom_toggle"):
		toggle_zoom()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
