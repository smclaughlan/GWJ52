# a wave of creeps will be a small flock following a single navigation node toward the city.

extends Node2D


var target_location : Vector2
var speed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(targetPos : Vector2):
	if targetPos == null or targetPos == Vector2.ZERO:
		targetPos = Global.village_location
	$NavigationAgent2D.set_target_location(targetPos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	target_location = $NavigationAgent2D.get_next_location()
	
	position += (target_location - get_global_position()) * delta * speed * Global.game_speed
	
