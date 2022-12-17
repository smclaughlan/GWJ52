"""
Tracks currency
"""
extends Node

signal resource_changed

# Base currency. Change the name if we must.
var sun: int = 0

func _ready() -> void:
	Global.currency_tracker = self
	var err = connect("resource_changed", Global.hud, "update_sun")


func update_amount(new_amount: int = 1) -> void:
	if not is_connected("resource_changed", Global.hud, "update_sun"):
		connect("resource_changed", Global.hud, "update_sun")
	sun += new_amount
	emit_signal("resource_changed", sun)


func get_amount() -> int:
	return sun
