extends Node2D

export(NodePath) onready var collision_shape = get_node(collision_shape)
export(NodePath) onready var collision_area = get_node(collision_area)
export(NodePath) onready var shoot_timer = get_node(shoot_timer)
var bullet_scene = load("res://Scenes/Objects/Projectiles/Bullet.tscn")
var turret_type = "fire"
var turret_range = 30
var turret_fire_rate = 1.0
var projectile_speed = 400
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !target or !is_instance_valid(target):
		return
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance < 600.0: # hax, to prevent them looking at the origin of the universe sometimes
		point_toward(target.global_position + target.velocity * (distance/projectile_speed) / delta)

func point_toward(targetPos):
	$DebugInfo.text = str(targetPos)
	$InvisibleTurret.look_at(targetPos)
	
	var targetRot = $InvisibleTurret.rotation + (2*PI) # prevent negative rotations
	var rotation_as_fraction = targetRot / (2*PI)
	
	var total_frames = $Sprite.hframes * $Sprite.vframes
	var offset_frame = 6
	var current_frame = int(rotation_as_fraction * float(total_frames)) + offset_frame
	current_frame = current_frame % (total_frames-1)
	$Sprite.frame = current_frame

func shoot():
	var new_projectile = bullet_scene.instance()
	Global.stage_manager.current_map.add_child(new_projectile)
	new_projectile.init(global_position, $InvisibleTurret.global_rotation)


func init(_turret_type, _turret_range):
	turret_type = _turret_type
	update_turret_range(_turret_range)

func update_turret_range(_turret_range):
	turret_range = _turret_range
	collision_shape.scale = Vector2(turret_range, turret_range)

func _on_Area2D_body_entered(body):
	if !target or !is_instance_valid(target):
		target = body
		shoot_timer.start(turret_fire_rate)


func _on_Area2D_body_exited(body):
	if body == target:
		target = null
		shoot_timer.stop()
	# Enemy might exit while other enemies are in collider.
	find_target_in_collider()
	
func find_target_in_collider():
	var enemies = collision_area.get_overlapping_bodies()
	var closest_enemy = null
	var closest_enemy_dist = 100000
	for enemy in enemies:
		var curr_dist = global_position.distance_to(enemy.global_position)
		if closest_enemy == null:
			closest_enemy = enemy
			closest_enemy_dist = curr_dist
		if curr_dist < closest_enemy_dist:
			closest_enemy = enemy
			closest_enemy_dist = curr_dist
	if closest_enemy and is_instance_valid(closest_enemy):
		target = closest_enemy
		shoot_timer.start(turret_fire_rate)


func _on_ShootTimer_timeout():
	if !target or !is_instance_valid(target):
		shoot_timer.stop()
		return
	else:
		shoot()
