extends PopupPanel


var tower_base

signal demolition_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(myTowerBase):
	tower_base = myTowerBase
	if tower_base.has_method("_on_demolition_requested"):
		if not is_connected("demolition_requested", tower_base, "_on_demolition_requested"):
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

func get_upgrade_count() -> int:
	var upgradeCount = 0
	for upgradeType in Global.UpgradeTypes.values():
		if tower_base.turret.upgrades[upgradeType] == true:
			upgradeCount += 1
	return upgradeCount
	
	

func _on_upgrade_selected(_upgradeType):
	var cost_reference: CostReference = CostReference.new()
	cost_reference.tower = tower_base
	var price = cost_reference.get_upgrade_price(get_upgrade_count()-1) # -1 to prevent double billing.
		
	Global.currency_tracker.update_amount(-1*price)
	Global.resume()
	hide()
	


func _on_TowerUpgradePopupDialog_about_to_show():
	var num_upgrades = 0
	for button in $MarginContainer/VBoxContainer/TowerUpgrades.get_children():
		if tower_base.turret.upgrades[button.upgrade_type] == true:
			button.disable_upgrade_button()
			num_upgrades += 1
	if num_upgrades == 3:
		$MarginContainer/VBoxContainer/TowerUpdatesLabel.hide()
		$MarginContainer/VBoxContainer/TowerUpgrades.hide()
	else:
		var cost_reference: CostReference = CostReference.new()
		cost_reference.tower = tower_base
		var price = cost_reference.get_upgrade_price(num_upgrades)
		var cash_available = Global.currency_tracker.sun
		
		
		if price > cash_available:
			$MarginContainer/VBoxContainer/TowerUpdatesLabel.text = "I love this tower, but I can't afford any upgrades. I need " + str(price) + ", but I only have " + str(cash_available)
			$MarginContainer/VBoxContainer/TowerUpdatesLabel.show()
			$MarginContainer/VBoxContainer/TowerUpgrades.hide()
		else:
			$MarginContainer/VBoxContainer/TowerUpdatesLabel.text = "I love this tower. Let's upgrade for " + str(price) + " ichor."
			if not $MarginContainer/VBoxContainer/TowerUpgrades.is_visible_in_tree():
				$MarginContainer/VBoxContainer/TowerUpgrades.show()
	
