extends StaticBody2D

export var num_spawners_per_wave : int = 5
export var spawner : PackedScene
var spawners_spawned_this_wave : int = 0
#var current_wave_wayfinder
var time_between_spawners = 1.2 # rand jitter will be applied later.
var time_between_spawner_waves = 20.0 # rand jitter will be applied later.

export var max_health : float = 200000.0
var health : float = max_health

enum States { INITIALIZING, READY, DEAD }
var State = States.READY

var current_wave_number : int = 0
 
signal spawner_spawned(spawner, location)



func _ready():
	#$WaveTimer.set_wait_time(time_between_spawner_waves * rand_range(0.8, 1.2))
	#$WaveTimer.start()
	if spawner == null:
		spawner = load("res://Scenes/Battle/CreepSpawner.tscn")

func enable():
	visible = true
	$WaveTimer.set_wait_time(time_between_spawner_waves * rand_range(0.8, 1.2))
	#$WaveTimer.start()
	start_wave_now()


func get_random_location():
	# point toward the village, then rotate within 90 degrees, find a random distance
	var vecTowardVillage = Global.village_location - global_position
	var magnitude = rand_range(0.01, 0.25)
	var slop = rand_range(-PI/4, PI/4)
	
	return global_position + (vecTowardVillage*magnitude).rotated(slop)


func spawn_spawner():

	var newSpawner = spawner.instance()
	var spawnerPos = get_random_location()
	newSpawner.init(spawnerPos)
	spawners_spawned_this_wave += 1
	$NewSpawnerNoise.play()


	if Global.current_map.has_method("_on_spawner_spawn_requested"):
		if not is_connected("spawner_spawned", Global.current_map, "_on_spawner_spawn_requested"):
			var _err = connect("spawner_spawned", Global.current_map, "_on_spawner_spawn_requested")
		emit_signal("spawner_spawned", newSpawner)
	else: # dumb map: just add the spawner yourself.
		Global.current_map.add_child(newSpawner)

	
	if spawners_spawned_this_wave >= num_spawners_per_wave:
		$WaveTimer.set_wait_time(rand_range(time_between_spawner_waves* 0.75, time_between_spawner_waves* 1.25))
		$WaveTimer.start() # wait a bit before the next set of creeps
	else:
		$SpawnTimer.set_wait_time(rand_range(time_between_spawners*0.75, time_between_spawners*1.25))
		$SpawnTimer.start() # short delay before launching another crepep




func begin_dying(): # could happen. Definitely needs a win condition.
	State = States.DEAD
	$HealthBar.hide()
	$DeathTimer.start()
	$CollisionShape2D.set_deferred("disabled", true)
	

func _on_WaveTimer_timeout():
	if State == States.READY:
		current_wave_number += 1
		# modify this later to accommodate game progression
		
		var chance_to_increase_difficulty = 0.2
		if randf()<chance_to_increase_difficulty:
			num_spawners_per_wave += 1
			time_between_spawner_waves = time_between_spawner_waves * 0.95
			num_spawners_per_wave += randi()%2

		if State == States.READY:
			spawn_spawner()
		$SpawnTimer.start()


func start_wave_now(): # accelerated start
	$WaveTimer.stop()
	_on_WaveTimer_timeout()


func _on_SpawnTimer_timeout():
	if State == States.READY:
		spawn_spawner() # timer gets restarted inside spawn_creep() method



func _on_hit(damage, _impactVector, _damageAttributes):
	health -= damage
	$HealthBar.value = health/max_health
	if health <= 0:
		begin_dying()



func _on_DeathTimer_timeout():
	$corpse.show()
	$Sprite.hide()
	
	
