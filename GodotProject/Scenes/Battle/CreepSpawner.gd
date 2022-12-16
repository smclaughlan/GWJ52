class_name CreepSpawner
extends StaticBody2D

#export var num_creeps_per_wave : int = 5
export var creep : PackedScene
var current_wave_wayfinder

export var max_health : float = 200.0
var health : float = max_health

enum States { INITIALIZING, READY, DEAD }
var State = States.READY

signal creep_spawned(creep, location)



# Called when the node enters the scene tree for the first time.
func _ready():
	# connect to WaveManager
	connect("creep_spawned", Global.wave_manager, "_on_creep_spawned")
	# make the spawn timers have a bit of variation, so player doesn't get 3 waves simultaneously
	$WaveTimer.set_wait_time($WaveTimer.get_wait_time() * rand_range(0.8, 1.2))
	$WaveTimer.start()
	if creep == null:
		creep = load("res://Scenes/Enemies/Creep.tscn")




func spawn_creep():

	var newCreep = creep.instance()
	newCreep.init(global_position, current_wave_wayfinder)
	$NewCreepNoise.play()


	if Global.current_map.has_method("_on_creep_spawn_requested"):
		if not is_connected("creep_spawned", Global.current_map, "_on_creep_spawn_requested"):
			var _err = connect("creep_spawned", Global.current_map, "_on_creep_spawn_requested")
	else: # dumb map: just add the creep yourself.
		Global.current_map.add_child(newCreep)

	
	$SpawnTimer.start()
	emit_signal("creep_spawned", newCreep)




func spawn_creep_wayfinder():
	var navTargetScene = preload("res://Scenes/Enemies/CreepWayfinder.tscn")
	var navTarget = navTargetScene.instance()
	navTarget.init(Global.village_location)
	Global.current_map.add_child(navTarget)
	current_wave_wayfinder = navTarget


func begin_dying():
	State = States.DEAD
	$HealthBar.hide()
	$DeathTimer.start()
	$CollisionShape2D.set_deferred("disabled", true)
	

func _on_WaveTimer_timeout():
	if State == States.READY:
		spawn_creep_wayfinder()

		# modify this later to accommodate game progression
		#num_creeps_per_wave = randi()%3 + 5 # 3 to 8 creeps per wave

		$SpawnTimer.start()


func _on_SpawnTimer_timeout():
	if State == States.READY:
		spawn_creep()

func _on_hit(damage, _impactVector, _damageAttributes):
	health -= damage
	$HealthBar.value = health/max_health
	if health <= 0:
		begin_dying()



func _on_DeathTimer_timeout():
	$corpse.show()
	$Sprite.hide()
	$DecayTimer.start()


func _on_DecayTimer_timeout() -> void:
	queue_free()


func pause_spawning(value: bool) -> void:
	if value == true:
		$SpawnTimer.stop()
		print("Pausing timer")
	else:
		$SpawnTimer.start()
		print("Resume")
