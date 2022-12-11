"""
Tracks currency
"""
extends Node

signal resource_changed

# Base currency.
var sun: int = 0

func _ready() -> void:
	Global.currency_tracker = self
	connect("resource_changed", Global.hud, "update_sun")


func update_amount(new_amount: int = 1) -> void:
	sun += new_amount
	emit_signal("resource_changed", sun)
