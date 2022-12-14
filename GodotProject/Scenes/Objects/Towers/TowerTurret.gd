extends Node2D

onready var enemy_detection_area = get_node("EnemyDetectionArea")
onready var shoot_timer = get_node("ShootTimer")
onready var upgrade_gem_scene = load("res://Scenes/Objects/Towers/UpgradeGem.tscn")

export var bullet_scene_1 : PackedScene
export var bullet_scene_2 : PackedScene

var current_bullet_scene = bullet_scene_1

var tower_base : StaticBody2D

var tower_type : int # from Global.Tower_Types enum
var turret_range = 30
export var turret_reload_delay = 0.75
var projectile_speed : float # declared in bullet scene
var target = null

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
	if projectile_speed == null or projectile_speed == 0.0:
		var referenceBullet = current_bullet_scene.instance()
		projectile_speed = referenceBullet.bullet_speed

		referenceBullet.queue_free()


func _process(delta):
	update()
	if !target or !is_instance_valid(target):
		return
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance < 600.0: # hax, to prevent them looking at the origin of the universe sometimes
		if target.get("velocity"): # verify that they are mobile
			var aim_lead_vector = target.velocity * (distance/projectile_speed) / delta
			point_toward(target.global_position + aim_lead_vector)
		else:
			point_toward(target.global_position)


func point_toward(targetPos):
	$InvisibleTurret.look_at(targetPos)
	update_spritesheet()
	

func update_spritesheet():
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
	elif upgradeType == Global.UpgradeTypes.FASTER:
		turret_reload_delay = 0.33 * turret_reload_delay
		$ShootTimer.set_wait_time( turret_reload_delay )
	elif upgradeType == Global.UpgradeTypes.STRONGER:
		current_bullet_scene = bullet_scene_2
		



func shoot():
	if current_bullet_scene == null:
		current_bullet_scene = bullet_scene_1
	var new_projectile = current_bullet_scene.instance()
	Global.stage_manager.current_map.add_child(new_projectile)
	new_projectile.init(global_position, $InvisibleTurret.global_rotation)


func init(towerType : int, towerBase : StaticBody2D):
	tower_type = towerType
	update_turret_range(turret_range)
	tower_base = towerBase


func update_turret_range(_turret_range):
	turret_range = _turret_range
	enemy_detection_area.get_node("CollisionShape2D").scale = Vector2(turret_range, turret_range)

func _on_Area2D_body_entered(body):
	if !target or !is_instance_valid(target):
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
	if $TowerWireSockets.connected_to_source == false:
		return
	elif !target or !is_instance_valid(target):
		shoot_timer.stop()
		return
	else:
		shoot()

func _on_base_destroyed():
	$TowerWireSockets.disconnect_all()
	queue_free()


func _draw():
	draw_circle(Vector2.ZERO, 10.0 * turret_range, Color(0.9, 0.9, 0.2, 0.05))
	
