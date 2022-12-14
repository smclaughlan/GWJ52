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

var max_range = 500.0
var source : Node2D = null
var connected_to_source = true

var connections_in = []
var connections_out = []

onready var light_wire_scene = load("res://Scenes/Objects/Towers/LightWire.tscn")

signal upstream_power_disconnected

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_closest_tower()
	connected_to_source = has_unbroken_connection()
	if not connected_to_source:
		turn_off_the_lights()
		$ReconnectionTimer.start()
	$DebugInfo.text = "Connected: " + str(connected_to_source)


func has_unbroken_connection():
	# Conduct a depth first search to determine if we're connected to the source.

	# Create a stack and a set to store the nodes we've visited
	var stack = [self]
	var visited = [self]

	# While the stack is not empty...
	while stack.size() > 0:
		# Pop a node off the stack
		var current = stack.pop_back()

		# Check if it's the target
		if current == Global.power_source:
			return true

		# Add the neighbors of the tower to the stack
		for neighbor in current.connections_in:
			if not visited.has(neighbor):
				stack.append(neighbor)
				visited.append(neighbor)

	# If we get here, then we never found the target
	return false



func disconnect_all(): # your base was just destroyed.
	# remove the connections and delete the wires.
	# notify the other end of the wire to take you out of their connected lists
	
	for remoteTowerSocket in connections_in:
		# they don't really care, this tower is downstream of them
		remoteTowerSocket.connections_out.erase(self)
		

	for remoteTowerSocket in connections_out:
		# force disconnect adjacent downstream, then broadcast a signal which propagates down the entire tree
		remoteTowerSocket.connections_in.erase(self)
		remoteTowerSocket.get_node("In/LightWire").queue_free()
		remoteTowerSocket.notify_downstream_adjacent_towers()
		notify_downstream_adjacent_towers()

func notify_downstream_adjacent_towers():
	for towerSocket in connections_out:
		# they just lost their upstream power source
		# notify them and all their branches and leaves
		if not is_connected("upstream_power_disconnected", towerSocket, "_on_upstream_power_disconnected"):
			var _err = connect("upstream_power_disconnected", towerSocket, "_on_upstream_power_disconnected")
	# broadcast to everyone immediately downstream
	emit_signal("upstream_power_disconnected")

	
func get_nearest_tower_socket():
	var towers = get_tree().get_nodes_in_group("tower_sockets")
	return Global.get_closest_object(towers, self)

func get_nearby_powered_towers() -> Array:
	var nearby_powered_sockets = []
	for remoteSocket in get_tree().get_nodes_in_group("tower_sockets"):
		if self.global_position.distance_squared_to(remoteSocket.global_position) < max_range * max_range:
			if remoteSocket.connected_to_source:
				nearby_powered_sockets.append(remoteSocket)
	return nearby_powered_sockets



func turn_off_the_lights():
	$LightAura.enabled = false
	#$In/LightWire.points = [ ]

func turn_on_the_lights():
	$LightAura.enabled = true
	
	
# moved to Global
#func get_closest_object(group : Array, reference_point : Vector2):
#	var closest_object = null
#	for obj in group:
#		if obj != self:
#			if closest_object == null or obj.global_position.distance_squared_to(reference_point) < closest_object.global_position.distance_squared_to(reference_point):
#				closest_object = obj
#	return closest_object


func connect_closest_tower():
	var remoteTowerSocket = get_nearest_tower_socket()
	if remoteTowerSocket != null and is_instance_valid(remoteTowerSocket) and remoteTowerSocket != self:
		plugin_to(remoteTowerSocket)

		

func plugin_to(remoteTowerSocket):
	connections_in.append(remoteTowerSocket)
	remoteTowerSocket.connections_out.append(self)
	
	
	#var line = $In/LightWire
	var line = light_wire_scene.instance()
	line.name = "LightWire"
	$In.add_child(line)

	line.init(self)
	line.add_point(self.position)
	line.add_point(remoteTowerSocket.get_global_position() - self.global_position)
	line.set_default_color(Color(1, 1, 0.25, 0.25))


func attempt_to_repower():
	var nearbyNodes = get_nearby_powered_towers()
	if nearbyNodes.size() > 0:
		var nearest_powered_node = Global.get_closest_object(nearbyNodes, self)
		if self.global_position.distance_squared_to(nearest_powered_node.global_position) < max_range * max_range:
			plugin_to(nearest_powered_node)


func _on_upstream_power_disconnected():
	connected_to_source = false
	turn_off_the_lights()
	$ReconnectionTimer.start()
	notify_downstream_adjacent_towers()


func _on_ReconnectionTimer_timeout():
	connected_to_source = has_unbroken_connection()
	$DebugInfo.text = "Connected: " + str(connected_to_source)
	if connected_to_source:
		turn_on_the_lights()
		$ReconnectionTimer.stop()
	else:
		attempt_to_repower()




	
