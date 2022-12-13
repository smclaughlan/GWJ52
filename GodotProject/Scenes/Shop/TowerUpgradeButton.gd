extends VBoxContainer

var tower_base

const Upgrade_Types = Global.UpgradeTypes
export (Upgrade_Types) var upgrade_type = Upgrade_Types.BIGGER
#export var label_text = "Bigger"


#export var extra_health : float = 0.0
#export var reload_reduction_factor : float = 1.0
#export var new_bullet_scene : PackedScene
#enum spread_patterns { LINE, CONE, WAVE }
#export(spread_patterns) var spread_pattern = spread_patterns.LINE
#export var damage_attribute : Dictionary = {
#	"poison":false,
#	"fire":false,
#	"electricity":false,
#	"armor_piercing":false,	
#}

signal upgrade(property)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(myTowerBase):
	tower_base = myTowerBase
	$UpgradeLabel.text = str(get_position_in_parent())
	$UpgradeLabel.text += " " + Upgrade_Types.keys()[upgrade_type].capitalize()

	if tower_base == null:
		printerr("config error in TowerUpgradeButton.. unknown tower base")
	else:
		if not is_connected("upgrade", tower_base, "_on_upgrade_requested"):
			var _err = connect("upgrade", tower_base, "_on_upgrade_requested")



func _on_UpgradeButton_pressed():
	# send a signal to the tower base
	emit_signal("upgrade", upgrade_type)
	
