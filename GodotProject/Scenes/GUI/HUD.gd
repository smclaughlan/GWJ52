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
		$ExtraInstructionsPanel/ExtraInstructions.text = "Press < , > to change tower type."
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
	$ExtraInstructionsPanel/ExtraInstructions.text = prevTower + " <  [ " + currentTower +  " ] > " + nextTower 
	
	

func update_sun(sun: int) -> void:
	$Footer/HBoxContainer/Mana/IchorAmount.text = str(sun)
	$Footer/HBoxContainer/Mana.value = float(sun)/100.0
	# if mana hits 100, should win automatically

func update_health() -> void:
	$Footer/HBoxContainer/Health.value = float(Global.player.health) / float(Global.player.max_health)
	$Footer/HBoxContainer/Health/HealthAmount.text = str(Global.player.health)

func _on_PauseButton_pressed():
	$PauseMenuPopupDialog.popup_centered_ratio(0.75)
	Global.pause()


func _on_UpdateTimer_timeout():
	update_health()

func _on_tower_type_blueprint_changed(currentTowerType):
	change_tower_instructions(currentTowerType)
