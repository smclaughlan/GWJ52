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

signal tower_built

func _ready():
	connect("tower_built", Global.currency_tracker, "update_amount")


func init(myPlayer):
	player = myPlayer
	State = States.ACTIVE

func _unhandled_input(_event):
	if !equipped or State != States.ACTIVE:
		return
	elif Input.is_action_just_pressed(action_to_use):
		attempt_to_spawn_tower()

func attempt_to_spawn_tower():
	var cost_reference: CostReference = CostReference.new()
	cost_reference.tower = tower_base_scene.instance()
	cost_reference.cost = cost_reference.tower.cost
	if tower_buildmode_visual.can_place and cost_reference.can_purchase():
		spawn_tower()
		emit_signal("tower_built", -cost_reference.cost)
	else:
		$IncorrectPlacementNoise.play()


func spawn_tower():
	var new_tower = tower_base_scene.instance()
	new_tower.global_position = tower_buildmode_visual.global_position
	
	if Global.current_map != null and is_instance_valid(Global.current_map):
		$BuildNoise.play()
		Global.current_map.add_child(new_tower)
		new_tower.init("fire")


func set_towerbuildmode(enabled:bool):
	is_placing_tower = enabled
	if enabled:
		# Create green tower base to visualize where tower will be placed.
		tower_buildmode_visual = tower_buildmode.instance()
		tower_buildmode_visual.store_player(player)

		if Global.current_map != null and is_instance_valid(Global.current_map):
			Global.current_map.add_child(tower_buildmode_visual)
		else:
			printerr("config error in ConstructionWrench.gd. unknown Global.map")
	else: # disabled
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
	set_towerbuildmode(true)
	update_tower_build_visual()
	
func disable():
	visible = false
	State = States.STORED
	set_towerbuildmode(false)
	queue_free() # don't worry, player has a duplicate
	
func stow():
	disable()
	
func equip(actionKey : String):
	enable(actionKey)
	
