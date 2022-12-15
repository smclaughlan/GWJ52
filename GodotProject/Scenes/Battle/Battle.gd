extends Node2D


export var starting_currency = 30

onready var extents = $Extents.get_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	if starting_currency > $Currency.sun:
		$Currency.update_amount( starting_currency )
			

func get_random_dangerous_location():
	assert(false) # deprecated. Not working.
	
#	var found = false
#	var count = 0
#	var escape = 100
#	while not found and count < escape:
#		var testLocation = Vector2(randi()%int(extents.size.x),  randi()%int(extents.size.y))-extents.position
#		if extents.has_point(testLocation) and !$SafeZone.has_point(testLocation):
#			found = true
#			return testLocation
#		count += 1
#		if count%10 == 0:
#			printerr("Battle.gd, get_random_dangerous_location(). uh oh, this doesn't seem right. " + str(count) + " " + str(testLocation))
#
#	if count > 90:
#		printerr("Nope.")
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_tutorial_ended():
	# spawn two spawner spawners and start the 1st wave.
	$SpawnerSpawner.enable()
	$SpawnerSpawner2.enable()
	
	
