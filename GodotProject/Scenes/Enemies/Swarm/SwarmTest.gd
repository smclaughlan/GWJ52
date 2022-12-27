# Swarm is a navigation pathfinder central sprite with a few boids that chase it

# Note, the Swarm object will stay in place, the Sprite and boids will move.

extends Node2D

var current_path
var local_path
var next_point : Vector2

export var speed : float = 6.0
export var max_boids : int = 12
export var max_swarms : int = 6
onready var follow_target = $SwarmMother
var swarm_scene_path = "res://Scenes/Enemies/Swarm/SwarmTest.tscn"

enum States { INITIALIZING, READY, DEAD }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	# probably don't need this if we start empty
	for boid in $Boids.get_children():
		if boid.has_method("init"):
			boid.init($SwarmMother)

	State = States.READY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# move_and_slide doesn't use delta
	if current_path != null and current_path.size() > 2:
		next_point = local_path[2] # look ahead an extra step
		var velocity = Vector2.ZERO
		velocity += next_point * speed
		$SwarmMother.move_and_slide( velocity )

func translate_points_to_local(pointsArr):
	var newArr = []
	for point in pointsArr:
		newArr.push_back(point - $SwarmMother.get_global_position())
	return newArr

func update_nav():
	var level_navigation_map = get_world_2d().get_navigation_map()
	if level_navigation_map == null:
		return
	var optimize = true
	var actor = $SwarmMother
	if Global.player == null:
		current_path = Navigation2DServer.map_get_path(level_navigation_map, actor.get_global_position(), get_global_mouse_position(), optimize)
	else:
		current_path = Navigation2DServer.map_get_path(level_navigation_map, actor.get_global_position(), Global.player.global_position, optimize)

	local_path = translate_points_to_local(current_path)
	$SwarmMother/Sprite/Line2D.points = local_path

func _on_VectorUpdateTimer_timeout():
	update_nav()

func spawn_boid():
	var newBoid = $ResourcePreloader.get_resource("Boid").instance()
	$Boids.add_child(newBoid)
	newBoid.init($SwarmMother)


func split_using_binary_fission():
	# make a new swarm and give it half your boids
	if get_parent().get_child_count() < max_swarms:
		var newSwarm = load(swarm_scene_path).instance()
		get_parent().add_child(newSwarm)
		var randOffset = Vector2.ONE.rotated(rand_range(-PI, PI) * rand_range(30,50))
		newSwarm.set_global_position(global_position)
		newSwarm.get_node("SwarmMother").global_position = $SwarmMother.global_position + randOffset

		var boids = $Boids.get_children()
		for boid in boids:
			#warning-ignore:integer_division
			if boid.get_position_in_parent() > max_boids / 2:
				$Boids.remove_child(boid)
				newSwarm.get_node("Boids").add_child(boid)
		
	

	
func _on_NewBoidTimer_timeout():
	if $Boids.get_child_count() < max_boids:
		spawn_boid()
		$NewBoidTimer.start()
	else:
		split_using_binary_fission()
		$NewBoidTimer.start()
