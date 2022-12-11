extends Area2D



func _on_PickupRadius_area_entered(area: Area2D) -> void:
	set_pickable_on_pickup(area, true)


func _on_PickupRadius_area_exited(area: Area2D) -> void:
	set_pickable_on_pickup(area, false)


func set_pickable_on_pickup(area: Area2D, value: bool) -> void:
	if area.has_method("set_on_pickup"):
		area.on_pickup_radius = value
