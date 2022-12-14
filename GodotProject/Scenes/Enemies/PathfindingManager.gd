# Nodes will not be placed anywhere where the path area collides.
# To use the nodes, we'll BFS through them. 

extends Node2D

var debug_viz = load("res://Scenes/Enemies/debug/pathfindViz.tscn")

var navmesh_done = false
onready var path_area = $PathArea
var offset = 40
var max_iterations
	# will look like this, key with an array list of neighboring positions to move to.
	# (0, 0) : [(1, 1), (0, 1), ...] 
var nodes = {}
	# this will let us put colliding_node[vector] and detect collisions
	# (0, 0): [Tower:1234] 
var colliding_nodes = {}
var queue = []

signal restart_pathfinding


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
	queue = [String(Vector2.ZERO)]
	max_iterations = 10000
	create_nodes()
	
func _process(delta):
	if navmesh_done == true:
		return
	if max_iterations <= 0:
#		print("nodes", nodes)
#		print("colliding_nodes", colliding_nodes)
		navmesh_done = true
		# signal all pathfinders to restart pathfinding
		emit_signal("restart_pathfinding")
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
		for debug_collider in get_tree().get_nodes_in_group("DebugColliders"):
			var shape = debug_collider.get_node("PathfindingObstacle/CollisionPolygon2D").get_polygon()
			var new_shape = []
			for vector in shape:
				new_shape.append(debug_collider.global_position + vector)
				
			var maxX = max(new_shape[0].x, max(new_shape[1].x, max(new_shape[2].x, new_shape[3].x)))
			var minX = min(new_shape[0].x, min(new_shape[1].x, min(new_shape[2].x, new_shape[3].x)))
			var maxY = max(new_shape[0].y, max(new_shape[1].y, max(new_shape[2].y, new_shape[3].y)))
			var minY = min(new_shape[0].y, min(new_shape[1].y, min(new_shape[2].y, new_shape[3].y)))
			
			# If the curr_vec.x is > minX and < maxX, while vec.y is > minY and < maxY
			# it's inside and colliding
			var vec = str_to_vector2(curr_vec)
			if vec.x > minX and vec.x < maxX and vec.y > minY and vec.y < maxY:
				if !colliding_nodes.has(curr_vec):
					colliding_nodes[curr_vec] = []
				colliding_nodes[curr_vec].append(debug_collider)
				
		for tower in get_tree().get_nodes_in_group("towers"):
			var shape = tower.get_node("PathfindingObstacle/CollisionPolygon2D").get_polygon()
			var new_shape = []
			for vector in shape:
				new_shape.append(tower.global_position + vector)
			
			var maxX = max(new_shape[0].x, max(new_shape[1].x, max(new_shape[2].x, new_shape[3].x)))
			var minX = min(new_shape[0].x, min(new_shape[1].x, min(new_shape[2].x, new_shape[3].x)))
			var maxY = max(new_shape[0].y, max(new_shape[1].y, max(new_shape[2].y, new_shape[3].y)))
			var minY = min(new_shape[0].y, min(new_shape[1].y, min(new_shape[2].y, new_shape[3].y)))
			
			# If the curr_vec.x is > minX and < maxX, while vec.y is > minY and < maxY
			# it's inside and colliding
			var vec = str_to_vector2(curr_vec)
			if vec.x > minX and vec.x < maxX and vec.y > minY and vec.y < maxY:
				if !colliding_nodes.has(curr_vec):
					colliding_nodes[curr_vec] = []
				colliding_nodes[curr_vec].append(tower)
		
		nodes[curr_vec] = []
		# Fill that arr w/ neighbor positions.
		for direction in directions:
			var neighbor_vec = str_to_vector2(curr_vec) + direction
			var strNeighbor = String(neighbor_vec)
			nodes[curr_vec].append(strNeighbor)
			# This node was new, so some of its neighbors will be too.
			if !nodes.has(strNeighbor):
				queue.append(strNeighbor)
		max_iterations -= 1


func rebuild_nodes():
	print("rebuilding navmesh")
	navmesh_done = false
	queue = [String(Vector2.ZERO)]
	nodes = {}
	colliding_nodes = {}
	max_iterations = 10000
	emit_signal("restart_pathfinding")


func str_to_vector2(strVec):
	# Remove the "Vector2(" and ")" characters from the string
	var string = strVec.replace("(", "").replace(")", "")
	
	# Split the string on the "," character to get the x and y components
	var components = string.split(",")

	# Convert the x and y components into float values
	var x = float(components[0])
	var y = float(components[1])

	# Return the Vector2
	return Vector2(x, y)


func debug_path_viz(position : Vector2):
	var new_viz = debug_viz.instance()
	new_viz.global_position = position
	Global.current_map.add_child(new_viz)
