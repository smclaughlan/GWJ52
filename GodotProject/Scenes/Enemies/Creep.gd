# move toward village
# attack player
# attack villagers
# take damage, die




extends KinematicBody2D


var health = 20.0
var speed = 100.0
var velocity : Vector2 = Vector2.ZERO
var prev_position : Vector2 = Vector2.ZERO
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
		connect("died", Global.pickable_object_spawner, "spawn_pickable")
	$corpse.hide()


func init(initialPos, navTarget):
	set_global_position(initialPos)
	nav_target = navTarget
	State = States.MOVING
	set_target(Global.player)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if State == States.MOVING:
		move(delta)
	
	velocity = (global_position - prev_position)
	prev_position = global_position

func set_target(target):
	for weapon in $Weapons.get_children():
		if weapon.has_method("set_target"):
			weapon.set_target(target)

func move(delta)	:
	var myPos = get_global_position()

	var playerPos = Vector2.ZERO
	if Global.player != null:
		playerPos = Global.player.get_global_position()

	var targetPos = nav_target.get_global_position()
	var dirToPlayer = myPos.direction_to(playerPos)
	var dirToNavTarget = myPos.direction_to(targetPos)

	if Goal == Goals.ATTACK_PLAYER:
		var _collision = move_and_collide(dirToPlayer * delta * Global.game_speed * speed)
	elif Goal == Goals.ATTACK_VILLAGE:
		var _collision = move_and_collide(dirToNavTarget * delta * Global.game_speed * speed)
	
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
	var _collision = move_and_collide(impactVector)

func _on_hit(damage, impactVector, _damageAttributes):
	# worry about damage attributes later
	
	$OwNoise.play()
	knockback(impactVector)
	
	health -= damage
	if health < 0 and State != States.DEAD:
		begin_dying()
	else:
		$InvulnerabiltyTimer.start()
		State = States.INVULNERABLE
	



func _on_DeathTimer_timeout():
	die_for_real_this_time()
	emit_signal("died", dropped_pickable, position)


func _on_InvulnerabiltyTimer_timeout():
	if health > 0:
		State = States.MOVING


func _on_DecayTimer_timeout():
	queue_free()
