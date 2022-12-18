extends Area2D


export var bullet_speed = 400.0
export var bullet_damage = 20.0
var crystal_hit_sound_scene = preload("res://Scenes/Objects/Projectiles/CrystalHitSound.tscn")

var damage_attributes = {
	"bleed":false,
	"poison":false,
	"fire":false,
	"holy":false,
	"armor_piercing":true,
}

enum States { DISABLED, INITIALIZING, MOVING, DEAD }
var State = States.DISABLED

signal hit(damage, impactVector, features)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(pos, rot):
	set_global_position(pos)
	set_global_rotation(rot)
	set_visible(true)
	$CollisionShape2D.set_deferred("disabled", false)
	State = States.MOVING

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		var fwdVector = (Vector2.RIGHT * bullet_speed).rotated(rotation)
		position += fwdVector * delta * Global.game_speed


func die():
	# play some animation, then disappear
	queue_free()


func _on_Bullet_body_entered(body):
	if body.has_method("_on_hit") and body != Global.player:
		if not is_connected("hit", body, "_on_hit"):
			var _err = connect("hit", body, "_on_hit")
		var fwdVector = (Vector2.RIGHT * 50.0).rotated(rotation)
		emit_signal("hit", bullet_damage, fwdVector, damage_attributes)
		var new_sound = crystal_hit_sound_scene.instance()
		new_sound.global_position = global_position
		Global.stage_manager.current_map.add_child(new_sound)
		die()
		


func _on_Timer_timeout():
	if is_instance_valid(self):
		call_deferred("queue_free")
