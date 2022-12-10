extends Node2D


var current_ammo
var can_shoot : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if current_ammo == null:
		current_ammo = $Ammo/Bullet

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		shoot(current_ammo)

func toggle_shooting():
	can_shoot = !can_shoot

func shoot(ammo):
	if !can_shoot:
		return
	
	var new_projectile = ammo.duplicate()
	
	# a signal to the map would be nicer, but this works for now
	get_parent().add_child(new_projectile)
	if new_projectile.has_method("init"):
		new_projectile.init($MuzzlePosition.global_position, $MuzzlePosition.global_rotation)
	

func _process(_delta):
	var mousePos = get_global_mouse_position()

	# flip if needed
	if mousePos.x < get_global_position().x:
		scale.x = -abs(scale.x)
		rotation = global_position.direction_to(mousePos).angle() - PI
	else:
		scale.x = abs(scale.x)
		look_at(get_global_mouse_position())
