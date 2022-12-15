extends Line2D


var time_between_updates : float = 0.5
var elapsed_time : float = 0.0
var last_check_time : float = 0.0

var creep

# Called when the node enters the scene tree for the first time.
func _ready():
	creep = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if creep.State == creep.States.DEAD:
		queue_free()
		return
	else:
		set_global_position(Vector2.ZERO)
		elapsed_time += delta
		if elapsed_time > last_check_time + time_between_updates:
			last_check_time = elapsed_time
			update_vis_line()

func update_vis_line():
	self.points = get_parent().get_node("NavigationAgent2D").get_nav_path()
	
