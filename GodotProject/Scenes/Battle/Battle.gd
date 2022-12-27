extends Node2D


export var starting_currency = 100

onready var extents = $Extents.get_rect()

var tutorial_ended : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Change the seed
	randomize()
	if starting_currency > $Currency.ichor:
		$Currency.add_ichor( starting_currency )
			

func audio_fade_in():
	var fade_duration = 3.0
	var tween = get_node("Tween")
	tween.interpolate_property($Music, "volume_db",
		-20, 0, fade_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	


	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_tutorial_ended():
	if not tutorial_ended:
		# spawn two spawner spawners and start the 1st wave.
		$SpawnerSpawner.enable()
		$SpawnerSpawner2.enable()
		tutorial_ended = true
	else:
		printerr("Why are you still getting tutorial ending signals in Battle.gd?")
	
