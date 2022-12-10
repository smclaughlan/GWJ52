extends KinematicBody2D

var tower_buildmode = load("res://Scenes/Objects/Towers/TowerBuildmode.tscn")
var tower_base_scene = load("res://Scenes/Objects/Towers/TowerBase.tscn")

var velocity : Vector2 = Vector2.ZERO
var player_speed : float = 400.0
var is_placing_tower : bool = false
var tower_buildmode_visual = null
onready var weapons = $WeaponSlot.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = Vector2.ZERO

	if Input.is_action_just_released("toggle_towerbuild"):
		toggle_towerbuildmode()
	update_tower_build_visual()

	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT
	elif Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN

	if Input.is_action_just_released("shoot") and is_placing_tower and tower_buildmode_visual.can_place:
		var new_tower = tower_base_scene.instance()
		new_tower.global_position = tower_buildmode_visual.global_position
		get_tree().get_root().add_child(new_tower)
		new_tower.init("fire")

	velocity = velocity.normalized() * player_speed

	velocity = move_and_slide(velocity * Global.game_speed) # delta not required


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

	for weapon in weapons:
		if weapon.has_method("toggle_shooting"):
			weapon.toggle_shooting()


func update_tower_build_visual():
	if !is_placing_tower:
		return

	tower_buildmode_visual.global_position = get_global_mouse_position()
