extends KinematicBody2D


var max_health = 100.0
var health = max_health


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die():
	$DeathTimer.start()

func die_for_real_this_time():
	$DecayTimer.start()

func _on_hit(damage, impulseVector, damageAttributes):
	health -= damage
	
	if damage <= 0:
		die()
		


func _on_DeathTimer_timeout():
	die_for_real_this_time()
