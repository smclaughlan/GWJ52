extends Line2D


export var default_width : float = 10.0
export var frequency : float = 5.0
var elapsed_time : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	
	set_width(default_width + (sin(elapsed_time * frequency)*(default_width/2.0)))
