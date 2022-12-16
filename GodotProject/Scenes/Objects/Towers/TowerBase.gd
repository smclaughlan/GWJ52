extends Node2D

var tower_turret_scene # set during init
onready var remove_mark_decon_timer = $RemoveMarkDeconTimer
var turret

var max_health = 200
var health = max_health 

var TowerTypes = Global.TowerTypes
var tower_type : int

var turret_scenes = [
	"res://Scenes/Objects/Towers/BEAMTurret.tscn",
	"res://Scenes/Objects/Towers/AOETurret.tscn",
	"res://Scenes/Objects/Towers/GLUETurret.tscn",
]

export var cost: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.pathfinding_manager.rebuild_collisions()


func init(turret_type):
	spawn_turret(turret_type)


func spawn_turret(turret_type):
	tower_turret_scene = load(turret_scenes[turret_type])
	var new_turret = tower_turret_scene.instance()
	new_turret.global_position = global_position
	if Global.current_map.has_node("Towers"):
		Global.current_map.get_node("Towers").add_child(new_turret)
		new_turret.global_position = global_position
	else:
		Global.current_map.add_child(new_turret)
	new_turret.init(turret_type, self)
	turret = new_turret

func mark_for_deconstruction():
	modulate = Color(1, 1, 1, 0.5)
	turret.modulate = Color(1, 1, 1, 0.5)
	remove_mark_decon_timer.start()

func destroy():
	# Later add the animation, etc.
	turret._on_base_destroyed() # should propagate to the WireSockets as well.
	#turret.queue_free()
	queue_free()


func _on_RemoveMarkDeconTimer_timeout():
	modulate = Color(1, 1, 1, 1)
	turret.modulate = Color(1, 1, 1, 1)


func _on_demolition_requested(): # from InteractArea probably
	destroy()

func _on_upgrade_requested(upgrade_type): # [bigger, stronger, faster]
	turret.upgrade(upgrade_type)

func _on_hit(damage, _impactVector, _damageAttributes):
	health -= damage
	if health <= 0:
		# might want better animations
		destroy()
		
	
