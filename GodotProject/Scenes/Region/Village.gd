# note: this is just a placeholder.
# we're hoping to have a more extensive village in the release version,
# complete with NPCs and shops and stuff.


extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.village = self
	Global.village_location = self.get_global_position()

func get_random_golem(): # creeps need to know who to attack.
	# This isn't needed. Creeps already get a list of "houses" aka golems from the group called "village"
	var golems = $Golemms.get_children()
	var randGolem = golems[randi()%golems.get_child_count()]
	return randGolem

func get_spare_golem_count():
	var possibleGolemsRemaining = $Golems.get_children()
	var actualGolemsRemaining = 0
	for golem in possibleGolemsRemaining:
		if not golem.is_dead():
			actualGolemsRemaining += 1
	return actualGolemsRemaining

func _on_golem_died():
	if get_spare_golem_count() == 0:
		# possible lose condition.
		if Global.player.State == Global.player.States.GHOST:
			# trigger lose condition
			Global.stage_manager.lose()
		
