"""
Tracks currency
"""
extends Node

signal resource_changed

# Base currency. Change the name if we must.
var sun: int = 0

func _ready() -> void:
	Global.currency_tracker = self
	var _err = connect("resource_changed", Global.hud, "update_sun")


func update_amount(new_amount: int = 1) -> void:
	sun += new_amount
	emit_signal("resource_changed", sun)


func get_amount() -> int:
	return sun
