"""
Tracks currency

See also: CostReference class from CostReference.gd
"""
extends Node

signal ichor_amount_changed(amount)
signal crystals_amount_changed(amount)

# Base currency. Change the name if we must.
export var starting_ichor: int = 100

var ichor: int = starting_ichor setget add_ichor, get_ichor# energy, mana, building materials: to be used inside a level. Gained by killing creeps
var crystals: int = 0 setget add_crystals, get_crystals # currency to be used between levels to upgrade character, unlock items, etc. Gained by mining gems.

# note: crystals will have to be saved as a persistent resource.

func _ready() -> void:
	Global.currency_tracker = self


func add_ichor(new_amount: int = 8) -> void:
	if not is_connected("ichor_amount_changed", Global.hud, "update_ichor"):
		var _err = connect("ichor_amount_changed", Global.hud, "update_ichor")
	ichor += new_amount
	emit_signal("ichor_amount_changed", ichor) # update the hud


func add_crystals(numCrystals: int = 1) -> void:
	if not is_connected("crystals_amount_changed", Global.hud, "_on_crystals_amount_changed"):
		var _err = connect("crystals_amount_changed", Global.hud, "_on_crystals_amount_changed")
	crystals += numCrystals
	emit_signal("crystals_amount_changed", crystals)


func get_ichor() -> int:
	return ichor
	
func get_crystals() -> int:
	return crystals

func _on_tower_built(cost):
	add_ichor(-cost)
	
