class_name CurrencyManager
extends Node
# Manages all currency as child node.


func _ready() -> void:
	Global.currency_tracker = self


func update_amount(node_name: String, new_amount: int = 1) -> void:
	for node in get_children():
		if node.name == node_name:
			if node.has_method("update_amount"):
				node.update_amount(new_amount)


func get_value(node_name: String) -> int:
	for node in get_children():
		if node is Currency and node.name == node_name:
			return node.amount
		else:
			return 0
	return 0
