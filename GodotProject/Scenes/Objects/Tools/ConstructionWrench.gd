extends Node2D

var player
var tower_buildmode = load("res://Scenes/Objects/Towers/TowerBuildmode.tscn")
var tower_base_scene = load("res://Scenes/Objects/Towers/TowerBase.tscn")
var is_placing_tower : bool = false
var tower_buildmode_visual = null

var action_to_use : String

enum States { INITIALIZING, STORED, ACTIVE }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myPlayer):
	player = myPlayer


func _unhandled_input(event):
	
	if not State == States.ACTIVE:
		return

	if Input.is_action_just_released("toggle_towerbuild"):
		toggle_towerbuildmode()
	update_tower_build_visual()

	
	if event.is_action_pressed("build"):
		# spawn a tower in the target location
		var tower = preload("res://Scenes/Towers/PlaceholderTower.tscn").instance()
		var towerPosition = $Sprite/TargetPosition.get_global_position()

		# this should be a signal to ask the map to spawn the tower
		Global.current_map.add_child(tower )
		tower.set_global_position(towerPosition)

	if Input.is_action_just_released(action_to_use) and is_placing_tower and tower_buildmode_visual.can_place:
		var new_tower = tower_base_scene.instance()
		new_tower.global_position = tower_buildmode_visual.global_position
		get_tree().get_root().add_child(new_tower)
		new_tower.init("fire")
		

func toggle_towerbuildmode():
	is_placing_tower = !is_placing_tower
	if is_placing_tower:
		# Create green tower base to visualize where tower will be placed.
		tower_buildmode_visual = tower_buildmode.instance()
		tower_buildmode_visual.store_player(self)
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
	$Sprite.visible = true
	action_to_use = actionKey
	State = States.ACTIVE
	
func disable():
	$Sprite.visible = false
	State = States.STORED
	queue_free() # don't worry, player has a duplicate
	
func stow():
	disable()
	
func equip(actionKey : String):
	enable(actionKey)
	
