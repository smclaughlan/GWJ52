extends KinematicBody2D


var vectors = {
	"peer_avoidance":Vector2.ZERO,
	"cohesion":Vector2.ZERO,
	"alignment":Vector2.ZERO,
	"follow_target":Vector2.ZERO,
	"obstacle_avoidance":Vector2.ZERO,
}

var peers = []
var avoidance_distance = 32.0
var velocity = Vector2.RIGHT
export var speed = 150.0
export var max_turning_rate = 7.5 # radians

var path_follow_target

var ticks : int = 0

enum States { INITIALIZING, READY, DEAD }
var State = States.INITIALIZING

var max_health = 30.0
var health = max_health

# Called when the node enters the scene tree for the first time.
func _ready():
	peers = get_parent().get_children()

	peers.erase(self)

func init(target):
	path_follow_target = target
	State = States.READY

func get_peer_avoidance_vector():
	if peers.size() == 0:
		return
	var peer_avoidance_vector = Vector2.ZERO
	var myPos = global_position
	for peer in peers:
		var peerPos = peer.global_position
		if myPos.distance_squared_to(peerPos) < avoidance_distance * avoidance_distance:
			peer_avoidance_vector += peerPos.direction_to(myPos)
	return peer_avoidance_vector.normalized() * 2.0

func get_cohesion_vector():
	if peers.size() == 0:
		return
	var cohesion_vector = Vector2.ZERO
	
	for peer in peers:
		cohesion_vector += peer.global_position
	cohesion_vector = cohesion_vector / peers.size()
	return self.to_local(cohesion_vector).normalized()
	
func get_alignment_vector():
	if peers.size() == 0:
		return
	var alignment_vector = Vector2.ZERO
	for peer in peers:
		alignment_vector += peer.velocity
	alignment_vector = alignment_vector / peers.size()
	return alignment_vector.normalized()

func get_target_vector():
	var target_vector = get_parent().get_parent().follow_target.global_position - global_position
	return target_vector.normalized()


func get_obstacle_avoidance_vector():
	if $ObstacleAvoidanceRay.is_colliding():
		var normal = $ObstacleAvoidanceRay.get_collision_normal()
		#var fwdVector = Vector2.RIGHT.rotated(global_rotation)
		#return fwdVector.bounce(normal) 
		return normal

func get_follow_target_vector():
	if path_follow_target != null:
		return global_position.direction_to(path_follow_target.global_position)
	else:
		return Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ticks += 1
	if ticks % 5 == 0:
		pass

	move(delta)


func get_intermediary_velocity(currentVelocity: Vector2, proposedVelocity: Vector2, maxTurningRate: float, delta: float):
	var angle = currentVelocity.angle_to(proposedVelocity)
	var minAngle = -maxTurningRate * delta
	var maxAngle = maxTurningRate * delta
	var clampedAngle = clamp(angle, minAngle, maxAngle)
	var intermediaryVelocity = currentVelocity.rotated(clampedAngle)

	return intermediaryVelocity

func cull_dead_peers():
	var tempPeers = peers.duplicate()
	for peer in tempPeers:
		if not is_instance_valid(peer):
			peers.erase(peer)
			

func move(delta):
	cull_dead_peers()
	var proposedVelocity = Vector2.ZERO
	var newVelocity = Vector2.ZERO
	vectors["alignment"] = get_alignment_vector()
	vectors["cohesion"] = get_cohesion_vector()
	vectors["peer_avoidance"] = get_peer_avoidance_vector()
	vectors["target"] = get_target_vector()
	vectors["obstacle_avoidance"] = get_obstacle_avoidance_vector()
	vectors["follow_target"] = get_follow_target_vector()
	var count = 0
	for vectorName in vectors.keys():
		if vectors[vectorName] != null:
			proposedVelocity += vectors[vectorName]
			count += 1
	proposedVelocity = proposedVelocity / count
	newVelocity = get_intermediary_velocity(velocity, proposedVelocity, max_turning_rate, delta)
	
	velocity = newVelocity.normalized() * speed
	global_rotation = Vector2.RIGHT.angle_to(velocity)

	var _result_vect = move_and_slide( velocity  )

func die():
	queue_free()

func _on_hit(damage, _impulseVector, _damageAttributes):
	if health > damage:
		health -= damage
	else:
		health = 0
		die()
	

