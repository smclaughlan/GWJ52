# show a visual representation of a tower on the ground.
# semi-transparent blueprint so the player can see what they're about to place.
# Note: This is viz only. tower spawning is handled elsewhere.

extends Node2D

var can_place = true
var player
export var MAX_PLACEMENT_RANGE = 300.0
onready var build_area = $Area2D
#onready var green_sprite = $GreenSprite
#onready var red_sprite = $RedSprite

var current_blueprint_sprite : Sprite

var tower_type : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_tower_type(towerType):
	tower_type = towerType
	var towerTypeName = Global.TowerTypes.keys()[towerType]
	for sprite in $TowerTypes.get_children():
		sprite.visible = false
	current_blueprint_sprite = $TowerTypes.get_node(towerTypeName)
	current_blueprint_sprite.visible = true

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
			if current_blueprint_sprite != null and is_instance_valid(current_blueprint_sprite):
				current_blueprint_sprite.set_self_modulate(Color.red)
			#green_sprite.hide()
			#red_sprite.show()
		else:
			can_place = true
			if current_blueprint_sprite != null and is_instance_valid(current_blueprint_sprite):
				current_blueprint_sprite.set_self_modulate(Color.greenyellow)
#			green_sprite.show()
#			red_sprite.hide()

func store_player(_player):
	player = _player
