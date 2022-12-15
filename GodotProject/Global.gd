extends Node

var game_speed : float = 1.0 # lower numbers for slowmo, higher number to accelerate time
var stage_manager : Control # responsible for changing scenes. Never use get_tree().change_scene()
var player : KinematicBody2D # player avatar, many things rely on this
var village_location : Vector2 # so creeps know where to go
var village : Node2D # Not actually necessary. The village can provide a random golem location for creeps, but they already get that info from the village group.
var current_map : Node2D # for spawning bullets and creeps
var nav_manager : Node # makes changes to nav mesh when placing/removing objects
var pickable_object_spawner: Node2D # Spawner node that handles spawning of pickables
var currency_tracker: Node # Node that tracks resources or currencies
var hud: CanvasLayer # HUD Reference
var grid_dist_px = 50
var power_source : Node2D # the first TowerWireSocket, at the home base
enum TowerTypes { BEAM, AOE, GLUE }
enum UpgradeTypes { BIGGER, FASTER, STRONGER }
var enable_fps_counter: bool # Shows an fps counter
var previous_window_index = 1


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
	
func show_fps_counter():
	# checks if the fps counter is enabled
	if enable_fps_counter:
		# if the fps counter is enabled but does not exist
		if !get_tree().get_root().get_node("FPS_COUNTER_HOLDER"):
			
			# init the fps counter holder
			var fps_counter_holder = CanvasLayer.new()
			fps_counter_holder.layer = 50
			fps_counter_holder.name = str("FPS_COUNTER_HOLDER")
			
			# init the fps counter
			
			var fps_counter = Label.new()
			fps_counter.name = str("FPS_COUNTER")
			fps_counter.rect_position = Vector2(10, 10)
			fps_counter.text = "FPS: 0"
			
			get_tree().get_root().add_child(fps_counter_holder) # create the fps counter holder
			fps_counter_holder.add_child(fps_counter) # create the fps counter
		elif get_tree().get_root().get_node("FPS_COUNTER_HOLDER"):
			# set the fps
			get_tree().get_root().get_node("FPS_COUNTER_HOLDER").get_node("FPS_COUNTER").text = str(Engine.get_frames_per_second())
			
	else:
		# delete the fps counter if not enabled
		var fps_counter_holder = get_tree().get_root().get_node("FPS_COUNTER_HOLDER")
		fps_counter_holder.queue_free()

func _process(_delta):
	if enable_fps_counter:
		show_fps_counter()
