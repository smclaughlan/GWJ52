extends Node2D


var current_ammo


# Called when the node enters the scene tree for the first time.
func _ready():
	if current_ammo == null:
		current_ammo = $Ammo/Bullet

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		shoot(current_ammo)
	else:
		printerr("config error in Gun.gd, _unhandled_input(). Ammo has no shoot method.")


func shoot(ammo):
	
	var new_projectile = ammo.duplicate()
	
	# a signal to the map would be nicer, but this works for now
	get_parent().add_child(new_projectile)
	new_projectile.init($MuzzlePosition.global_position, $MuzzlePosition.global_rotation)
	

func _process(_delta):
	# temporary aiming mechanic
	look_at(get_global_mouse_position())
