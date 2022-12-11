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

var max_range = 1000.0
var source : Node2D = null
var connected_to_source = false

var connections_in = []
var connections_out = []

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_closest_tower()


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


	

func get_nearby_towers():
	for tower in get_tree().get_nodes_in_group("tower_sockets"):
		if tower.position.distance_squared_to(self.position) < max_range * max_range:
			print("Tower found")
			if tower.position.x > self.position.x:
				connections_out.append(tower)
			else:
				connections_in.append(tower)	
	
func get_nearest_tower():
	var towers = get_tree().get_nodes_in_group("tower_sockets")
	return get_closest_object(towers, self.global_position)


func get_closest_object(group : Array, reference_point : Vector2):
	var closest_object = null
	for obj in group:
		if obj != self:
			if closest_object == null or obj.global_position.distance_squared_to(reference_point) < closest_object.global_position.distance_squared_to(reference_point):
				closest_object = obj
	return closest_object


func connect_closest_tower():
	var tower = get_nearest_tower()
	if tower != null and is_instance_valid(tower) and tower != self:
		connections_in.append(tower)
		tower.connections_out.append(self)
		var line = $In/LightWire
		line.add_point(self.position)
		line.add_point(tower.get_global_position() - self.global_position)
		line.set_default_color(Color(1, 1, 0.25, 0.25))
	
