extends StaticBody2D

var max_health : float = 100.0
var health : float = max_health

enum States { INITIALIZING, READY, DEAD }
var State = States.INITIALIZING

signal possessed_by_player()

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY
	$HealthBar.hide()
	$Corpse.hide()
	


func begin_dying():
	$AnimationPlayer.play("die")
	$DeathTimer.start()
	
func die_for_real_this_time():
	$Sprite.hide()
	$Corpse.show()
	$DecayTimer.start()


func _on_hit(damage, _impactVector, _damageAttributes):
	$HealthBar.show()
	if not State in [ States.INITIALIZING, States.DEAD ]: 
		health -= damage
		$HealthBar.value = health / max_health
		if health <= 0:
			begin_dying()
		


func _on_DecayTimer_timeout():
	queue_free()


# moved to death timer
#func _on_AnimationPlayer_animation_finished(anim_name):
#	if anim_name == "die":
#		die_for_real_this_time()


func _on_Area2D_body_entered(body):
	if body == Global.player and body.State == body.States.GHOST:
		var _err = connect("possessed_by_player", body, "_on_golem_entered")
		
		emit_signal("possessed_by_player")
		# maybe needs an animation too
		queue_free()


func _on_SpareGolem_possessed_by_player():
	pass # Replace with function body.




func _on_DeathTimer_timeout():
	die_for_real_this_time()
