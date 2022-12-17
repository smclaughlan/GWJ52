extends Area2D


export var bullet_speed = 400.0
export var bullet_damage = 20.0
export var bullet_range = 300.0


export var damage_attributes = {
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
	State = States.MOVING
	look_at(Global.player.global_position)
	set_visible(true)
	$CollisionShape2D.set_deferred("disabled", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		var fwdVector = (Vector2.RIGHT * bullet_speed).rotated(rotation)
		position += fwdVector * delta * Global.game_speed


func die():
	# play some animation, then disappear
	queue_free()


func _on_Bullet_body_entered(body):
	if body.has_method("_on_hit") and body == Global.player:
		if not is_connected("hit", body, "_on_hit"):
			var _err = connect("hit", body, "_on_hit")
		var fwdVector = (Vector2.RIGHT * bullet_speed/3.0).rotated(rotation)
		emit_signal("hit", bullet_damage, fwdVector, damage_attributes)
		die()
		
