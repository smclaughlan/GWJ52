extends Light2D


var action_to_use : String
var equipped : bool = false

var player

enum States { INITIALIZING, READY, STORED, ACTIVE }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myPlayer):
	player = myPlayer
	State = States.ACTIVE


func _process(_delta):
	if !equipped or State != States.ACTIVE:
		return
	look_at(get_global_mouse_position())


func _unhandled_input(_event):
	if !equipped or State != States.ACTIVE:
		return
	elif Input.is_action_just_pressed(action_to_use):
		toggle_light()

func toggle_light():
	set_enabled(!enabled)
	

func enable(actionKey : String):
	visible = true
	action_to_use = actionKey
	State = States.ACTIVE
	equipped = true

	
func disable():
	visible = false
	State = States.STORED
	queue_free() # don't worry, player has a duplicate
	
func stow():
	disable()
	
func equip(actionKey : String):
	enable(actionKey)
	
