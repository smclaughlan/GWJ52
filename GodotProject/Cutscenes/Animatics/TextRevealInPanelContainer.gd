tool
extends PanelContainer

export var text : String setget set_label_text

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint: # running in-game
		$Label.text = text

func start():
	$AnimationPlayer.play("RevealText")



	
func set_label_text(myText):
	if Engine.editor_hint: # running in godot editor, not in-game
		$Label.text = myText


func _on_AnimationPlayer_animation_finished(_anim_name):
	pass # Replace with function body.
