extends PickableObject


func _ready() -> void:
	connect("picked", Global.currency_tracker, "update_amount")
