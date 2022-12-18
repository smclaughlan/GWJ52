extends Area2D

var myCreep

enum States { INITIALIZING, READY, ATTACKING, COCKING, RELOADING, DISABLED }
var State = States.INITIALIZING

export var base_damage : int = 10
var damage: int = base_damage * Global.difficulty_controller.difficulty_multiplier
var damage_attributes = { } # future potential for poison, flaming, etc.
var knockback_factor : float = 1.0

export var num_attacks_per_set : int = 3
var attacks_this_set : int = 0

var current_target

signal hit(damage, impactVector, damageAttributes)
signal stopped_attacking()

# Called when the node enters the scene tree for the first time.
func _ready():
	myCreep = get_parent().get_parent()
	var _err = connect("hit", myCreep, "_on_used_melee_attack")
	_err = connect("stopped_attacking", myCreep,"_on_stopped_attacking")
	State = States.READY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if current_target != null:
		if is_instance_valid(current_target):
			look_at(current_target.get_global_position())
	$DebugInfo.set_global_rotation(0)
	$DebugInfo/StateLabel.text = States.keys()[State]

func bite(targetObj):
	if State == States.ATTACKING:
		if get_overlapping_bodies().has(targetObj):
			$NomNomNoise.pitch_scale = rand_range(0.8,1.2)
			#$AnimationPlayer.play("bite") # use signal to myCreep instead.
			$NomNomNoise.play()
			var impactVector = targetObj.global_position - global_position * knockback_factor
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
			emit_signal("stopped_attacking")


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
			emit_signal("stopped_attacking")




func _on_ReloadTimer_timeout(): # ready to fight again
	if get_overlapping_bodies().has(current_target):
		State = States.COCKING
		$CockTimer.start()
	else:
		
		State = States.READY
		emit_signal("stopped_attacking")

	
