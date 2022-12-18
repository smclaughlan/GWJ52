extends Node2D

var enemy_projectile_scene = load("res://Scenes/Enemies/Projectile/EnemyProjectile.tscn")
onready var projectile_spawn_timer = $ProjectileSpawnTimer
onready var check_for_spawn_timer = $CheckForSpawnTimer
export var range_to_attack_player = 800
export var min_attack_time = 2
export var max_attack_time = 8


func _on_CheckForSpawnTimer_timeout():
	# See if we're close enough to attack the player.
	# If so, start a timer to release the attack.
	if !projectile_spawn_timer.is_stopped():
		return
	var dist_to_player = global_position.distance_to(Global.player.global_position)
	if dist_to_player < range_to_attack_player:
		projectile_spawn_timer.start(rand_range(min_attack_time, max_attack_time))


func _on_ProjectileSpawnTimer_timeout():
	# Spawn the enemy projectile.
	# Only if our enemy is alive, and the player is alive too.
	projectile_spawn_timer.stop()
	if get_parent().health <= 0 or Global.player.health <= 0:
		return
	
	var new_projectile = enemy_projectile_scene.instance()
	new_projectile.global_position = global_position
	Global.current_map.find_node("YSort").add_child(new_projectile)
