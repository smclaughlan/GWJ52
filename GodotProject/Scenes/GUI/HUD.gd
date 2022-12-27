extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hud = self

func init(myPlayer):
	player = myPlayer


func _on_ActionButton_pressed(action : String):
	if action in [ "melee", "range", "build", "flashlight" ] and player != null and is_instance_valid(player):
		player.set_tool(action)
	if action == "build":
		$ExtraInstructionsPanel/VBoxContainer/ExtraInstructions.text = "Press Q , E to change tower type."
		$ExtraInstructionsPanel.show()
	else:
		$ExtraInstructionsPanel.hide()
		
#	elif action == "shop":
#		$ShoppingPopupPanel.popup()

func change_tower_instructions(towerType):
	var towerTypes = Global.TowerTypes.keys()
	var prevTower = towerTypes[(towerType-1) % towerTypes.size()]
	var currentTower = towerTypes[towerType]
	var nextTower = towerTypes[(towerType+1) % towerTypes.size()]
	var instructionText : String
	
	if Global.currency_tracker != null and Global.currency_tracker.ichor >= 10:
		instructionText = prevTower + " <  [ " + currentTower +  " ] > " + nextTower 
	else:
		instructionText = "Insufficient Ichor Reserves to build a tower.\nChoose another tool below and collect more Ichor."
	find_node("ExtraInstructions").text = instructionText
	
	

func update_ichor(ichor: int) -> void:
	$Footer/HBoxContainer/Mana/IchorAmount.text = str(ichor)
	$Footer/HBoxContainer/Mana.value = float(ichor)/Global.ichor_required_to_win
	$Footer/HBoxContainer/Mana/WinInstructionLabel.text = "To Defeat the Strife\nCollect " + str(Global.ichor_required_to_win) + " ichor."
	if ichor < 10:
		var instructionText = "Insufficient Ichor Reserves to build a tower.\nChoose another tool below and collect more Ichor."
		find_node("ExtraInstructions").text = instructionText

	# Trigger end-of-tutorial, player has built and upgrades initial towers
	if ichor <= 80 and Global.current_map.tutorial_ended == false:
		Global.current_map._on_tutorial_ended()
		
	# if mana hits _some_value_, should win automatically
	if ichor >= Global.ichor_required_to_win:
		Global.stage_manager.win()


func update_health() -> void:
	$Footer/HBoxContainer/Health.value = float(Global.player.health) / float(Global.player.max_health)
	$Footer/HBoxContainer/Health/HealthAmount.text = str(Global.player.health)




func _on_PauseButton_pressed():
	var pauseMenu = $PauseMenuPopupDialog
	if pauseMenu.visible == false:
		pauseMenu.popup_centered_ratio(0.75)
		Global.pause()
	else:
		Global.resume()
		pauseMenu.hide()
		



func _on_UpdateTimer_timeout():
	update_health()

func _on_tower_type_blueprint_changed(currentTowerType):
	change_tower_instructions(currentTowerType)

func _on_creep_wave_started(_location):
	#$ThreatInfoContainer.alert()
	# moved to when glem is attacked
	pass

func _on_golem_attacked():
	$ThreatInfoContainer.alert()
	
	

func _on_tutorial_ended():
	$ExtraInstructionsPanel/VBoxContainer/Tutorial.hide()

func _on_crystals_amount_changed(amount):
	$Header/Crystals/CrystalValue.text = str(amount)
