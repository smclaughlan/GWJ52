# Template for objects that are pickable
extends Area2D

func _ready() -> void:
	connect("body_entered", Global.player, "on_PickableObjects_body_entered")

