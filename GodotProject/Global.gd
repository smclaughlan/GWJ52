extends Node

var game_speed : float = 1.0 # lower numbers for slowmo, higher number to accelerate time
var stage_manager : Control # responsible for changing scenes. Never use get_tree().change_scene()
var player : KinematicBody2D # player avatar, many things rely on this
var village_location : Vector2 # so creeps know where to go
var current_map : Node2D # for spawning bullets and creeps
var nav_manager : Node # makes changes to nav mesh when placing/removing objects
var pickable_object_spawner: Node2D # Spawner node that handles spawning of pickables
var currency_tracker: Node # Node that tracks resources or currencies
var hud: CanvasLayer # HUD Reference
var grid_dist_px = 50
var power_source : Node2D # the first TowerWireSocket, at the home base


func pause():
	# this is pretty abrupt and brute force.
	get_tree().set_pause(true)


func resume():
	get_tree().set_pause(false)


func get_closest_object(group : Array, referenceObj ):
	var refPos = referenceObj.global_position
	var closest_object = null
	for obj in group:
		if is_instance_valid(obj) and obj != referenceObj and obj.is_inside_tree():
			var objPos = obj.global_position
			if closest_object == null or objPos.distance_squared_to(refPos) < closest_object.global_position.distance_squared_to(refPos):
				closest_object = obj
	return closest_object
	
