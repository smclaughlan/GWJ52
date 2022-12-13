extends Area2D


var player_present : bool = false # probably starts with the player near the tower
var tower_base # not the same as a tower turret, but the base knows about the turret
var upgrade_popup_dialog

#signal demolition_requested # moved to TowerUpgradePopupDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$InteractLabel.hide()
	tower_base = get_parent()
	upgrade_popup_dialog = find_node("TowerUpgradePopupDialog")
	upgrade_popup_dialog.init(tower_base)
	
	if get_overlapping_bodies().has(Global.player):
		player_present = true
		$InteractLabel.show()
		


func _unhandled_input(event):
	if player_present and event.is_action_pressed("interact"):
		upgrade_popup_dialog.popup_centered_ratio(0.66)
		Global.pause()


func _on_InteractArea_body_entered(body):
	if body == Global.player:
		player_present = true
		$InteractLabel.show()


func _on_PopupDialog_popup_hide():
	Global.resume()


func _on_InteractArea_body_exited(body):
	if body == Global.player:
		player_present = false
		$InteractLabel.hide()



	


func _on_PopupDialog_about_to_show():
	# tell the player to pause their tools.
	pass
	
	
