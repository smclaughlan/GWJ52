extends Node2D
var level_navigation_map :RID
var regionID : RID
onready var actor = find_node("KinematicBody2D")
var nav_agent : RID
var current_path = []
func _process(_delta):
	$TargetSprite.set_global_position(get_global_mouse_position())
	
func _ready():
	level_navigation_map = get_world_2d().get_navigation_map()
	regionID = Navigation2DServer.region_create()
	nav_agent = Navigation2DServer.agent_create()
	Navigation2DServer.agent_set_map(nav_agent, level_navigation_map)	
	Navigation2DServer.agent_set_radius(nav_agent, 50)

	Global.current_map = self
	
