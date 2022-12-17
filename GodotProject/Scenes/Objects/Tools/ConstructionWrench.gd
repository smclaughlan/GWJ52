# used for placing and repairing towers

# maybe later we'll change the wrench to be repair only, and a blueprint can be for placing towers

extends Node2D

var player
var tower_buildmode = load("res://Scenes/Objects/Towers/TowerBuildmode.tscn")
var tower_base_scene = load("res://Scenes/Objects/Towers/TowerBase.tscn")
#onready var deconstruct_area_2d = $DeconstructArea2D
var is_placing_tower : bool = false
var tower_buildmode_visual = null
#var tower_to_deconstruct = null

var num_towers_placed : int = 0

const TowerTypes = Global.TowerTypes
var tower_type = TowerTypes.BEAM

# turrets change, not bases.
#var tower_base_scenes = [
#	"res://Scenes/Objects/Towers/TowerBeam.tscn",
#	"res://Scenes/Objects/Towers/TowerAoE.tscn",
#	"res://Scenes/Objects/Towers/TowerGlue.tscn",
#	]


var action_to_use : String
var equipped : bool = false

enum States { INITIALIZING, STORED, ACTIVE, BUILDING, PAUSED }
var State = States.INITIALIZING

signal tower_built
signal tutorial_ended

func _ready():
	var delay_let_ancestors_initialize_first = get_tree().create_timer(0.1)
	yield(delay_let_ancestors_initialize_first, "timeout")
	var _err = connect("tower_built", Global.currency_tracker, "update_amount")
	_err = connect("tutorial_ended", Global.current_map, "_on_tutorial_ended")
	_err = connect("tutorial_ended", Global.player.hud, "_on_tutorial_ended")

func init(myPlayer):
	player = myPlayer
	State = States.ACTIVE

func _unhandled_input(_event):
	if equipped == true and State == States.ACTIVE:
		if Input.is_action_just_pressed("next_blueprint"):
			increment_blueprint(1)
		elif Input.is_action_just_pressed("prev_blueprint"):
			increment_blueprint(-1)
		if Input.is_action_just_pressed(action_to_use):
			attempt_to_spawn_tower(tower_type)


func increment_blueprint(value:int): # +1 == fwd, -1 == backward
	tower_type += value
	if tower_type == TowerTypes.size():
		tower_type = 0
	elif tower_type < 0:
		tower_type = TowerTypes.size()-1
	tower_buildmode_visual.set_tower_type(tower_type)
	#tower_base_scene = load(tower_base_scenes[tower_type])

	Global.player.hud._on_tower_type_blueprint_changed(tower_type)
	

func attempt_to_spawn_tower(towerType):
	State = States.BUILDING
	var cost_reference: CostReference = CostReference.new()
	cost_reference.tower = tower_base_scene.instance()
	cost_reference.cost = cost_reference.tower.cost
	if cost_reference.can_purchase() == false:
		$InsufficientFundsNoise.play()
	elif tower_buildmode_visual.can_place == false:
		$IncorrectPlacementNoise.play()
	else:
		spawn_tower(towerType)
		emit_signal("tower_built", -cost_reference.cost)
	$ReloadTimer.start()
	


func spawn_tower(towerType):
	var new_tower = tower_base_scene.instance() # common base scene for all "tower types", only the turrets change
	new_tower.global_position = tower_buildmode_visual.global_position
	
	if Global.current_map != null and is_instance_valid(Global.current_map):
		$BuildNoise.play()
		Global.current_map.find_node("YSort").add_child(new_tower)
		new_tower.init(towerType)
		
		#Removed because of slowdowns
		#Global.current_map.get_node("NavManager").cut_object_from_nav(new_tower)
		
		# moved tutorial end signal to HUD
#		num_towers_placed += 1
#
#		if num_towers_placed == 3 and Global.current_map.tutorial_ended == false:
#			emit_signal("tutorial_ended")

		#build_tilemap_walls_under_tower(new_tower)
		#causes too much slowdown
		
func build_tilemap_walls_under_tower(new_tower):
	assert(false) # deprecated function, don't use it.
	# This might be causing slowdowns. We may need to remove it.

	var tilemap = Global.current_map.get_node("tilemap")
	var local_position = tilemap.to_local(new_tower.global_position)
	var map_position = tilemap.world_to_map(local_position)
	#var specific_tile = tilemap.get_cell(map_position.x, map_position.y)
	
	for row in range(3):
		for col in range(3):
			var posX = map_position.x + col - 1
			var posY = map_position.y + row - 1
			tilemap.set_cell(posX, posY, 1)


func set_towerbuildmode(enabled:bool):
	is_placing_tower = enabled
	if enabled:
		# Create green tower base to visualize where tower will be placed.
		tower_buildmode_visual = tower_buildmode.instance()
		tower_buildmode_visual.set_tower_type(tower_type)
		tower_buildmode_visual.store_player(player)

		if Global.current_map != null and is_instance_valid(Global.current_map):
			Global.current_map.find_node("YSort").add_child(tower_buildmode_visual)
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
	aim_chiral_sprite()


func aim_chiral_sprite(): # for sprites the would look upside down if rotated 180
	var mousePos = get_global_mouse_position()
	# flip if needed
	if mousePos.x < get_global_position().x:
		scale.x = -abs(scale.x)
		rotation = global_position.direction_to(mousePos).angle() - PI
	else:
		scale.x = abs(scale.x)
		look_at(get_global_mouse_position())


func _physics_process(_delta):
	if State != States.ACTIVE:
		return


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
	
func _on_menu_opened():
	State = States.PAUSED
func _on_menu_closed():
	State = States.READY


func _on_ReloadTimer_timeout():
	State = States.ACTIVE

