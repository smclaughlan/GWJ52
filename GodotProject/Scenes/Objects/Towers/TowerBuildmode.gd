# show a visual representation of a tower on the ground.
# semi-transparent blueprint so the player can see what they're about to place.
# Note: This is viz only. tower spawning is handled elsewhere.

extends Node2D

var can_place = true
var player
export var MAX_PLACEMENT_RANGE = 800.0
export var MIN_DISTANCE_BETWEEN_TOWERS = 150.0

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

func move_blueprint_to_mouse_position_on_grid():
	var new_position = get_global_mouse_position()
	if new_position == null:
		return
	new_position.x = stepify(new_position.x, Global.grid_dist_px)
	new_position.y = stepify(new_position.y, Global.grid_dist_px)
	set_global_position(new_position)

func safe_placement_location():
	var safe_placement_location = true

	if on_another_tower():
		safe_placement_location = false
	if on_player():
		safe_placement_location = false
	if exceeds_maximum_distance():
		safe_placement_location = false
	if outside_map_extents():
		safe_placement_location = false

	return safe_placement_location

func on_player():
	var body_collisions = build_area.get_overlapping_bodies()
	if body_collisions.has(Global.player):
		return true
	else:
		return false
		

func on_another_tower():
	var location_already_occupied = false
	var towers = get_tree().get_nodes_in_group("towers")
	var closest_tower = Global.get_closest_object(towers, self)
	if closest_tower != null:
		var proximity = global_position.distance_squared_to(closest_tower.global_position)
		if proximity < MIN_DISTANCE_BETWEEN_TOWERS * MIN_DISTANCE_BETWEEN_TOWERS:
			location_already_occupied = true
	return location_already_occupied


func exceeds_maximum_distance():
	var distance_sq = global_position.distance_squared_to(get_global_mouse_position())
	if distance_sq > MAX_PLACEMENT_RANGE * MAX_PLACEMENT_RANGE:
		return true
	else:
		return false

func outside_map_extents():
	# hard code this for now, but a dynamic solution is preferable.
	if ( 
			global_position.x < 4358
			and global_position.x > -4211
			and global_position.y < 2680
			and global_position.y > -2497
	):
		return false
	else:
		return true

func _physics_process(_delta):
	if self != null and is_instance_valid(self):
		move_blueprint_to_mouse_position_on_grid()
		if safe_placement_location() == true:
			change_blueprint_color(Color.greenyellow)
			can_place = true
		else:
			can_place = false
			change_blueprint_color(Color.red)
		

func change_blueprint_color(newColor):
	if current_blueprint_sprite != null and is_instance_valid(current_blueprint_sprite):
		current_blueprint_sprite.set_self_modulate(newColor)


func store_player(_player):
	player = _player
