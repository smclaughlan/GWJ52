class_name Currency
extends Node
# A currency node.
# Stores the name for which the 
signal resource_changed
# Base currency. Change the name if we must.
var amount: int = 0

export var starting_amount := 30
export var method_name: String = ""

func _ready() -> void:
	# Connects this node to the HUD with the value in method name.
	# Makes it more dynamic for multiple resources in the future.
	if method_name != "":
		var _err = connect("resource_changed", Global.hud, method_name)
	update_amount(starting_amount)


func update_amount(new_amount: int = 1) -> void:
	amount += new_amount
	emit_signal("resource_changed", amount)


func get_amount() -> int:
	return amount
