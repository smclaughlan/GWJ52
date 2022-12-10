extends Control

export var first_scene = preload("res://Scenes/Menus/MainMenu.tscn")
var fade_node : TextureRect
var fade_duration = 0.5

var current_map

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	Global.stage_manager = self
	fade_node = $FadeRect

	change_scene(first_scene)
	
	



func change_scene(newScene : PackedScene):
	fade_out(fade_duration)
	for child in $CurrentScene.get_children():
		if child.has_method("die"):
			child.die()
		else:
			child.queue_free()
	if newScene != null:
		current_map = newScene.instance()
		Global.current_map = current_map
		$CurrentScene.add_child(current_map)
		fade_in(fade_duration)
	else:
		printerr("Main.gd.change_scene() error. No target scene to change to.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func fade(startColor, fadeDuration):
	var tween = get_tree().create_tween() # SceneTreeTween
	fade_node.set_self_modulate(startColor)
	var endColor = startColor
	if startColor.a < 0.5:
		endColor.a = 1.0
	else:
		endColor.a = 0.0
	tween.tween_property(fade_node, "self_modulate", endColor, fadeDuration) # starts automatically

func fade_in(fadeDuration : float):
	fade(Color(.5,.5,.5,1), fadeDuration)

func fade_out(fadeDuration : float):
	fade(Color(.5,.5,.5,0), fadeDuration)


func return_to_main():
	change_scene(first_scene)

func _on_scene_change_requested(new_scene : PackedScene):
	change_scene(new_scene)
