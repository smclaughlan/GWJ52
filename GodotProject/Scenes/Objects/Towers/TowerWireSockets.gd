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

signal upstream_power_disconnected

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_closest_tower()
	connected_to_source = is_connected_to_source()


#func init(sourceNode : Node2D):
#	pass # no one initialized us yet


func is_connected_to_source(): # recursive walk upstream
	if self == Global.power_source:
		return true
	if connections_in.has(Global.power_source):
		return true
	else:
		for tower in connections_in:
			if tower != null and is_instance_valid(tower) and tower.is_inside_tree():
				if tower.is_connected_to_source():
					return true
	return false


func disconnect_all():
	
	
	for towerSocket in connections_in:
		# they don't really care, this tower is downstream of them
		towerSocket.connections_in.erase(self)
	
	for towerSocket in connections_out:
		# they just lost their upstream power source
		# notify them and all their branches and leaves
		if not is_connected("upstream_power_disconnected", towerSocket, "_on_upstream_power_disconnected"):
			var _err = connect("upstream_power_disconnected", towerSocket, "_on_upstream_power_disconnected")
		emit_signal("upstream_power_disconnected")

	
func get_nearest_tower_socket():
	var towers = get_tree().get_nodes_in_group("tower_sockets")
	return Global.get_closest_object(towers, self)

func turn_off_the_lights():
	$LightAura.enabled = false
	#$In/LightWire.queue_free()

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
		connections_in.append(remoteTowerSocket)
		remoteTowerSocket.connections_out.append(self)
		var line = $In/LightWire
		line.add_point(self.position)
		line.add_point(remoteTowerSocket.get_global_position() - self.global_position)
		line.set_default_color(Color(1, 1, 0.25, 0.25))
	
func _on_upstream_power_disconnected():
	connected_to_source = false
	turn_off_the_lights()
	$ReconnectionTimer.start()


func _on_ReconnectionTimer_timeout():
	connected_to_source = is_connected_to_source()
	if connected_to_source:
		turn_on_the_lights()
		$ReconnectionTimer.stop()
