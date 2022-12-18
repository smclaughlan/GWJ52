extends Button



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_QuitButton_pressed():
	$ClickNoise.play()
	
	


func _on_QuitButton_mouse_entered():
	$HoverNoise.play()


func _on_ClickNoise_finished():
	get_tree().quit()
