extends Area2D


var player_present : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
