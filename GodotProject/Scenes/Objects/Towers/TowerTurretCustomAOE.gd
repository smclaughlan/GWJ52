extends Node2D

onready var enemy_detection_area = get_node("EnemyDetectionArea")
onready var shoot_timer = get_node("ShootTimer")
onready var upgrade_gem_scene = load("res://Scenes/Objects/Towers/UpgradeGem.tscn")

export var bullet_scene_1 : PackedScene
export var bullet_scene_2 : PackedScene

var current_bullet_scene = bullet_scene_1

var tower_base : Node2D

var tower_type : int # from Global.Tower_Types enum
var turret_range = 30
#export var turret_reload_delay = 0.75
export var turret_reload_delay = 2.0
var projectile_speed : float # declared in bullet scene
var target = null

enum target_tracking_methods { AIM_AT, AIM_AHEAD, AIM_RANDOM }
export (target_tracking_methods) var target_tracking_method = target_tracking_methods.AIM_RANDOM

var shine_playing : bool = false

# it's the base that should get attacked, not the turret
#var health = 100
#var max_health = 100



var upgrades = {
	Global.UpgradeTypes.BIGGER:false, # health and range
	Global.UpgradeTypes.FASTER:false, # shoot timer speed
	Global.UpgradeTypes.STRONGER:false, # bullet_scene ( damage, fx )
}



# Called when the node enters the scene tree for the first time.
func _ready():
	if current_bullet_scene == null:
		current_bullet_scene = bullet_scene_1

	lookup_bullet_speed_for_slow_projectiles()

	for gem in $Upgrades.get_children():
		gem.hide()
	if has_node("Sprite/Crystal/Shine"):
		$Sprite/Crystal/Shine.hide()



func lookup_bullet_speed_for_slow_projectiles():
	if target_tracking_method == target_tracking_methods.AIM_AHEAD:
		if projectile_speed == null or projectile_speed == 0.0:
			var referenceBullet = current_bullet_scene.instance()
			if referenceBullet.get("bullet_speed"): # will return null if there's no bullet_speed property, eg: laser beams
				projectile_speed = referenceBullet.bullet_speed
			referenceBullet.queue_free()

	

func _process(delta):
	update() # invokes the draw function to draw a circle
	if target == null or target.get("State") == null:
		return
		
	if is_instance_valid(target) and target.State != target.States.DEAD:
		aim(target, delta)



func aim(myTarget, _delta):
	var distance = global_position.distance_to(target.global_position)
	if distance > 600.0: # hax, to prevent them looking at the origin of the universe sometimes
		find_a_new_target()

	var aim_random_vector = Vector2(rand_range(-300,300), rand_range(-300,300))

	if target_tracking_method == target_tracking_methods.AIM_AHEAD:
		if myTarget.get("velocity"): # verify that they are mobile
			# var time_for_bullet_to_arrive = distance / projectile_speed
			# var aim_lead_vector = myTarget.velocity * time_for_bullet_to_arrive

			point_toward(myTarget.global_position + aim_random_vector)
		
		else:
			point_toward(myTarget.global_position + aim_random_vector)
	elif target_tracking_method == target_tracking_methods.AIM_RANDOM:
		point_toward(self.global_position + aim_random_vector)



	

func point_toward(targetPos):
	$InvisibleTurret.look_at(targetPos)
		

func update_spritesheet_for_upgrades():
	var num_upgrades = 0
	for upgrade in upgrades.keys():
		if upgrades[upgrade] == true:
			num_upgrades += 1
	$Sprite.frame = min(2, num_upgrades)
	
	$Sprite/Crystal.position.y = -10 * $Sprite.frame
	$InvisibleTurret.global_position = $Sprite/Crystal.global_position


func deprecated_rotate_8_way_spritesheet():
	# change the spritesheet frame for animated 8-way turrets
	if $Sprite.hframes > 1 or $Sprite.vframes > 1:
		var total_frames = $Sprite.hframes * $Sprite.vframes
		var offset_frame = 6
		var targetRot = $InvisibleTurret.rotation + (2*PI) # prevent negative rotations
		var rotation_as_fraction = targetRot / (2*PI)
		var current_frame = int(rotation_as_fraction * float(total_frames)) + offset_frame
		current_frame = current_frame % (total_frames-1)
		$Sprite.frame = current_frame


func upgrade(upgradeType): # [bigger, faster, stronger]
	
	if upgradeType == Global.UpgradeTypes.BIGGER:
		tower_base.max_health = 3 * tower_base.max_health
		tower_base.health = tower_base.max_health
		update_turret_range(1.5 * turret_range)
		$Upgrades/Gem0.show()
		tower_base.healthbar.set_range(tower_base.max_health)
		tower_base.healthbar.set_value(tower_base.health)
	if upgradeType == Global.UpgradeTypes.FASTER:
		turret_reload_delay = 0.33 * turret_reload_delay
		$ShootTimer.set_wait_time( turret_reload_delay )
		$Upgrades/Gem1.show()
	if upgradeType == Global.UpgradeTypes.STRONGER:
		current_bullet_scene = bullet_scene_2
		$Upgrades/Gem2.show()
	upgrades[upgradeType] = true
	update_spritesheet_for_upgrades()




func shoot():
	if current_bullet_scene == null:
		current_bullet_scene = bullet_scene_1
	var new_projectile = current_bullet_scene.instance()
	if Global.stage_manager != null and Global.stage_manager.current_map != null and Global.stage_manager.current_map.find_node("YSort") != null:
		Global.stage_manager.current_map.find_node("YSort").add_child(new_projectile)
	else:
		tower_base.get_parent().add_child(new_projectile)
	var muzzle_location = $InvisibleTurret/MuzzleLocation
	# short on time, hard coding if statements based on parameters available for a custom projectile.
	if new_projectile.has_method("set_target"):
		new_projectile.set_target(target)
	new_projectile.init(muzzle_location.global_position, $InvisibleTurret.global_rotation)
	shine_crystal()
	$ShootSound.play()
	$ShootTimer.start()

	
func shine_crystal():
	if has_node("Sprite/Crystal/Shine"):
		var shine = get_node("Sprite/Crystal/Shine")
		if shine_playing == false:
			shine.frame = 0
			$Sprite/Crystal/Shine.show()
			shine.play("shine")
			shine_playing = true

func init(towerType : int, towerBase : Node2D):
	tower_type = towerType
	update_turret_range(turret_range)
	tower_base = towerBase


func update_turret_range(_turret_range):
	turret_range = _turret_range
	enemy_detection_area.get_node("CollisionShape2D").scale = Vector2(turret_range, turret_range)

func _on_Area2D_body_entered(body):
	if target != null and is_instance_valid(target) and target.get("State") and target.State != target.States.DEAD:
		return
	else:
		target = body
		shoot_timer.start(turret_reload_delay)


func _on_Area2D_body_exited(body):
	if body == target:
		target = null
		shoot_timer.stop()
	# Enemy might exit while other enemies are in collider.
		target_closest_enemy()

	
func target_closest_enemy():
	var enemies = enemy_detection_area.get_overlapping_bodies()
	if enemies.size() > 0:
		var closest_enemy = Global.get_closest_object(enemies, self)
		if closest_enemy and is_instance_valid(closest_enemy):
			target = closest_enemy
			shoot_timer.start(turret_reload_delay)
	else:
		target = null

func _on_ShootTimer_timeout():
#	if $TowerWireSockets.connected_to_source == false:
#		return
	if !target or !is_instance_valid(target) or target.get("State") == null or target.State == target.States.DEAD:
		# find a new target.
		find_and_shoot_a_new_target()
	else:
		shoot()

func find_a_new_target():
	var newTarget
	var creepsInRange = $EnemyDetectionArea.get_overlapping_bodies()
	var numCreeps = creepsInRange.size()
	if numCreeps > 0:
		for i in numCreeps:
			var nextCreep = creepsInRange[i]
			if nextCreep.State != nextCreep.States.DEAD:
				target = nextCreep
				return
		
func find_and_shoot_a_new_target():
	find_a_new_target()
	shoot()
	
	
	
func _on_base_destroyed():
	$TowerWireSockets.disconnect_all()
	queue_free()


func _draw():
	pass
	draw_circle(Vector2.ZERO, 10.0 * turret_range, Color(0.9, 0.9, 0.2, 0.01))
	


func _on_Shine_animation_finished():
	shine_playing = false
	if has_node("Sprite/Crystal/Shine"):
		$Sprite/Crystal/Shine.hide()
