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


export var damage = 25.0
export var knockback_factor : float = 250.0

enum States {INITIALIZING, READY, SWINGING}
var State = States.INITIALIZING

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


func _on_DamageArea_body_entered(body):
	if body != null and is_instance_valid(body):
		if body.is_in_group("creeps") or body.is_in_group("EnemySpawners"):
			if body.has_method("_on_hit"):
				if player != null and is_instance_valid(player):
					var impactVector = (body.global_position - player.global_position).rotated(rand_range(-PI/3,PI/3)).normalized()*knockback_factor
					body._on_hit(damage, impactVector, damage_attributes)
		if body.is_in_group("EnemySpawners"):
			$CrunchNoise.play()
			
