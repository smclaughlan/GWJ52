extends Line2D


export var default_width : float = 10.0
export var frequency : float = 5.0
var elapsed_time : float = 0.0

var tower_socket

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(towerSocket):
	tower_socket = towerSocket

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	
	if tower_socket.connected_to_source == true:
		set_width(default_width + (sin(elapsed_time * frequency)*(default_width/2.0)))
		set_default_color(Color.yellow)
	else:
		set_width(1)
		set_default_color(Color.red)
