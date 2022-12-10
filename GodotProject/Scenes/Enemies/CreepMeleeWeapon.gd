extends Area2D

enum States { INITIALIZING, READY, ATTACKING, COCKING, RELOADING, DISABLED }
var State = States.INITIALIZING

export var damage : int = 10
var damage_attributes = { } # future potential for poison, flaming, etc.


export var num_attacks_per_set : int = 3
var attacks_this_set : int = 0

var current_target

signal hit(damage, impactVector, damageAttributes)

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if current_target != null:
		look_at(current_target.get_global_position())
	$DebugInfo.set_global_rotation(0)
	$DebugInfo/StateLabel.text = States.keys()[State]

func bite(targetObj):
	if State == States.ATTACKING:
		if get_overlapping_bodies().has(targetObj):
			$AnimationPlayer.play("bite")
			$NomNomNoise.play()
			var impactVector = targetObj.global_position - global_position * damage
			emit_signal("hit", damage, impactVector, damage_attributes)
			attacks_this_set += 1
			if attacks_this_set > num_attacks_per_set:
				State = States.RELOADING
				$ReloadTimer.start()
			else:
				State = States.COCKING
				$CockTimer.start()
		else: # target disappeared.
			if not is_instance_valid(targetObj):
				current_target = Global.player
			State = States.READY

func disable():
	$CollisionShape2D.set_deferred("disabled", true)
	State = States.DISABLED
	

func _on_CreepMeleeWeapon_body_entered(body):
	if body == current_target and State == States.READY:
		if not is_connected("hit", body, "_on_hit"):
			var _err = connect("hit", body, "_on_hit")
		State = States.ATTACKING
		$CockTimer.start()


func _on_CreepMeleeWeapon_body_exited(body):
	if body == Global.player:
		if State == States.ATTACKING:
			$CockTimer.stop()
			$ReloadTimer.stop()
			State = States.READY


func set_target(target):
	current_target = target


func _on_CockTimer_timeout():
	if current_target == null:
		current_target = Global.player

	# still need to figure out how to direct attacks elsewhere
	if State in [ States.ATTACKING, States.COCKING ]:
		if get_overlapping_bodies().has(current_target):
			State = States.ATTACKING
			bite(current_target)
		else:
			State = States.READY




func _on_ReloadTimer_timeout(): # ready to fight again
	if get_overlapping_bodies().has(current_target):
		State = States.COCKING
		$CockTimer.start()
	else:
		State = States.READY

	
