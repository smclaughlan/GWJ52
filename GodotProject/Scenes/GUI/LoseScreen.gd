extends Node2D

func _ready():
	$AnimationPlayer.queue("lose_loop")

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and $AnimationPlayer.current_animation == "lose_loop":
		get_tree().change_scene("res://Main.tscn")
