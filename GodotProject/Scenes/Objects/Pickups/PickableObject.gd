# Template for objects that are pickable
#
# Can be extended for different objects that provide different
# functions.
#
# Once the player is in range, the item will be freed instantly

extends Area2D
class_name PickableObject

export var PICKUP_SPEED = 500.0

var on_pickup_radius: bool = false setget set_on_pickup

signal picked


func _on_PickableObject_body_entered(body: Node) -> void:
	if body.collision_layer == 1: #Player
		$Sprite.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		
		play_pickup_noise()
		$linger_for_audio_timer.start()
		emit_signal("picked")


func play_pickup_noise():
	if $CustomNoises.get_child_count() > 0:
		var customNoises = $CustomNoises.get_children()
		var randNoise = customNoises[randi()%customNoises.size()]
		randNoise.set_pitch_scale(rand_range(0.9, 1.1))
		randNoise.play()
	else:
		$DefaultPickupNoise.set_pitch_scale(rand_range(0.9, 1.1))
		$DefaultPickupNoise.play()
	

func _physics_process(delta: float) -> void:
	if !on_pickup_radius:
		return
	var velocity: Vector2 = position.direction_to(Global.player.position)
	position += velocity * PICKUP_SPEED * delta


func set_on_pickup(value: bool) -> void:
	on_pickup_radius = value


func _on_linger_for_audio_timer_timeout():
	queue_free()
