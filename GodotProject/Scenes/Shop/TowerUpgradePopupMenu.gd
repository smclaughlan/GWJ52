extends PopupPanel


var tower

signal demolition_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(myTower):
	tower = myTower
	if tower.has_method("_on_demolition_requested"):
		var _err = connect("demolition_requested", tower, "_on_demolition_requested")
	else:
		printerr("Configuration error in TowerUpgradePopupMenu. Are you connected to a tower?")
	
func _on_DeconstructButton_pressed():
	Global.resume()
	Global.currency_tracker.update_amount(10)
	emit_signal("demolition_requested")
	hide()
