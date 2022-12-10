extends Node2D


var current_ammo
var can_shoot : bool = true

enum States { INITIALIZING, READY, FIRING, COCKING, RELOADING, DEAD }
var State = States.INITIALIZING

var shooter

signal shot(impulseVector)

# Called when the node enters the scene tree for the first time.
func _ready():
	if current_ammo == null:
		current_ammo = $Ammo/Bullet

	State = States.READY

func init(myShooter): # aka human player
	shooter = myShooter
	if shooter.has_method("_on_knockback"):
		var _err = connect("shot", shooter, "_on_knockback")
	else:
		printerr("Config error in Gun.gd.init() shooter has no _on_knockback method.")

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		shoot(current_ammo)


func shoot(ammo):
	if !can_shoot:
		return

	if State == States.READY:
		$BangNoise.play()
		flash_muzzle()
		knockback_shooter()
		var new_projectile = ammo.duplicate()

		# a signal to the map would be nicer, but this works for now
		Global.stage_manager.current_map.add_child(new_projectile)
		if new_projectile.has_method("init"):
			new_projectile.init($MuzzlePosition.global_position, $MuzzlePosition.global_rotation)
		State = States.COCKING
		$CockTimer.start()

func flash_muzzle():
	$MuzzlePosition/MuzzleFlash.visible = true
	$MuzzlePosition/MuzzleFlash/FlashTimer.start()

func knockback_shooter():
	var knockbackPower = 1050.0
	var impulseVector = (Vector2.RIGHT * knockbackPower).rotated(get_global_rotation() - PI)
	if shooter != null:
		emit_signal("shot", impulseVector)

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
	$MuzzlePosition/MuzzleFlash.hide()
