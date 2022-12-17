extends Node

signal difficulty_changed

# The current multiplier that affects the creep's stats. When the wave starts, it
# starts to increment the value by 0.15 in that case, the first wave multiplier is 1.0
export var difficulty_multiplier:float = 0.85

func _ready() -> void:
	# Set the global node
	Global.difficulty_controller = self


# Increase the difficulty. If passed with zero parameters use the default
# value.
func increase_difficulty(ramp_amount: float = 0.15) -> void:
	difficulty_multiplier += ramp_amount
