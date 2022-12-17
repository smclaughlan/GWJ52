extends KinematicBody2D

var previous_velocity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO
var player_speed : float = 400.0
var dash_multiple : float = 8.0

onready var weapons = $Weapons.get_children()
onready var hud = $HUD

export var health : int = 100
export var max_health : int = 100

var lives_remaining : int = 5 # each life should be represented by a golem on the map
# players inhabit golems to go do stuff.

enum States {INITIALIZING, READY, DYING, GHOST, DEAD}
var State = States.INITIALIZING


var action_states = {
	"moving":false,
	"attacking":false,
	"dashing":false,
	"building":true,
	
}


onready var tools = {
	"melee":$Toolbelt/Axe,
	"range":$Toolbelt/Gun,
	"build":$Toolbelt/ConstructionWrench,
	#"flashlight":$Toolbelt/Flashlight,
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
	
	initialize_hud()
	#initialize_weapons() # moved to delayed init timer
		
	$Sprite/AnimatedSprite.animation = "GolemIdle"
	
	hide_things_for_later()
	State = States.READY



func hide_things_for_later():
	$DeathNotice.hide()
	$ThreatIndicator.hide()
	$GolemCorpse.hide()




func initialize_weapons():
	set_tool("range", "left")

func initialize_hud():
	$HUD.init(self)

func set_tool(toolString : String = "range", hand : String = "left"):
	# put a tool in the left or right hand and tell it which action to listen for.
	# note: We aren't shuffling nodes, we duplicate tools from the toolbelt, then delete them when no longer needed.
	if not State in [ States.READY, States.INITIALIZING ]:
		return
	
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

	previous_velocity = velocity
	velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN

	if Input.is_action_just_pressed("dash") and $DashTimer.is_stopped() and $DashTimer/RestTimer.is_stopped() == true:
		$DashParticles.emitting = true
		$DashTimer.start()
		$DashTimer/RestTimer.start() # longer than the dash
	var dashFactor : float = 1.0
	if Input.is_action_pressed("dash") and $DashTimer.is_stopped() == false:
		dashFactor = dash_multiple
	velocity = velocity.normalized() * player_speed * dashFactor

	velocity = move_and_slide(velocity * Global.game_speed) # delta not required

	flip_sprite_toward_mouse()
	choose_walk_or_idle_animation()
	
	
func choose_walk_or_idle_animation():
	if State in [States.READY]: # not dead, not a ghost.
		if velocity.length_squared() > 0:
			if $Sprite/AnimatedSprite.get_animation() == "GolemIdle":
				$Sprite/AnimatedSprite.play("GolemWalk")
		else:
			if $Sprite/AnimatedSprite.get_animation() == "GolemWalk":
				$Sprite/AnimatedSprite.play("GolemIdle")



func flip_sprite_toward_mouse():
	if get_global_mouse_position().x > global_position.x:
		$Sprite.scale.x = -abs($Sprite.scale.x)
	else:
		$Sprite.scale.x = abs($Sprite.scale.x)

func begin_dying():
	# start a timer and play an animation. Maybe give the player a chance for a miracle recovery?
	State = States.DYING
	$DeathTimer.start()


func drop_a_broken_golem():
	var newCorpse = $GolemCorpse.duplicate()
	Global.current_map.find_node("YSort").add_child(newCorpse)
	newCorpse.set_global_position(global_position)
	newCorpse.show()

func turn_into_a_ghost():
	$Sprite/AnimatedSprite.animation = "ghost"
	$Sprite/AnimatedSprite.play()

	$DeathNotice.position = Vector2(25, -25)
	$DeathNotice.show()
	
	var tween = get_tree().create_tween()
	tween.tween_property($DeathNotice, "position", Vector2(25, 25), 0.3)
	$DeathNotice/NotificationTimer.start()
	
	disable_tools("left")
	disable_tools("right")
	State = States.GHOST
	
func resurrect():
	# turn back into a golem
	$Sprite/AnimatedSprite.play("GolemIdle")
	$DeathNotice.hide()
	health = max_health
	$StatusBars/TextureProgress.value = health
		
	State = States.READY
	initialize_weapons()


func die_for_real_this_time():
	# show a death screen and pop up a restart option
	State = States.DEAD
	disable_tools("left")
	disable_tools("right")
	$HUD/DeathDialog.popup_centered_ratio(0.75)

func _on_knockback(impulseVector):
	#var _remainingVel = move_and_slide(impulseVector)
	if health <= 0:
		return

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position+impulseVector, 0.1)

	
	
func _on_hit(damage, impulseVector, _damageAttributes):
	if State != States.DEAD:
		_on_knockback(impulseVector)
		health -= damage
		$StatusBars/TextureProgress.value = health
		if health <= 0:
			begin_dying()



func _on_DeathTimer_timeout():
	if lives_remaining > 0:
		drop_a_broken_golem()
		turn_into_a_ghost()
	else:
		die_for_real_this_time()


func _on_DeathDialog_confirmed():
	Global.stage_manager.return_to_main()


#	for weapon in weapons:
#		if weapon.has_method("toggle_shooting"):
#			weapon.toggle_shooting()





func _on_NotificationTimer_timeout():
	$DeathNotice.hide()
	
func _on_golem_entered():
	if State == States.GHOST:
		resurrect()


func _on_DelayInitTimer_timeout():
	set_tool("build", "left")

func _on_creep_wave_started(location):
	pass
#	$ThreatIndicator.show()
#	$ThreatIndicator.look_at(location)
#	$ThreatIndicator/ThreatIndicatorTimer.start()
	

func _on_ThreatIndicatorTimer_timeout():
	$ThreatIndicator.hide()
