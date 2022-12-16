extends Node2D


export var starting_currency = 30
var first_three_tower_counter = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.battle_map = self
	if starting_currency > $Currency.sun:
		$Currency.update_amount( starting_currency )
		

func first_three_towers() -> void:
	if first_three_tower_counter == 0:
		$WaveManager.prepare_new_wave()
	if first_three_tower_counter > 0:
		first_three_tower_counter -= 1
