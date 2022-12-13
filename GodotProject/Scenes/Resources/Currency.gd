class_name Currency
extends Node

signal resource_changed

# Base currency. Change the name if we must.
var amount: int = 0

export var starting_amount := 30

func _ready() -> void:
	Global.currency_tracker = self
	var _err = connect("resource_changed", Global.hud, "update_amount")
	update_amount(starting_amount)


func update_amount(new_amount: int = 1) -> void:
	amount += new_amount
	emit_signal("resource_changed", amount)


func get_amount() -> int:
	return amount
