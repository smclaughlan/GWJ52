extends Node2D


export var starting_currency = 30
var first_three_tower_counter = 3

onready var extents = $Extents.get_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.battle_map = self
	if starting_currency > $Currency.sun:
		$Currency.update_amount( starting_currency )
		

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
	# spawn two spawner spawners and start the 1st wave.
	$SpawnerSpawner.enable()
	$SpawnerSpawner2.enable()
	
func first_three_towers() -> void:
	if first_three_tower_counter == 0:
		$WaveManager.prepare_new_wave()
	if first_three_tower_counter > 0:
		first_three_tower_counter -= 1
