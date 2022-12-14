extends TextureRect



export (String, MULTILINE) var text_to_reveal : String
onready var text_label = $TextPanel/TextToReveal



func start():
	text_label.text = text_to_reveal
	$AnimationPlayer.play("RevealText")
