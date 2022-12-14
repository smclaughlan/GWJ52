class_name WaveManager
extends Node
# Manages the spawning of spawners. Stores the number of enemies to be spawned
# by spawners.

# Number of creeps to be spawned
export var spawn_amount: int = 0

var creep = preload("res://Scenes/Enemies/Creep.tscn")
