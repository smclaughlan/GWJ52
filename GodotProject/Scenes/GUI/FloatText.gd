extends Node2D

onready var tween = $Tween
onready var label_text = $LabelText


# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2(global_position.x, global_position.y - 100)
	var go_left = (randi() % 2) == 0
	var randomX = randi() % 150
	var randomY = randi() % 150
	var new_position = Vector2.ZERO
	if go_left:
		new_position = Vector2(global_position.x - randomX, global_position.y - 50)
	else:
		new_position = Vector2(global_position.x + randomX, global_position.y - 50)
	var new_rotation = rand_range(-0.5, 0.5)
	var new_color = Color(1, 1, 1, 0)
	tween.interpolate_property(self, "global_position", global_position, new_position, 1)
	tween.interpolate_property(self, "global_rotation", global_rotation, new_rotation, 1)
	tween.interpolate_property(self, "modulate", modulate, new_color, 1)
	tween.start()


func set_text(_text):
	if typeof(_text) == TYPE_INT or typeof(_text) == TYPE_REAL:
		label_text.text = "-" + String(_text)
		var new_global_scale = get_global_scale()
		new_global_scale = Vector2(max(new_global_scale.x * _text * 0.1, 1), max(new_global_scale.y * _text * 0.1, 1))
		set_global_scale(new_global_scale)
	else:
		label_text.text = _text

func _on_DeleteTimer_timeout():
	queue_free()
