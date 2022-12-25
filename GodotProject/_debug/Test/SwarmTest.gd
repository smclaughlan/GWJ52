# Swarm is a navigation pathfinder central sprite with a few boids that chase it

extends Node2D

var current_path
var local_path
var next_point : Vector2

export var speed = 6.0
onready var follow_target = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	for boid in $Boids.get_children():
		if boid.has_method("init"):
			boid.init($Sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if current_path != null and current_path.size() > 2:
		next_point = local_path[2] # look ahead an extra step
		var velocity = Vector2.ZERO
		velocity += next_point * speed * delta
		$Sprite.position += velocity

func translate_points_to_local(pointsArr):
	var newArr = []
	for point in pointsArr:
		newArr.push_back(point - $Sprite.get_global_position())
	return newArr

func update_nav():
	var level_navigation_map = get_world_2d().get_navigation_map()
	if level_navigation_map == null:
		return
	var optimize = true
	var actor = $Sprite
	if Global.player == null:
		current_path = Navigation2DServer.map_get_path(level_navigation_map, actor.get_global_position(), get_global_mouse_position(), optimize)
	else:
		current_path = Navigation2DServer.map_get_path(level_navigation_map, actor.get_global_position(), Global.player.global_position, optimize)

	local_path = translate_points_to_local(current_path)
	$Sprite/Line2D.points = local_path

func _on_VectorUpdateTimer_timeout():
	update_nav()
