extends Node2D


func _ready():
	$Sound.play()

func _on_Timer_timeout():
	queue_free()
