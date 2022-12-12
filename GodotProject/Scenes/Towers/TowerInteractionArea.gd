extends Area2D


var player_present : bool = true # probably starts with the player near the tower
var tower

signal demolition_requested


# Called when the node enters the scene tree for the first time.
func _ready():
	tower = get_parent()
	if tower.has_method("_on_demolition_requested"):
		var _err = connect("demolition_requested", tower, "_on_demolition_requested")


func _unhandled_input(event):
	if player_present and event.is_action_pressed("interact"):
		$CanvasLayer/PopupDialog.popup_centered_ratio(0.66)
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


func _on_DeconstructButton_pressed():
	Global.resume()
	Global.currency_tracker.update_amount(10)
	emit_signal("demolition_requested")
	hide()
	


func _on_PopupDialog_about_to_show():
	# tell the player to pause their tools.
	pass
	
	
