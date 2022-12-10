# used for placing and repairing towers

# maybe later we'll change the wrench to be repair only, and a blueprint can be for placing towers

extends Node2D

var player
var tower_buildmode = load("res://Scenes/Objects/Towers/TowerBuildmode.tscn")
var tower_base_scene = load("res://Scenes/Objects/Towers/TowerBase.tscn")
var is_placing_tower : bool = false
var tower_buildmode_visual = null

var action_to_use : String
var equipped : bool = false

enum States { INITIALIZING, STORED, ACTIVE }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myPlayer):
	player = myPlayer


func _unhandled_input(event):
	if !equipped or State != States.ACTIVE:
		return
	elif Input.is_action_just_pressed(action_to_use) and tower_buildmode_visual.can_place:
		spawn_tower()


func spawn_tower():
	var new_tower = tower_base_scene.instance()
	new_tower.global_position = tower_buildmode_visual.global_position
	
	if Global.current_map != null and is_instance_valid(Global.current_map):
		Global.current_map.add_child(new_tower)
		new_tower.init("fire")



func toggle_towerbuildmode():
	is_placing_tower = !is_placing_tower
	if is_placing_tower:
		# Create green tower base to visualize where tower will be placed.
		tower_buildmode_visual = tower_buildmode.instance()
		tower_buildmode_visual.store_player(self)
		if Global.current_map != null and is_instance_valid(Global.current_map):
			Global.current_map.add_child(tower_buildmode_visual)
		else:
			get_tree().get_root().add_child(tower_buildmode_visual)
	else:
		# Stop showing the green tower base visual.
		tower_buildmode_visual.queue_free()
		
		
func update_tower_build_visual():
	if !is_placing_tower:
		return

	tower_buildmode_visual.global_position = get_global_mouse_position()


func _process(_delta):
	$Sprite.look_at(get_global_mouse_position())


func enable(actionKey : String):
	visible = true
	action_to_use = actionKey
	State = States.ACTIVE
	equipped = true
	toggle_towerbuildmode()
	update_tower_build_visual()
	
func disable():
	visible = false
	State = States.STORED
	queue_free() # don't worry, player has a duplicate
	
func stow():
	disable()
	
func equip(actionKey : String):
	enable(actionKey)
	
