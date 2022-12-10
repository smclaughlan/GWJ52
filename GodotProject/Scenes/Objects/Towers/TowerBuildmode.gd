extends Node2D

var can_place = true
var player
export var MAX_PLACEMENT_RANGE = 300.0
onready var build_area = $Area2D
onready var visual = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	
	set_global_position(get_global_mouse_position())
	
	# If the player is too far away, can't place.
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check for any collisions. If any found, turn red, can't place.
	var area_collisions = build_area.get_overlapping_areas()
	var body_collisions = build_area.get_overlapping_bodies()
	
	if distance_to_player > MAX_PLACEMENT_RANGE or area_collisions.size() > 0 or body_collisions.size() > 0:
		can_place = false
		visual.self_modulate = Color(1, .1, .1, .5)
	else:
		can_place = true
		visual.self_modulate = Color(1, 1, 1, .5)

func store_player(_player):
	player = _player
