extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var player_speed : float = 400.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT
	elif Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN
	
	
	velocity = velocity.normalized() * player_speed

	velocity = move_and_slide(velocity * Global.game_speed) # delta not required

