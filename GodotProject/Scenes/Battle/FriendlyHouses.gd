extends StaticBody2D

var max_health : float = 100.0
var health : float = max_health

enum States { INITIALIZING, READY, DEAD }
var State = States.INITIALIZING



# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY
	$HealthBar.hide()
	$Corpse.hide()

func begin_dying():
	$AnimationPlayer.play("die")
	
func die_for_real_this_time():
	$Sprite.hide()
	$corpse.show()
	$DecayTimer.start()


func _on_hit(damage, _impactVector, _damageAttributes):
	$HealthBar.show()
	if not State in [ States.INITIALIZING, States.DEAD ]: 
		health -= damage
		$HealthBar.value = health / max_health
		if damage <= 0:
			begin_dying()
		


func _on_DecayTimer_timeout():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		die_for_real_this_time()
