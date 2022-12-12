extends Node2D

var can_place = true
var player
export var MAX_PLACEMENT_RANGE = 300.0
onready var build_area = $Area2D
onready var green_sprite = $GreenSprite
onready var red_sprite = $RedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if self != null and is_instance_valid(self):
		var new_position = get_global_mouse_position()
		if new_position == null:
			return

		new_position.x = stepify(new_position.x, Global.grid_dist_px)
		new_position.y = stepify(new_position.y, Global.grid_dist_px)
		set_global_position(new_position)

		# If the player is too far away, can't place.
		var distance_to_player = global_position.distance_to(Global.player.global_position)

		# Check for any collisions. If any found, turn red, can't place.
		var area_collisions = build_area.get_overlapping_areas()
		var body_collisions = build_area.get_overlapping_bodies()

		if distance_to_player > MAX_PLACEMENT_RANGE or area_collisions.size() > 0 or body_collisions.size() > 0:
			can_place = false
			green_sprite.hide()
			red_sprite.show()
		else:
			can_place = true
			green_sprite.show()
			red_sprite.hide()

func store_player(_player):
	player = _player
