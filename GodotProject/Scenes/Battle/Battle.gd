extends Node2D


export var starting_currency = 30

onready var extents = $Extents.get_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	if starting_currency > $Currency.sun:
		$Currency.update_amount( starting_currency )
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
