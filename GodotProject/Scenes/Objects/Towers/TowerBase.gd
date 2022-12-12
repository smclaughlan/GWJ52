extends StaticBody2D

var tower_turret_scene = load("res://Scenes/Objects/Towers/TowerTurret.tscn")
onready var collision_polygon_2d = $CollisionPolygon2D
onready var remove_mark_decon_timer = $RemoveMarkDeconTimer
var turret


export var cost: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	cut_from_nav()


func init(turret_type):
	var new_turret = tower_turret_scene.instance()
	new_turret.global_position = global_position
	if Global.current_map.has_node("Towers"):
		Global.current_map.get_node("Towers").add_child(new_turret)
		new_turret.global_position = global_position
	else:
		Global.current_map.add_child(new_turret)
	var default_turret_range = 30
	new_turret.init(turret_type, default_turret_range)
	turret = new_turret

func mark_for_deconstruction():
	modulate = Color(1, 1, 1, 0.5)
	turret.modulate = Color(1, 1, 1, 0.5)
	remove_mark_decon_timer.start()

func destroy():
	# Later add the animation, etc.
	turret.queue_free()
	queue_free()


func cut_from_nav():
	Global.nav_manager.cut_from_nav(collision_polygon_2d)


func _on_RemoveMarkDeconTimer_timeout():
	modulate = Color(1, 1, 1, 1)
	turret.modulate = Color(1, 1, 1, 1)
