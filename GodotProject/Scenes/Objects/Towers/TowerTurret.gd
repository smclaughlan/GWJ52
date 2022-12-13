extends Node2D

onready var enemy_detection_area = get_node("EnemyDetectionArea")
onready var shoot_timer = get_node("ShootTimer")

export var bullet_scene_1 : PackedScene
export var bullet_scene_2 : PackedScene
export var bullet_scene_3 : PackedScene
var current_bullet_scene = bullet_scene_1

#var turret_type = "beam"
var tower_type : int # from Global.Tower_Types enum
var turret_range = 30
var turret_fire_rate = 1.0
var projectile_speed = 400
var target = null




# Called when the node enters the scene tree for the first time.
func _ready():
	if current_bullet_scene == null:
		current_bullet_scene = bullet_scene_1


func _physics_process(delta):
	if !target or !is_instance_valid(target):
		return
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance < 600.0: # hax, to prevent them looking at the origin of the universe sometimes
		if target.get("velocity"): # verify that they have the velocity property
			point_toward(target.global_position + target.velocity * (distance/projectile_speed) / delta)
		else:
			point_toward(target.global_position)

func point_toward(targetPos):
	$DebugInfo.text = str(targetPos)
	$InvisibleTurret.look_at(targetPos)
	
	var targetRot = $InvisibleTurret.rotation + (2*PI) # prevent negative rotations
	var rotation_as_fraction = targetRot / (2*PI)
	
	# change the spritesheet frame for animated 8-way turrets
	if $Sprite.hframes > 1 or $Sprite.vframes > 1:
		var total_frames = $Sprite.hframes * $Sprite.vframes
		var offset_frame = 6
		var current_frame = int(rotation_as_fraction * float(total_frames)) + offset_frame
		current_frame = current_frame % (total_frames-1)
		$Sprite.frame = current_frame

func upgrade():
	
	current_bullet_scene = bullet_scene_2

func shoot():
	if current_bullet_scene == null:
		current_bullet_scene = bullet_scene_1
	var new_projectile = current_bullet_scene.instance()
	Global.stage_manager.current_map.add_child(new_projectile)
	new_projectile.init(global_position, $InvisibleTurret.global_rotation)


func init(towerType : int, _turret_range : int):
	tower_type = towerType
	update_turret_range(_turret_range)

func set_properties():
	pass

func update_turret_range(_turret_range):
	turret_range = _turret_range
	enemy_detection_area.get_node("CollisionShape2D").scale = Vector2(turret_range, turret_range)

func _on_Area2D_body_entered(body):
	if !target or !is_instance_valid(target):
		target = body
		shoot_timer.start(turret_fire_rate)


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
			shoot_timer.start(turret_fire_rate)
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
