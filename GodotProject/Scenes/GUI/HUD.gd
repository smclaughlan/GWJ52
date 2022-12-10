extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ActionButton_pressed(action : String):
	if action in [ "melee", "range", "build" ]:
		Global.player.set_tool(action)
	elif action == "shop":
		$ShoppingPopupPanel.popup()
	
