extends PopupDialog


export var audio_bus_name := "Master"
onready var _bus := AudioServer.get_bus_index(audio_bus_name)

var easy_toggled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	find_node("VolumeSlider").value = db2linear(AudioServer.get_bus_volume_db(_bus))
	$MarginContainer/VBoxContainer/SecretDebugOptions.hide()
	find_node("FullscreenButton").pressed = OS.window_fullscreen
	# Hide the easy button if the build is in `debug`
	if not OS.is_debug_build():
		$MarginContainer/VBoxContainer/CheatLabel.hide()


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))

func _unhandled_input(_event):
	if Input.is_action_just_pressed("debug"):
		show_cheat_options()

#	if Input.is_action_just_pressed("ui_cancel"):
#		hide()
#		yield(get_tree().create_timer(0.2), "timeout")
#		Global.resume()


func show_cheat_options():
	$MarginContainer/VBoxContainer/SecretDebugOptions.show()


func hide_cheat_options():
	$MarginContainer/VBoxContainer/SecretDebugOptions.hide()


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
	Global.current_map.find_node("YSort").add_child(explosion)
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
		var creepScene = creepScenes[randi()%creepScenes.size()]
		print(creepScene + " wave spawned")
		var creep = load(creepScene).instance()

		Global.current_map.find_node("YSort").add_child(creep)
		var randLocation = (Vector2.ONE*rand_range(150, 500)).rotated(rand_range(-PI,PI))
		creep.init(Global.player.global_position + randLocation)
		Global.resume()
		hide()



func _on_FPS_Button_toggled(button_pressed):
	Global.enable_fps_counter = button_pressed
	Global.show_fps_counter()


func start_wave():
	var availableSpawners = get_tree().get_nodes_in_group("EnemySpawners")
	if availableSpawners.size() > 0:
		var randomSpawner = availableSpawners[randi()%availableSpawners.size()]
		randomSpawner.start_wave_now()


func _on_StartWaveButton_pressed():
	Global.resume()
	var availableSpawners = get_tree().get_nodes_in_group("EnemySpawners")
	if availableSpawners.size() > 0:
		var randomSpawner = availableSpawners[randi()%availableSpawners.size()]
		randomSpawner.start_wave_now()
	else:
		var availableSpawnerSpawners = get_tree().get_nodes_in_group("SpawnerSpawners")
		if availableSpawnerSpawners.size() > 0:
			var randomSpawnerSpawner = availableSpawnerSpawners[randi()%availableSpawnerSpawners.size()]
			randomSpawnerSpawner.start_wave_now()

		yield(get_tree().create_timer(0.5), "timeout")
		start_wave()
	hide()



func _on_CheatLabel_pressed():
	if not easy_toggled:
		show_cheat_options()
		easy_toggled = true
	else:
		hide_cheat_options()
		easy_toggled = false


func _on_PauseMenuPopupDialog_popup_hide():
	Global.resume()


func _on_FullscreenButton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
