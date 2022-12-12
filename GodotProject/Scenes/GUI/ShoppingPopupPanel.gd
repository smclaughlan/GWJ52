extends PopupPanel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CloseButton_pressed():
	hide()


func _on_ShoppingPopupPanel_popup_hide():
	Global.resume()
	#Engine.set_time_scale(1.0) # Why doesn't this work?!?
