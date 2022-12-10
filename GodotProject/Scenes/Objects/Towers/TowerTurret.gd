extends Node2D

var turret_type = "fire"
var turret_range = 300
var projectile_speed = 100
var target


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	# For now just shoot at the player.
	target = Utils.get_player()
	
	if !target:
		return
	
	var distance = global_position.distance_to(target.global_position)
	if distance > turret_range:
		return
	
	look_at(target.global_position + target.velocity * (distance/projectile_speed) * delta)

func init(_turret_type):
	turret_type = _turret_type
