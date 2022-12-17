extends Node2D

var debug_viz = load("res://Scenes/Enemies/debug/pathfindViz.tscn")
export(NodePath) onready var tween = get_node(tween)
onready var path_area = $PathArea
onready var nodes = Global.pathfinding_manager.nodes
onready var colliding_nodes = Global.pathfinding_manager.colliding_nodes
onready var player_colliding_nodes = Global.pathfinding_manager.player_colliding_nodes
# List of positions to move to.
var path = []
var offset = 10
var queue = []
var seen = {}
var target

enum States {FINDING_TARGET, START_FINDING_PATH, FINDING_PATH, DONE}
var State = States.FINDING_TARGET

func _ready():
	# Connect signal from pathfinding_manager so pathfinding restarts when something is placed
	# and the navmesh has been rebuilt.
	Global.pathfinding_manager.connect("restart_pathfinding", self, "start_restart_timer")
	Global.pathfinding_manager.connect("restart_player_pathfinding", self, "update_player_pathfinding")
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
		for i in 40:
			next_step()


func find_target():
	var nearest = null
	var lowest_dist = 99999999999999
	var potential_targets = []
	var towers = get_tree().get_nodes_in_group("towers")
	var village_stuff = get_tree().get_nodes_in_group("village")
	if towers != null:
		potential_targets.append_array(towers)
	if village_stuff != null:
		potential_targets.append_array(village_stuff)
	for potential_target in potential_targets:
		if potential_target.has_method("get_health") and potential_target.get_health() <= 0:
			continue
		var curr_dist = global_position.distance_to(potential_target.global_position)
		if curr_dist < lowest_dist:
			lowest_dist = curr_dist
			nearest = potential_target
	target = nearest
	if target != null and is_instance_valid(target):
		State = States.START_FINDING_PATH
		get_parent().target = target


func find_path():
	path = []
	queue = []
	seen = {}
	# Find path by:
	# * Put the start position at the nearest node on the navmesh. 
	#		The first position in the path will always be there.
	# Need to find the closest node but without iterating.
	# Stepify the global_position instead.
	var stepify_offset = Global.pathfinding_manager.offset
	var global_stepified = Vector2(stepify(global_position.x, stepify_offset), stepify(global_position.y, stepify_offset))
	
	queue = [
			[global_stepified], # [[path_array], [path_array]]
		]
	State = States.FINDING_PATH


func next_step():
	var curr_path_arr = queue.pop_front()
	if curr_path_arr == null:
		return
	if curr_path_arr.size() > 100000:
		# TODO Find a different target??
		queue = []
		State = States.DONE

	var last_path_position = curr_path_arr[curr_path_arr.size() - 1]
#	debug_path_viz(str_to_vector2(last_path_position))
	# BFS through nodes using their neighbors to move outward.
	#	If colliding_nodes has any neighbor nodes w/ target, that's our path.
	#	If neighbor nodes are in colliding_nodes, skip them.
	#	Add the other non-colliding nodes to the queue.
	var neighbors = nodes.get(last_path_position)
	if neighbors == null:
		return
	for neighbor in neighbors:
		# Check if this is the target we're looking for.
		var all_colliders = []
		var colliders = colliding_nodes.get(neighbor)
		var player_colliders = player_colliding_nodes.get(neighbor)
		if colliders != null:
			all_colliders.append_array(colliders)
		if player_colliders != null:
			all_colliders.append_array(player_colliders)
#		print('looking for target:', target)
		if all_colliders.has(target):
			path = curr_path_arr
			State = States.DONE
		
		if all_colliders.size() == 0:
			add_to_queue(curr_path_arr, neighbor)


func add_to_queue(curr_path_arr, neighbor):
	if seen.has(neighbor):
		return
	seen[neighbor] = true
	var new_path_arr = curr_path_arr.duplicate()
	new_path_arr.append(neighbor)
	queue.append(new_path_arr)

#
#func str_to_vector2(strVec):
#	# Remove the "Vector2(" and ")" characters from the string
#	var string = strVec.replace("(", "").replace(")", "")
#
#	# Split the string on the "," character to get the x and y components
#	var components = string.split(",")
#
#	# Convert the x and y components into float values
#	var x = float(components[0])
#	var y = float(components[1])
#
#	# Return the Vector2
#	return Vector2(x, y)


func start_restart_timer(_nodes, _colliding_nodes):
	nodes = _nodes
	colliding_nodes = _colliding_nodes
	$RestartTimer.start(rand_range(0.1, 0.3))


func restart_pathfinding():
	$RestartTimer.start(rand_range(0.1, 0.3))


func _restart_pathfinding():
	$RestartTimer.stop()
#	print("restarting pathfinding on enemy")
	find_target()
	State = States.FINDING_TARGET


func update_player_pathfinding(_player_colliding_nodes):
	if target != Global.player:
		return
	player_colliding_nodes = _player_colliding_nodes
#	print("player colliding nodes:", player_colliding_nodes)
	State = States.FINDING_PATH

func debug_path_viz(position : Vector2):
	var new_viz = debug_viz.instance()
	new_viz.global_position = position
	Global.current_map.find_node("YSort").add_child(new_viz)


func _on_FindTargetTimer_timeout():
	if target == null:
		State = States.FINDING_TARGET


func _on_CheckTargetDeadTimer_timeout():
	if target == null or !is_instance_valid(target):
		find_target()
	if target != null and target.has_method("get_health") and target.get_health() <= 0:
		find_target()
