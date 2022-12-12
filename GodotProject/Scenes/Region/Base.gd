extends Node2D

var player_present : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.power_source = $TowerTurret/TowerWireSockets


func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_present == true:
		shop()


func shop():
	$ShoppingMall/InteractArea/AudioStreamPlayer2D.play()
	$ShoppingMall/InteractArea/Fullscreen/ShoppingPopupPanel.popup_centered_ratio(0.75)
	Global.pause()
	# Engine.set_time_scale( 0.1 ) # why doesn't this work?!?



func _on_InteractArea_body_entered(body):
	if body == Global.player:
		$ShoppingMall/InteractArea/InteractLabel.show()
		player_present = true
	



func _on_InteractArea_body_exited(body):
	if body == Global.player:
		$ShoppingMall/InteractArea/InteractLabel.hide()
		player_present = false

