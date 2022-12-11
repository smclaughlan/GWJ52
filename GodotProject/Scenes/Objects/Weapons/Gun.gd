extends Node2D


var current_ammo
var can_shoot : bool = true

enum States { INITIALIZING, READY, FIRING, COCKING, RELOADING, DEAD }
var State = States.INITIALIZING
var equipped : bool = false
var action_to_use : String

var shooter

signal shot(impulseVector)

# Called when the node enters the scene tree for the first time.
func _ready():
	if current_ammo == null:
		current_ammo = $Ammo/Bullet

	State = States.READY

func init(myShooter): # aka human player
	shooter = myShooter
	set_global_position(shooter.global_position)
	if shooter.has_method("_on_knockback"):
		var _err = connect("shot", shooter, "_on_knockback")
	else:
		printerr("Config error in Gun.gd.init() shooter has no _on_knockback method.")

func _unhandled_input(event):
	if equipped and event.is_action_pressed(action_to_use):
		shoot(current_ammo)


func shoot(ammo):
	if not equipped:
		return

	if State == States.READY:
		$LaserNoise.play()
		knockback_shooter()
		var new_projectile = ammo.duplicate()

		# a signal to the map would be nicer, but this works for now
		Global.stage_manager.current_map.add_child(new_projectile)
		var rand_offset = Vector2.ZERO
		rand_offset.x = rand_range(-5.0, 5.0)
		rand_offset.y = rand_range(-5.0, 5.0)
		var rand_aim_tremble = rand_range(-0.15, 0.15)
		flash_muzzle()
		$Sprite.rotation = rand_aim_tremble
		var pos = $Sprite/MuzzlePosition.global_position + rand_offset
		var rot = $Sprite/MuzzlePosition.global_rotation + rand_aim_tremble

		if new_projectile.has_method("init"):
			new_projectile.init(pos, rot)
		else:
			printerr("configuration error in Gun.gd: ammo has no init() method")
		State = States.COCKING
		$CockTimer.start()

func flash_muzzle():
	$Sprite/MuzzleFlash.rotation = rand_range(-1.0,1.0)
	var colorChange = rand_range(0.8, 1.0)
	$Sprite/MuzzleFlash.set_self_modulate(Color(colorChange, colorChange, colorChange))
	$Sprite/MuzzleFlash.visible = true
	$Sprite/MuzzleFlash/FlashTimer.start()

func knockback_shooter():
	var knockbackPower = 1050.0
	var impulseVector = (Vector2.RIGHT * knockbackPower).rotated(get_global_rotation() - PI)
	if shooter != null:
		emit_signal("shot", impulseVector)

func enable(actionString:String):
	visible = true
	equipped = true
	action_to_use = actionString
	
func disable():
	visible = false
	equipped = false
	action_to_use = ""
	queue_free() # don't worry, player has a duplicate

func equip(actionString:String):
	enable(actionString)
	
func stow():
	disable()

func _process(_delta):
	var mousePos = get_global_mouse_position()

	# flip if needed
	if mousePos.x < get_global_position().x:
		scale.x = -abs(scale.x)
		rotation = global_position.direction_to(mousePos).angle() - PI
	else:
		scale.x = abs(scale.x)
		look_at(get_global_mouse_position())


func _on_CockTimer_timeout():
	State = States.READY

	# continuous fire by holding mouse button down
	if Input.is_action_pressed("shoot"):
		shoot(current_ammo)



func _on_FlashTimer_timeout():
	$Sprite/MuzzleFlash.hide()
