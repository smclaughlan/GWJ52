"""
Wire Sockets should be able to:
	Connect nearby towers
	Draw power from Out slot to In Slot
	Power will provide turret with abilities
	
	Player should be able to manipulate wires.
		- change source, destination
	
	~~~~~~~~~~ MVP Cutoff ~~~~~~~~~~~	
	
	Future versions might have wire upgrades, splitters, filters, etc.

"""

extends Node2D

var max_range = 100.0
var source : Node2D = null
var connected_to_source = false

var connections_in = []
var connections_out = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(sourceNode : Node2D):
	source = sourceNode
	get_nearby_towers()
	connected_to_source = is_connected_to_source()
	print("Connected to source: ", connected_to_source)


func is_connected_to_source(): # recursive walk upstream
	if connections_in.has(source):
		return true
	else:
		for tower in connections_in:
			if tower.is_connected_to_source():
				return true
	return false


func connect_to():
	pass
	
func connect_from():
	pass

func get_nearby_towers():
	for tower in get_tree().get_nodes_in_group("towers"):
		if tower.position.distance_squared_to(self.position) < max_range * max_range:
			print("Tower found")
			if tower.position.x > self.position.x:
				connections_out.append(tower)
			else:
				connections_in.append(tower)	
	
