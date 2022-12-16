# move toward village
# attack player
# attack villagers
# take damage, die




extends KinematicBody2D


var health = 20.0
var speed = 2.0
var velocity : Vector2 = Vector2.ZERO
var prev_position : Vector2 = Vector2.ZERO
#onready var nav_agent = $NavigationAgent2D
onready var pathfinder = $Pathfinder
onready var tween = $Tween
onready var tween_knockback = $TweenKnockback
onready var sprite = $Sprite
onready var weapons = $Weapons
export (PackedScene) var float_text
#var nav_target
var target = null


enum Goals { ATTACK_PLAYER, ATTACK_VILLAGE } #move toward is implicit when out of range
# change this to ATTACK_VILLAGE later
var Goal = Goals.ATTACK_PLAYER

enum States { INITIALIZING, READY, MOVING, ATTACKING, INVULNERABLE, RELOADING, STUNNED, DEAD }
var State = States.INITIALIZING

export (PackedScene) var dropped_pickable

signal died

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.pickable_object_spawner != null:
		var _err = connect("died", Global.pickable_object_spawner, "_on_creep_died")

	$corpse.hide()


func init(initialPos):
	set_global_position(initialPos)
	State = States.MOVING
	select_animation("walk")
	$Sprite/AnimatedSprite.play("walk")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State in [ States.MOVING, States.READY ]:
		move(delta)



func set_attack_target(target):
	for weapon in $Weapons.get_children():
		if weapon.has_method("set_target"):
			weapon.set_target(target)


func select_animation(anim_name):
	var animSprite = $Sprite/AnimatedSprite
	if animSprite.get_animation() != anim_name:
		animSprite.play(anim_name)
	if anim_name == "walk":
		$Sprite/AnimatedSprite/eyes.play("walk")
		$Sprite/AnimatedSprite/eyes.frame = $Sprite/AnimatedSprite.frame
	else:
		$Sprite/AnimatedSprite/eyes.visible = false


func move(delta):
	if tween.is_active():
		return

	# Tween from point to point in pathfinder.path
	var next_pos = pathfinder.path.pop_front()
	if next_pos == null:
		return
	tween.interpolate_property(self, "global_position", global_position, next_pos, 0.2)
	tween.start()

	var direction = Vector2.ZERO
	if target != null and is_instance_valid(target):
		direction = global_position.direction_to(target.global_position)
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	var new_angle = velocity.angle()
	if velocity.x > 0:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
	weapons.rotation = new_angle
#	var _collision = move_and_collide(velocity)


func begin_dying(): # death animation and loot spawn
	State = States.DEAD
	# disable collisions
	$CollisionShape2D.set_deferred("disabled", true)
#	$ObstacleDetectionZone/CollisionShape2D.set_deferred("disabled", true)
	disable_weapons()
	$AnimationPlayer.play("die")
	$DeathTimer.start()


func die_for_real_this_time(): # blood smear
	$corpse.show()
	$Sprite.hide()
	$DecayTimer.start()
	emit_signal("died", self, dropped_pickable, position)


func disable_weapons():
	for weapon in $Weapons.get_children():
		if weapon.has_method("disable"):
			weapon.disable()
	$Weapons.hide()

func _on_ObstacleDetectionZone_area_entered(area):
	if area.is_in_group("towers"):
		pass
		# turn left until there's no more obstacles

func knockback(impactVector):
	#var _collision = move_and_collide(impactVector)
	#var _resultVel = move_and_slide(impactVector)
#	tween.interpolate_property(self, "position", position+impactVector, 0.1)
	tween.stop_all()
	tween_knockback.interpolate_property(self, "global_position", global_position, global_position+impactVector, 0.1)
	tween_knockback.start()
	pathfinder.path = []
	pathfinder.restart_pathfinding()
	State = States.STUNNED


func _on_hit(damage, impactVector, _damageAttributes):
	# don't keep taking damage when you're dying or dead.
	if not State in [ States.READY, States.MOVING, States.ATTACKING, States.RELOADING, States.STUNNED ]:
		return


	# worry about damage attributes later
	var new_floating_text = float_text.instance()
	new_floating_text.global_position = global_position
	Global.current_map.add_child(new_floating_text)
	new_floating_text.set_text(damage)
	$OwNoise.play()
	knockback(impactVector)

	health -= damage
	if health <= 0 and State != States.DEAD:
		begin_dying()
	else:
		State = States.INVULNERABLE
		$InvulnerabiltyTimer.start()


func _on_DeathTimer_timeout():
	die_for_real_this_time()



func _on_InvulnerabiltyTimer_timeout():
	if State == States.INVULNERABLE and health > 0:
		State = States.MOVING



func _on_DecayTimer_timeout():
	queue_free()


func _on_PathfindTimer_timeout():
	if State != States.DEAD:
		target = pathfinder.target
		set_attack_target(target)
	else:
		$PathfindTimer.stop()

func _on_used_melee_attack(_damage, _impactVector, _damage_attributes):
	if health > 0 and State != States.DEAD:
		State = States.ATTACKING
		select_animation("attack")
#		$Sprite/AnimatedSprite.play("attack")
#		$Sprite/AnimatedSprite/eyes.visible = false

func _on_stopped_attacking():
	if health > 0 and State != States.DEAD:
		State = States.MOVING
		select_animation("walk")



func _on_Timer_timeout():
	pass # Replace with function body.


func _on_StunTimer_timeout():
	State = States.MOVING
