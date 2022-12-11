# Template for objects that are pickable
#
# Can be extended for different objects that provide different
# functions.
#
# Once the player is in range, the item will be freed instantly

extends Area2D
class_name PickableObject

const PICKUP_SPEED = 300

var on_pickup_radius: bool = false setget set_on_pickup

signal picked


func _on_PickableObject_body_entered(body: Node) -> void:
	if body.collision_layer == 1:
		queue_free()
		emit_signal("picked")


func _physics_process(delta: float) -> void:
	if !on_pickup_radius:
		return
	var velocity: Vector2 = position.direction_to(Global.player.position)
	position += velocity * PICKUP_SPEED * delta


func set_on_pickup(value: bool) -> void:
	on_pickup_radius = value
