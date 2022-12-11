extends KinematicBody2D


var velocity : Vector2 = Vector2.ZERO
var player_speed : float = 400.0

onready var weapons = $Weapons.get_children()

export var health : int = 100
export var max_health : int = 100

enum States {INITIALIZING, READY, DYING, DEAD}
var State = States.INITIALIZING

onready var tools = {
	"melee":$Toolbelt/Sword,
	"range":$Toolbelt/Gun,
	"build":$Toolbelt/ConstructionWrench,
}

onready var handNodes = {
	"left":{
				"node":$LeftHand,
				"action":"left_hand"
			},
	"right":{
				"node":$RightHand,
				"action":"right_hand"
			},
}



# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self
	initialize_weapons()
	initialize_hud()
	State = States.READY

func initialize_weapons():
	set_tool("range", "left")

func initialize_hud():
	$HUD.init(self)

func set_tool(toolString : String = "range", hand : String = "left"):
	# put a tool in the left or right hand and tell it which action to listen for.
	# note: We aren't shuffling nodes, we duplicate tools from the toolbelt, then delete them when no longer needed.
	
	disable_tools(hand)
	var newTool = tools[toolString].duplicate()
	handNodes[hand]["node"].add_child(newTool)
	if newTool.has_method("init"):
		newTool.init(self)
		newTool.equip(handNodes[hand]["action"])
	else:
		printerr("Configuration error in PlayerAvatar.gd set_tool(), trying to use a tool with no init method")


func disable_tools(hand : String):
	for existingTool in handNodes[hand]["node"].get_children():
		existingTool.disable()
		existingTool.queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if State == States.DEAD:
		return

	velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN


	velocity = velocity.normalized() * player_speed

	velocity = move_and_slide(velocity * Global.game_speed) # delta not required

func begin_dying():
	# start a timer and play an animation. Maybe give the player a chance for a miracle recovery?
	State = States.DYING
	$DeathTimer.start()

func die_for_real_this_time():
	# show a death screen and pop up a restart option
	State = States.DEAD
	disable_tools("left")
	disable_tools("right")
	$HUD/DeathDialog.popup_centered_ratio(0.75)

func _on_knockback(impulseVector):
	var _remainingVel = move_and_slide(impulseVector)
	
func _on_hit(damage, impulseVector, _damageAttributes):
	if State != States.DEAD:
		_on_knockback(impulseVector)
		health -= damage
		$StatusBars/TextureProgress.value = health
		if health <= 0:
			begin_dying()



func _on_DeathTimer_timeout():
	die_for_real_this_time()


func _on_DeathDialog_confirmed():
	Global.stage_manager.return_to_main()


#	for weapon in weapons:
#		if weapon.has_method("toggle_shooting"):
#			weapon.toggle_shooting()



