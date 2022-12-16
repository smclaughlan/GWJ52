# Nodes will not be placed anywhere where the path area collides.
# To use the nodes, we'll BFS through them. 

extends Node2D

var debug_viz = load("res://Scenes/Enemies/debug/pathfindViz.tscn")

var navmesh_done = false
var offset = 40
var max_iterations
	# will look like this, key with an array list of neighboring positions to move to.
	# (0, 0) : [(1, 1), (0, 1), ...] 
var nodes = {}
	# this will let us put colliding_node[vector] and detect collisions
	# (0, 0): [Tower:1234] 
var colliding_nodes = {}
var player_colliding_nodes = {}
var shapes = {}
var queue = []

signal restart_pathfinding
signal restart_player_pathfinding


var directions = [
	Vector2(0, -offset), # up
	Vector2(0, offset), # down
	Vector2(-offset, 0), # left
	Vector2(offset, 0), # right
	Vector2(-offset, offset), # downleft
	Vector2(offset, offset), # downright
	Vector2(-offset, -offset), #upleft
	Vector2(offset, -offset) # upright
]


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create nodes for searching later.
	Global.pathfinding_manager = self
	queue = [Vector2.ZERO]
	max_iterations = 50000
	create_nodes()
	
func _process(delta):
	if navmesh_done == true:
		return
	if max_iterations <= 0:
#		print("nodes", nodes)
#		print("colliding_nodes", colliding_nodes)
		navmesh_done = true
		# signal all pathfinders to restart pathfinding
		emit_signal("restart_pathfinding", nodes, colliding_nodes)
		return
	
	for i in 200:
		create_nodes()


func create_nodes():
	# Get the first node from the queue.
	# If we've already done max iterations, exit early.
	if max_iterations <= 0:
		return
	
	var curr_vec = queue.pop_front()
	# Create an array for the vector if not there already.
	if !nodes.has(curr_vec):
		# Let's also keep track of anything colliding with this node.
		# I tried to use a collider, but that won't work.
		
		# Get all objects we want to check for collisions with.
#		debug_path_viz(curr_vec)
		for obstacle in get_tree().get_nodes_in_group("obstacles"):
			var shape = obstacle.get_node("PathfindingObstacle/CollisionPolygon2D").get_polygon()
			var new_shape = []
			for vector in shape:
				new_shape.append(obstacle.global_position + vector)
			
			var maxX = max(new_shape[0].x, max(new_shape[1].x, max(new_shape[2].x, new_shape[3].x)))
			var minX = min(new_shape[0].x, min(new_shape[1].x, min(new_shape[2].x, new_shape[3].x)))
			var maxY = max(new_shape[0].y, max(new_shape[1].y, max(new_shape[2].y, new_shape[3].y)))
			var minY = min(new_shape[0].y, min(new_shape[1].y, min(new_shape[2].y, new_shape[3].y)))
			
			# If the curr_vec.x is > minX and < maxX, while vec.y is > minY and < maxY
			# it's inside and colliding
			if curr_vec.x > minX and curr_vec.x < maxX and curr_vec.y > minY and curr_vec.y < maxY:
				if !colliding_nodes.has(curr_vec):
					colliding_nodes[curr_vec] = []
				colliding_nodes[curr_vec].append(obstacle)
		
		nodes[curr_vec] = []
		# Fill that arr w/ neighbor positions.
		for direction in directions:
			var neighbor_vec = curr_vec + direction
			nodes[curr_vec].append(neighbor_vec)
			# This node was new, so some of its neighbors will be too.
			if !nodes.has(neighbor_vec):
				queue.append(neighbor_vec)
		max_iterations -= 1


func rebuild_nodes():
	print("rebuilding navmesh")
	navmesh_done = false
	queue = [Vector2.ZERO]
	nodes = {}
	colliding_nodes = {}
	max_iterations = 50000
	emit_signal("restart_pathfinding", nodes, colliding_nodes)


func rebuild_collisions():
	colliding_nodes = {}
	var seen_colliding_nodes = {}
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		var shape = obstacle.get_node("PathfindingObstacle/CollisionPolygon2D").get_polygon()
		var new_shape = []
		for vector in shape:
			new_shape.append(obstacle.global_position + vector)
		
		var maxX = max(new_shape[0].x, max(new_shape[1].x, max(new_shape[2].x, new_shape[3].x)))
		var minX = min(new_shape[0].x, min(new_shape[1].x, min(new_shape[2].x, new_shape[3].x)))
		var maxY = max(new_shape[0].y, max(new_shape[1].y, max(new_shape[2].y, new_shape[3].y)))
		var minY = min(new_shape[0].y, min(new_shape[1].y, min(new_shape[2].y, new_shape[3].y)))
		
		# Use loops to fill out collision nodes starting at one corner and going to the other.
		for curr_x in range(minX, maxX):
			for curr_y in range(minY, maxY):
				var step_x = stepify(curr_x, offset)
				var step_y = stepify(curr_y, offset)
				var curr_vec = Vector2(step_x, step_y)
				if seen_colliding_nodes.has(curr_vec):
					continue
				seen_colliding_nodes[curr_vec] = true
				
#				debug_path_viz(curr_vec)
				if !colliding_nodes.has(curr_vec):
					colliding_nodes[curr_vec] = []
				colliding_nodes[curr_vec].append(obstacle)
	emit_signal("restart_pathfinding", nodes, colliding_nodes)


#func rebuild_player_collisions():
#	player_colliding_nodes = {}
#	var seen_player_colliding_nodes = {}
#	for obstacle in get_tree().get_nodes_in_group("player"):
#		var shape = obstacle.get_node("PathfindingObstacle/CollisionPolygon2D").get_polygon()
#		var new_shape = []
#		for vector in shape:
#			new_shape.append(obstacle.global_position + vector)
#
#		var maxX = max(new_shape[0].x, max(new_shape[1].x, max(new_shape[2].x, new_shape[3].x)))
#		var minX = min(new_shape[0].x, min(new_shape[1].x, min(new_shape[2].x, new_shape[3].x)))
#		var maxY = max(new_shape[0].y, max(new_shape[1].y, max(new_shape[2].y, new_shape[3].y)))
#		var minY = min(new_shape[0].y, min(new_shape[1].y, min(new_shape[2].y, new_shape[3].y)))
#
#		# Use loops to fill out collision nodes starting at one corner and going to the other.
#		for curr_x in range(minX, maxX):
#			for curr_y in range(minY, maxY):
#				var step_x = stepify(curr_x, offset)
#				var step_y = stepify(curr_y, offset)
#				var curr_vec = Vector2(step_x, step_y)
#				if seen_player_colliding_nodes.has(curr_vec):
#					continue
#				seen_player_colliding_nodes[curr_vec] = true
##				debug_path_viz(curr_vec)
#				if !player_colliding_nodes.has(curr_vec):
#					player_colliding_nodes[curr_vec] = []
#				player_colliding_nodes[curr_vec].append(obstacle)
#	emit_signal("restart_player_pathfinding", player_colliding_nodes)
#
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


func debug_path_viz(position : Vector2):
	var new_viz = debug_viz.instance()
	new_viz.global_position = position
	Global.current_map.add_child(new_viz)
