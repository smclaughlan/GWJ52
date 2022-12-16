# move toward village
# attack player
# attack villagers
# take damage, die




extends KinematicBody2D


export var health = 20.0
export var speed = 2.0
var velocity : Vector2 = Vector2.ZERO
var prev_position : Vector2 = Vector2.ZERO
onready var nav_agent = $NavigationAgent2D
onready var sprite = $Sprite
onready var weapons = $Weapons
export (PackedScene) var float_text
var nav_target


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
	set_attack_target(choose_target())


func init(initialPos, wayFinder):
	set_global_position(initialPos)
	if wayFinder:
		nav_target = wayFinder
		var _err = connect("died", wayFinder, "_on_creep_died")
	#set_attack_target(Global.player)
	
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


func choose_target():
	var target : Object
	var targetLocation : Vector2
	
	var vector_to_player = Global.player.global_position - self.global_position
	var vector_to_village = Global.village_location - self.global_position
	if vector_to_player.length_squared() > vector_to_village.length_squared():
		target = get_nearest_target()
		targetLocation = target.global_position
	else:
		target = Global.player
		targetLocation = Global.player.global_position
		
	nav_agent.set_target_location(targetLocation)
	return target



func get_nearest_target():
	var potentialTargets = []
	var houses = get_tree().get_nodes_in_group("village")
	for house in houses:
		if house.State in [ house.States.READY ]:
			potentialTargets.append(house)

	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if randf() < 0.2: # mostly creeps should march past towers.
			potentialTargets.append(tower)
		
	potentialTargets.append(Global.player)
	
	return Global.get_closest_object(potentialTargets, self)


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
	
	#select_animation("walk")
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	nav_agent.get_next_location()
	

	
	
	
	var direction = global_position.direction_to(nav_agent.get_next_location())
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	var new_angle = velocity.angle()
	#sprite.rotation = new_angle
	if velocity.x > 0:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
		
	
	weapons.rotation = new_angle
	var _collision = move_and_collide(velocity)

#	var myPos = get_global_position()
#
#	var playerPos = Vector2.ZERO
#	if Global.player != null:
#		playerPos = Global.player.get_global_position()
#
#	var targetPos = nav_target.get_global_position()
#	var dirToPlayer = myPos.direction_to(playerPos)
#	var dirToNavTarget = myPos.direction_to(targetPos)
#
#	if Goal == Goals.ATTACK_PLAYER:
#		var _collision = move_and_collide(dirToPlayer * delta * Global.game_speed * speed)
#	elif Goal == Goals.ATTACK_VILLAGE:
#		var _collision = move_and_collide(dirToNavTarget * delta * Global.game_speed * speed)

func begin_dying(): # death animation and loot spawn
	State = States.DEAD
	# disable collisions
	$CollisionShape2D.set_deferred("disabled", true)
	$ObstacleDetectionZone/CollisionShape2D.set_deferred("disabled", true)
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
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position+impactVector, 0.1)

	

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
		choose_target()
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
