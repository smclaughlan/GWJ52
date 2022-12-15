# AoE Projectile.

# travel slowly for a bit, then reveal your circle collision area.
# deal damage to any creeps / spawners in circle


extends Area2D


export var bullet_speed = 400.0
export var bullet_damage = 10.0
export var bullet_range = 300.0


export var damage_attributes = {
	"bleed":false,
	"poison":false,
	"fire":false,
	"holy":false,
	"armor_piercing":true,
}

enum States { DISABLED, INITIALIZING, MOVING, EXPLODING, DEAD }
var State = States.DISABLED

signal hit(damage, impactVector, features)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(pos, rot):
	set_global_position(pos)
	set_global_rotation(rot)
	set_visible(true)
	$CollisionShape2D.set_deferred("disabled", true)
	$explosion.visible = false

	State = States.MOVING
	$DurationTimer.start()
	$TravelTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		var fwdVector = (Vector2.RIGHT * bullet_speed).rotated(rotation)
		position += fwdVector * delta * Global.game_speed


func die():
	queue_free()


func explode():
	State = States.EXPLODING
	$CollisionShape2D.set_deferred("disabled", false)
	$explosion.visible = true
	$explosion.play("explode")
	$BoomNoise.play()
	var incinerate_timer = get_tree().create_timer(0.1)
	yield(incinerate_timer, "timeout") # give the collision shape a chance to appear
	for body in self.get_overlapping_bodies():

		if body.has_method("_on_hit") and body != Global.player:
			if not is_connected("hit", body, "_on_hit"):
				var _err = connect("hit", body, "_on_hit")
			var impactVector = (body.global_position - global_position)*(bullet_damage/5.0)
			emit_signal("hit", bullet_damage, impactVector, damage_attributes)
	bullet_speed = 0.0
	
	#die()
	



func _on_Bullet_body_entered(_body):
	return # not needed, we'll get overlapping_bodies instead
	
#	if body.has_method("_on_hit") and body != Global.player:
#		if not is_connected("hit", body, "_on_hit"):
#			var _err = connect("hit", body, "_on_hit")
#		var fwdVector = (Vector2.RIGHT * bullet_speed/3.0).rotated(rotation)
#		emit_signal("hit", bullet_damage, fwdVector, damage_attributes)
		
		


func _on_DurationTimer_timeout():
	pass
	#die()


func _on_TravelTimer_timeout():
	explode()


func _on_explosion_animation_finished():
	die()
