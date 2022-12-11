extends Node2D

var tower_turret_scene = load("res://Scenes/Objects/Towers/TowerTurret.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(turret_type):
	var new_turret = tower_turret_scene.instance()
	new_turret.global_position = global_position
	Global.current_map.add_child(new_turret)
	var default_turret_range = 30
	new_turret.init(turret_type, default_turret_range)
