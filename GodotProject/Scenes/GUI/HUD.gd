extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player

onready var sun_amount = $header/Currency/Sun/SunAmount
onready var power = $header/Currency/Power/SunAmount

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hud = self

func init(myPlayer):
	player = myPlayer


func _on_ActionButton_pressed(action : String):
	if action in [ "melee", "range", "build" ] and player != null and is_instance_valid(player):
		player.set_tool(action)
	elif action == "shop":
		$ShoppingPopupPanel.popup()
	

func update_sun(sun: int) -> void:
	sun_amount.text = str(sun)


func update_power(_power:int) -> void:
	power.text = str(_power)


func _on_PauseButton_pressed():
	$PauseMenuPopupDialog.popup_centered_ratio(0.75)
	Global.pause()
