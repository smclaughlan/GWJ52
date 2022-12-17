extends VBoxContainer

var tower_base

const Upgrade_Types = Global.UpgradeTypes
export (Upgrade_Types) var upgrade_type = Upgrade_Types.BIGGER

signal upgrade(property)


func init(myTowerBase, myDialogBox):
	tower_base = myTowerBase
	$UpgradeLabel.text = str(get_position_in_parent())
	$UpgradeLabel.text += " " + Upgrade_Types.keys()[upgrade_type].capitalize()

	if tower_base == null:
		printerr("config error in TowerUpgradeButton.. unknown tower base")
	else:
		if not is_connected("upgrade", tower_base, "_on_upgrade_requested"):
			var _err = connect("upgrade", tower_base, "_on_upgrade_requested")

	if not is_connected("upgrade", myDialogBox, "_on_upgrade_selected"):
		var _err = connect("upgrade", myDialogBox, "_on_upgrade_selected")



func _on_UpgradeButton_pressed():
	$ClickNoise.play()
	# send a signal to the tower base
	$UpgradeButton.set_disabled(true)
	emit_signal("upgrade", upgrade_type)
	
func disable_upgrade_button():
	$UpgradeButton.disabled = true
	self.hide()




func _on_UpgradeButton_mouse_entered():
	$HoverNoise.play()
