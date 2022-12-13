extends Node2D

var debug_viz = load("res://Scenes/Enemies/debug/pathfindViz.tscn")
export(NodePath) onready var tween = get_node(tween)
onready var path_area = $PathArea
# List of positions to move to.
var path = []
var offset = 30
var queue = []
var seen = {}
var target

enum States {FINDING_TARGET, START_FINDING_PATH, FINDING_PATH, DONE}
var State = States.FINDING_TARGET

var directions = [
	Vector2(0, -offset), # up
	Vector2(-offset, -offset), #upleft
	Vector2(offset, -offset), # upright
	Vector2(0, offset), # down
	Vector2(-offset, offset), # downleft
	Vector2(offset, offset), # downright
	Vector2(-offset, 0), # left
	Vector2(offset, 0) # right
]
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.DONE:
		return
	elif State == States.FINDING_TARGET:
		find_target()
	elif State == States.START_FINDING_PATH:
		find_path()
	elif State == States.FINDING_PATH:
		next_step()


func get_tower_collider_position(tower):
	return Vector2(tower.global_position.x, tower.global_position.y + 60)


func find_target():
	var nearest = null
	var lowest_dist = 99999999999999
	for tower in get_tree().get_nodes_in_group("towers"):
		var curr_dist = global_position.distance_to(get_tower_collider_position(tower))
		if curr_dist < lowest_dist:
			lowest_dist = curr_dist
			nearest = tower
	target = nearest
	if target != null and is_instance_valid(target):
#		print("found target: ", target)
		State = States.START_FINDING_PATH


func find_path():
	# Find path by:
	# * Move the path_area around using the directions.
	# * Fill queue arrays up to a limited amount of iterations.
	# * If the path_area overlaps with a collider, set that path_array as path.
	var start_position = get_parent().global_position
	queue = [
			[0, [start_position]], # [num_of_iterations_so_far, [path_array]]
		]
	State = States.FINDING_PATH


func next_step():
	# Do the next step in the pathfinding.
	var curr_queue_item = queue.pop_front()
	if curr_queue_item == null:
		State = States.DONE
		return
	var curr_iterations = curr_queue_item.pop_front()
	var curr_path_arr = curr_queue_item.pop_front()
	if curr_iterations > 10000000:
		queue = []
		State = States.DONE
	
	# If the current last position of curr_path_arr is overlapping, make that the path.
	var last_path_position = curr_path_arr[curr_path_arr.size() - 1]
	# Put the vector into seen so we can skip creating new points there.
	seen[String(last_path_position)] = true
	debug_path_viz(last_path_position)
#		print("last_path_position:", last_path_position)
	path_area.global_position = last_path_position
	var overlapping_areas = path_area.get_overlapping_areas()
	var overlapping_bodies = path_area.get_overlapping_bodies()
	for area in overlapping_areas:
		if area:
			path = curr_path_arr
			State = States.DONE
			print("overlapping area: ", area)
			print("path found: ", path)
			break
	
	for body in overlapping_bodies:
		if body:
			path = curr_path_arr
			State = States.DONE
			print("overlapping body: ", body)
			print("path found: ", path)
			break
	
	# Take last_path_position from curr_path_arr and move it to the different directions.
	# Create a new_path_arr.
	curr_iterations += 1
	# if there isn't a collision, we can just go directly toward the target
	var is_collision_on_any_direction = directions_have_collision(last_path_position, directions)
	if !is_collision_on_any_direction:
		# Pick the closest direction and only add that to queue.
		var closest_dir = null
		var closest_dist = 999999999999
		for direction in directions:
			var new_pos = last_path_position + direction
			var curr_dist = new_pos.distance_to(get_tower_collider_position(target))
			if curr_dist < closest_dist:
				closest_dist = curr_dist
				closest_dir = direction
		add_to_queue(curr_iterations, curr_path_arr, last_path_position, closest_dir)
	else:
		print("collision detected")
		for direction in directions:
			add_to_queue(curr_iterations, curr_path_arr, last_path_position, direction)


func add_to_queue(curr_iterations, curr_path_arr, last_path_position, direction):
	var new_path_arr = curr_path_arr.duplicate()
	var new_direction = last_path_position + direction
	if !seen.has(String(new_direction)):
		new_path_arr.append(last_path_position + direction)
		queue.append([curr_iterations, new_path_arr])


func directions_have_collision(last_position, directions):
	for direction in directions:
		var new_pos = last_position + direction
		path_area.global_position = new_pos
		var overlapping_areas = path_area.get_overlapping_areas()
		var overlapping_bodies = path_area.get_overlapping_bodies()
		if overlapping_areas.size() > 0 or overlapping_bodies.size() > 0:
			return true
	return false

func debug_path_viz(position : Vector2):
	var new_viz = debug_viz.instance()
	new_viz.global_position = position
	Global.current_map.add_child(new_viz)
