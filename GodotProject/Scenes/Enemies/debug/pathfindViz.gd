extends Node2D


func _on_Timer_timeout():
	queue_free()


func _on_Timer_ready():
	$Timer.start(1 + rand_range(1, 3))
