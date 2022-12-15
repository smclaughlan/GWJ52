extends PopupPanel


var tower_base

signal demolition_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(myTowerBase):
	tower_base = myTowerBase
	if tower_base.has_method("_on_demolition_requested"):
		var _err = connect("demolition_requested", tower_base, "_on_demolition_requested")
	else:
		printerr("Configuration error in TowerUpgradePopupMenu. Are you connected to a tower?")

	for upgradeOption in find_node("TowerUpgrades").get_children():
		upgradeOption.init(tower_base, self)

	
func _on_DeconstructButton_pressed():
	Global.resume()
	Global.currency_tracker.update_amount(10)
	emit_signal("demolition_requested")
	hide()


func _on_CloseButton_pressed():
	Global.resume()
	hide()

func _on_upgrade_selected(_upgradeType):
	Global.resume()
	hide()
	


func _on_TowerUpgradePopupDialog_about_to_show():
	var disabled_button_count = 0
	for button in $MarginContainer/VBoxContainer/TowerUpgrades.get_children():
		if tower_base.turret.upgrades[button.upgrade_type] == true:
			button.disable_upgrade_button()
			disabled_button_count += 1
	if disabled_button_count == 3:
		$MarginContainer/VBoxContainer/TowerUpdatesLabel.hide()
		$MarginContainer/VBoxContainer/TowerUpgrades.hide()
	
	
