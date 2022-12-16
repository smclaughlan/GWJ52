class_name WaveManager
extends Node2D
# Manages the spawning of spawners. Stores the number of enemies to be spawned
# by spawners.
signal wave_ended

const MIN_NUMBER:int = 10
const MAX_NUMBER:int = 20
# Number of creeps to be spawned
export var spawn_amount: int = 0
export var minimum_spawners: int = 3

var creep = preload("res://Scenes/Enemies/Creep.tscn")
var spawner = preload("res://Scenes/Battle/CreepSpawner.tscn")
# Array that can be used to track if the wave is empty.
var creep_array: Array = []
var _current_wave: int = 0

func _ready() -> void:
	randomize()
	connect("wave_ended", self, "_on_wave_ended")
	Global.wave_manager = self
	#prepare_new_wave()


func prepare_new_wave() -> void:
	var current_number_of_spawners: = _get_spawner_children().size()
	var is_less_than_minimum_spawners: bool = current_number_of_spawners < minimum_spawners
	# Increase current wave
	_current_wave += 1
	# Generate a random number of spawns
	spawn_amount = rand_range(MIN_NUMBER, MAX_NUMBER)
	# Check the number of children spawners.
	if is_less_than_minimum_spawners:
		create_spawners(minimum_spawners - current_number_of_spawners)
	_pause_spawning(false)
	
	


func create_spawners(number: int = 1) -> void:
	for n in number:
		# Distance from the position
		var distance := 1300
		# Create a random vector
		var randomized_vector: Vector2 = _generate_random_vector(distance)
		var spawn_position : Vector2 = randomized_vector
		instance_spawners(spawn_position)
		


func _generate_random_vector(distance: int) -> Vector2:
	var _vector: Vector2
	var angle = rand_range(0.0, 2 * PI)
	
	_vector.x = distance * cos(angle)
	_vector.y = distance * sin(angle)
	
	return _vector


func instance_spawners(target_position: Vector2) -> void:
	var new_spawner = spawner.instance()
	new_spawner.position = target_position
	add_child(new_spawner)


func _get_spawner_children() -> Array:
	var children: Array = []
	for n in get_children():
		if n is CreepSpawner:
			children.append(n)
	return children


func _on_creep_spawned(_creep: Object) -> void:
	creep_array.append(_creep)
	spawn_amount -= 1
	if spawn_amount <= 0:
		spawn_amount = 0
		_pause_spawning(true)
		


func _on_creep_died(_creep: Object) -> void:
	if _creep in creep_array:
		creep_array.erase(_creep)
		if creep_array.empty():
			emit_signal("wave_ended")
			print("Wave ended")


func _on_wave_ended() -> void:
	$NewWaveWaitTime.start()


func _on_NewWaveWaitTime_timeout() -> void:
	prepare_new_wave()


func _pause_spawning(value: bool) -> void:
	if _get_spawner_children().empty():
		return
	for _spawner in _get_spawner_children():
		_spawner.pause_spawning(value)
