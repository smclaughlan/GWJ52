extends Node2D

export var num_creeps_per_wave : int = 5
export var creep : PackedScene
var creeps_spawned_this_wave : int = 0
var current_wave_wayfinder

signal creep_spawned(creep, location)

# Called when the node enters the scene tree for the first time.
func _ready():
	if creep == null:
		creep = load("res://Scenes/Enemies/Creep.tscn")




func spawn_creep():

	var newCreep = creep.instance()
	newCreep.init(global_position, current_wave_wayfinder)
	creeps_spawned_this_wave += 1
	$NewCreepNoise.play()


	if Global.current_map.has_method("_on_creep_spawn_requested"):
		if not is_connected("creep_spawned", Global.current_map, "_on_creep_spawn_requested"):
			var _err = connect("creep_spawned", Global.current_map, "_on_creep_spawn_requested")
		emit_signal("creep_spawned", newCreep)
	else: # dumb map: just add the creep yourself.
		Global.current_map.add_child(newCreep)

	
	if creeps_spawned_this_wave >= num_creeps_per_wave:
		$WaveTimer.start() # wait a bit before the next set of creeps
	else:
		$SpawnTimer.start() # short delay before launching another crepep




func spawn_creep_wayfinder():
	var navTargetScene = preload("res://Scenes/Enemies/CreepWave.tscn")
	var navTarget = navTargetScene.instance()
	Global.current_map.add_child(navTarget)
	current_wave_wayfinder = navTarget


func _on_WaveTimer_timeout():
	spawn_creep_wayfinder()
	$SpawnTimer.start()


func _on_SpawnTimer_timeout():
	spawn_creep()
