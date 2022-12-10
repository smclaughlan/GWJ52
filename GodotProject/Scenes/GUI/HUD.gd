extends CanvasLayer

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myPlayer):
	player = myPlayer


func _on_ActionButton_pressed(action : String):
	if action in [ "melee", "range", "build" ] and player != null and is_instance_valid(player):
		player.set_tool(action)
		print(action)
	elif action == "shop":
		$ShoppingPopupPanel.popup()
	
