extends CanvasLayer

var fog_color = Color(0.05,0.2,0.1,1.0)
var invisible_fog_color = Color(0.05,0.1,0.2,0.0)
var fade_duration = 1.5 # seconds to fade out = 1/2 of a complete fade out+in
onready var tab_container = $Control/TabContainer

export var next_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimationPlayer.play("intro_exposition")
	audio_fade_in() # audio comes first, otherwise we'll be yielding for the fog.
	fade_in()
	tab_container.current_tab = 0
	
func audio_fade_in():
	var tween = get_node("Tween")
	tween.interpolate_property($Music, "volume_db",
		-20, 0, fade_duration*2.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	
func fade_out():
	$FogFade.visible = true
	var tween = get_node("Tween")
	tween.interpolate_property($FogFade, "self_modulate",
		Color(0.05,0.2,0.1,1.0), Color(0.05,0.2,0.1,0.0), fade_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")

func fade_in():
	var tween = get_node("Tween")
	tween.interpolate_property($FogFade, "self_modulate",
		fog_color, invisible_fog_color, fade_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	$FogFade.visible = false


func _unhandled_input(_event):
	if Input.is_action_just_pressed("next_slide"):
		var slide = tab_container.get_current_tab_control()
		if slide.has_method("is_playing") and slide.is_playing():
			slide.reveal_all_text()
		else:
			show_next_slide()
	elif Input.is_action_just_pressed("prev_slide"):
		show_previous_slide()
	elif Input.is_action_just_pressed("ui_cancel"):
		Global.stage_manager.change_scene(next_scene)


func show_previous_slide():
		fade_out()
		tab_container.current_tab -= 1
		if tab_container.current_tab < 0:
			tab_container.current_tab = 0 # no need to wrap around
		fade_in()
			
func show_next_slide():
	if tab_container.current_tab < tab_container.get_child_count()-1:
		fade_out()
		tab_container.current_tab += 1
		var slide = tab_container.get_current_tab_control()
		if slide.has_method("start"):
			slide.start()
		fade_in()
	else: # past last slide. Go to the next scene.
		Global.stage_manager.change_scene(next_scene)
			
