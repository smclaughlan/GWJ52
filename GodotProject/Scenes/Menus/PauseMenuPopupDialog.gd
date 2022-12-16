extends PopupDialog


export var audio_bus_name := "Master"
onready var _bus := AudioServer.get_bus_index(audio_bus_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	find_node("VolumeSlider").value = db2linear(AudioServer.get_bus_volume_db(_bus))
	$MarginContainer/VBoxContainer/SecretDebugOptions.hide()

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	
func _unhandled_input(_event):
	if Input.is_action_just_pressed("debug"):
		$MarginContainer/VBoxContainer/SecretDebugOptions.show()

func _on_ResumeButton_pressed():
	Global.resume()
	self.hide()


func _on_QuitButton_pressed():
	Global.resume()
	Global.stage_manager.return_to_main()


func _on_FreeMoneyButton_pressed():
	Global.currency_tracker.update_amount(100)


func _on_BonusHealthButton_pressed():
	Global.player.health += 1000
	Global.player.max_health += 1000


func _on_DieNowButton_pressed():
	$WhistleNoise.play()
	Global.player.health = 1
	var explosion = load("res://Scenes/Objects/Projectiles/AOEProjectile2.tscn").instance()
	Global.current_map.add_child(explosion)
	explosion.init(Global.player.global_position + (Vector2(-250, -250)), PI/4)
	
	Global.player._on_hit(100000, Vector2.ZERO, {} )
	Global.resume()
	hide()


func _on_SpawnCreepsButton_pressed():
	for _i in range(30):
		var creepScenes = [
			"res://Scenes/Enemies/Creep.tscn",
			"res://Scenes/Enemies/Creep2Bigger.tscn",
			"res://Scenes/Enemies/Creep3Faster.tscn",
		]
		var creep = load(creepScenes[randi()%creepScenes.size()]).instance()
		Global.current_map.add_child(creep)
		var randLocation = (Vector2.ONE*rand_range(150, 500)).rotated(rand_range(-PI,PI))
		creep.init(Global.player.global_position + randLocation, null)
		Global.resume()
		hide()
		


func _on_Button_toggled(button_pressed):
	Global.enable_fps_counter = button_pressed
	Global.show_fps_counter()
