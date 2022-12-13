extends VBoxContainer

var tower
export var extra_health : float = 0.0
export var reload_reduction_factor : float = 1.0
export var new_bullet_scene : PackedScene
enum spread_patterns { LINE, CONE, WAVE }
export(spread_patterns) var spread_pattern = spread_patterns.LINE
export var damage_attribute : Dictionary = {
	"poison":false,
	"fire":false,
	"electricity":false,
	"armor_piercing":false,	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myTower):
	tower = myTower






func _on_UpgradeButton_pressed():
	# send a signal to the tower base with a brand new turret in the signal params
	# the tower base should then remove their old turret and drop the new one in place
	# Note: wiring sockets are on the turret, but they should light up automatically.
	
	var turretScene = load("res://Scenes/Objects/Towers/TowerTurret.tscn")
	var newTurret = turretScene.instance()
	newTurret.init()
	
	printerr("incomplete code in TowerUpgradeButton.gd")
	#emit_signal

	#tower.remove_old_turret()
	#tower.spawn_new_turret(upgrade_attributes)
	
