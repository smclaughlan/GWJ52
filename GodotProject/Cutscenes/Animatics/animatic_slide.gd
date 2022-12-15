extends TextureRect




export (String, MULTILINE) var text_to_reveal : String
onready var text_label = $TextPanel/TextToReveal



func start():
	text_label.text = text_to_reveal
	$AnimationPlayer.play("RevealText")

func is_playing():
	return $AnimationPlayer.is_playing()

func reveal_all_text():
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
		$TextPanel/TextToReveal.set_percent_visible(1.0)
		$SpaceToContinue.show()
		
