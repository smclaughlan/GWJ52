# Lock onto a target and follow them with 
# persistent, low-damage DoT laser.



extends Area2D


#export var bullet_speed = 400.0
export var laser_damage_per_tick = 2.0
export var laser_range = 300.0
export var bullet_speed = 1000000 # hax because some scripts (TowerTurret.gd) rely on it

var target_enemy

export var damage_attributes = {
	"bleed":false,
	"poison":false,
	"fire":false,
	"holy":false,
	"armor_piercing":true,
}

enum States { DISABLED, INITIALIZING, FIRING, DEAD }
var State = States.DISABLED

signal hit(damage, impactVector, features)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(pos, _rot):
	set_global_position(pos)
	set_global_rotation(0.0) # tracking laser beams don't need rotation like bullets do
	
	set_visible(true)
	$Sprite/RayCast2D.enabled = true # may not need this
	$DamageIntervalTimer.start()
	State = States.FIRING


func set_target(target):
	target_enemy = target
	var _err = connect("hit", target_enemy, "_on_hit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# track the target
	
	if State == States.FIRING and is_instance_valid(target_enemy) and target_enemy.health > 0:
		$Sprite/Line2D.visible = true
		$Sprite/Line2D.points = [ Vector2.ZERO, target_enemy.global_position - self.global_position]
	else:
		die()


func die():
	$Sprite/Line2D.visible = false
	$DurationTimer.stop()
	$DamageIntervalTimer.stop()
	queue_free()


func _on_DamageIntervalTimer_timeout():
	if State != States.FIRING:
		return
		
	if target_enemy != null and is_instance_valid(target_enemy):
		var dist_sq = self.global_position.distance_squared_to(target_enemy.global_position )
		if dist_sq < laser_range * laser_range:
			emit_signal("hit", laser_damage_per_tick, Vector2.ZERO, damage_attributes)
		else:
			die() # target got away
	else:
		die() # target likely dead

func _on_DurationTimer_timeout():
	die()
