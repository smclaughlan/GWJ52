extends Node2D

var action_to_use : String
var equipped : bool = false
var player
var damage_attributes = {
	"bleed":true,
	"poison":false,
	"fire":false,
	"holy":false,
	"armor_piercing":false,
}


export var damage = 30.0
export var knockback_factor : float = 250.0
var melee_hit_audio_scene = preload("res://Scenes/Objects/Weapons/MeleeHitAudio.tscn")
onready var hit_cooldown_timer = $HitCooldownTimer
var is_on_hit_cooldown_sound = false
enum States {INITIALIZING, READY, SWINGING}
var State = States.INITIALIZING

signal struck_tilemap_terrain(tile_id, damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	$DamageArea/Sprite/SpeedLines.hide()

func init(myPlayer):
	player = myPlayer
	disable_collisions()
	
func _unhandled_input(event):
	if equipped and State == States.READY:
		if event.is_action_pressed(action_to_use):
			swing()

func _process(_delta):
	if equipped and State in [States.READY, States.SWINGING]:
		look_at(get_global_mouse_position())

func swing():
	if State == States.READY:
		State = States.SWINGING
		enable_collisions()
		$AnimationPlayer.play("swing")
		$SwingNoise.set_pitch_scale(rand_range(0.8, 1.2))
		$SwingNoise.play()

func enable_collisions():
	$DamageArea.set_collision_mask_bit(1, true)

func disable_collisions():
	$DamageArea.set_collision_mask_bit(1, false)


func enable(actionString:String):
	visible = true
	equipped = true
	action_to_use = actionString
	State = States.READY
	
func disable():
	visible = false
	equipped = false
	action_to_use = ""
	queue_free() # don't worry, player has a duplicate

func equip(actionString:String):
	enable(actionString)
	
func stow():
	disable()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "swing":
		State = States.READY
		if Input.is_action_pressed(action_to_use):
			swing()
		else:
			disable_collisions()


func strike(body):
	if body.has_method("_on_hit"):
		if player != null and is_instance_valid(player):
			var impactVector = (body.global_position - player.global_position).rotated(rand_range(-PI/3,PI/3)).normalized()*knockback_factor
			body._on_hit(damage, impactVector, damage_attributes)
			if !is_on_hit_cooldown_sound:
				var new_hit_audio = melee_hit_audio_scene.instance()
				new_hit_audio.global_position = global_position
				Global.stage_manager.current_map.add_child(new_hit_audio)
				is_on_hit_cooldown_sound = !is_on_hit_cooldown_sound
				hit_cooldown_timer.start()


func mine_for_ore(tileMap):
	if hit_cooldown_timer.is_stopped():
		
		
		# It would be nice if the axe didn't go through the rocks
#		$AnimationPlayer.seek(0)
#		$AnimationPlayer.stop()
#		_on_AnimationPlayer_animation_finished("swing")
#
		
		# send a signal to the tilemap, let it figure out what to do with the damage
		var globalCoords = $DamageArea/LeadingEdge.global_position

		if not is_connected("struck_tilemap_terrain", tileMap, "_on_pickaxe_struck_tile"):
			connect("struck_tilemap_terrain", tileMap, "_on_pickaxe_struck_tile")
		emit_signal("struck_tilemap_terrain", globalCoords, damage, damage_attributes)
		hit_cooldown_timer.start()
		$CrunchNoise.play()
	

func _on_DamageArea_body_entered(body):
	if body != null and is_instance_valid(body):
		if body.is_in_group("creeps") or body.is_in_group("EnemySpawners"):
			strike(body)
		elif body.name == "TileMap":
			mine_for_ore(body)


func _on_HitCooldownTimer_timeout():
	is_on_hit_cooldown_sound = false
