extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sun_amount = $header/Currency/SunAmount

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hud = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ActionButton_pressed(action : String):
	if action in [ "melee", "range", "build" ]:
		Global.player.set_tool(action)
	elif action == "shop":
		$ShoppingPopupPanel.popup()
	

func update_sun(sun: int) -> void:
	sun_amount.text = str(sun)
