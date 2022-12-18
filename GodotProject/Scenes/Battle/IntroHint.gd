extends Node2D

var is_showing = true

func _ready():
	pass # Replace with function body.


func _on_BlinkTimer_timeout():
	is_showing = !is_showing
	if is_showing:
		show()
	else:
		hide()


func _on_TurnOffTimer_timeout():
	hide()
	$BlinkTimer.stop()
	$TurnOffTimer.stop()
