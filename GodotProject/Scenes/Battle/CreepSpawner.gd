extends StaticBody2D

export var num_creeps_per_wave : int = 5
var creep = load("res://Scenes/Enemies/Creep.tscn")
var creeps_spawned_this_wave : int = 0
#var current_wave_wayfinder
export var time_between_creeps = 1.2 # rand jitter will be applied later.
export var time_between_waves = 20.0 # rand jitter will be applied later.

export var max_health : float = 200.0
var health : float = max_health

export (PackedScene) var dropped_pickable

enum States { INITIALIZING, READY, INVUNERABLE, DEAD }
var State = States.READY

signal creep_spawned(creep, location)
signal wave_started(location)
signal died(location)
signal damaged(location)

# Called when the node enters the scene tree for the first time.
func _ready():
	# make the spawn timers have a bit of variation, so player doesn't get 3 waves simultaneously
	$WaveTimer.set_wait_time($WaveTimer.get_wait_time() * rand_range(0.8, 1.2))
	$WaveTimer.start()
	if creep == null:
		creep = load("res://Scenes/Enemies/Creep.tscn")

	var _err = connect("wave_started", Global.player.hud, "_on_creep_wave_started")
	_err = connect("died", Global.pickable_object_spawner, "_on_spawner_died")
	_err = connect("damaged", Global.pickable_object_spawner, "_on_spawner_hit")

func init(location):
	set_global_position(location)


func spawn_creep():
	if Global.current_map == null or is_instance_valid(Global.current_map) == false:
		return
	
	#print("spawning creep")
	if get_tree().get_nodes_in_group("enemies").size() > Global.max_enemies:
		return
	
	var newCreep = creep.instance()
	creeps_spawned_this_wave += 1
	$NewCreepNoise.play()


	if Global.current_map.has_method("_on_creep_spawn_requested"):
		if not is_connected("creep_spawned", Global.current_map, "_on_creep_spawn_requested"):
			var _err = connect("creep_spawned", Global.current_map, "_on_creep_spawn_requested")
		emit_signal("creep_spawned", newCreep)
	else: # dumb map: just add the creep yourself.
		Global.current_map.find_node("YSort").add_child(newCreep)
		newCreep.init(global_position)

	
	if creeps_spawned_this_wave >= num_creeps_per_wave:
		$WaveTimer.set_wait_time(rand_range(time_between_waves* 0.75, time_between_waves* 1.25))
		$WaveTimer.start() # wait a bit before the next set of creeps
	else:
		$SpawnTimer.set_wait_time(rand_range(time_between_creeps*0.75, time_between_creeps*1.25))
		$SpawnTimer.start() # short delay before launching another crepep




#func spawn_creep_wayfinder():
#	var navTargetScene = preload("res://Scenes/Enemies/CreepWayfinder.tscn")
#	var navTarget = navTargetScene.instance()
#
#	navTarget.init(Global.village_location)
#	Global.current_map.add_child(navTarget)
#	navTarget.set_global_position(self.global_position)
#	current_wave_wayfinder = navTarget


func begin_dying():
	State = States.DEAD
	$HealthBar.hide()
	$DeathTimer.start()
	$CollisionShape2D.set_deferred("disabled", true)
#	emit_signal("died", self, dropped_pickable, global_position)
	

func _on_WaveTimer_timeout():
	if State == States.READY:
#		spawn_creep_wayfinder()

		# modify this later to accommodate game progression
		num_creeps_per_wave = randi()%3 + 5 # 3 to 8 creeps per wave
		spawn_creep()
		$SpawnTimer.start()
		emit_signal("wave_started", global_position)


func start_wave_now(): # accelerated start
	$SpawnTimer.stop()
	_on_WaveTimer_timeout()

	

func _on_SpawnTimer_timeout():
	if State == States.READY:
		spawn_creep() # timer gets restarted inside spawn_creep() method

func show_damage():
	$HealthBar.value = health/max_health
	#var newFrame = int(1.0-(min(health/max_health,1.0)) * 3.0) # should be 0 to 3 with 0 being max health
	var newFrame = min(3, 4 - (health/max_health * 4.0))
	$Sprite.set_frame(newFrame)


func _on_hit(damage, _impactVector, _damageAttributes):
	if State == States.READY:
		health -= damage
		$ImpactParticles.emitting = true
		show_damage()
		
#		if randf()<0.33: # was getting too much loot out of a rift, so reduced the likelihood.
#			emit_signal("damaged", self, dropped_pickable, position)
		if health <= 0:
			begin_dying()
		else:
			State = States.INVUNERABLE
			$InvulnTimer.start()
	
	



func _on_DeathTimer_timeout():
	$corpse.show()
	$Sprite.hide()
	
	


func _on_InvulnTimer_timeout():
	State = States.READY
