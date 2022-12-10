extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var player_speed : float = 400.0

export var health : int = 100
export var max_health : int = 100

enum States {INITIALIZING, READY, DYING, DEAD}
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self
	initialize_weapons()
	State = States.READY
	
func initialize_weapons():
	for weapon in $WeaponSlot.get_children():
		if weapon.has_method("init"):
			weapon.init(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if State == States.DEAD:
		return

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

func begin_dying():
	# start a timer and play an animation. Maybe give the player a chance for a miracle recovery?
	State = States.DYING
	$DeathTimer.start()

func die_for_real_this_time():
	# show a death screen and pop up a restart option
	State == States.DEAD
	$HUD/DeathDialog.popup_centered_ratio(0.75)

func _on_knockback(impulseVector):
	var _remainingVel = move_and_slide(impulseVector)
	
func _on_hit(damage, impulseVector, damageAttributes):
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
