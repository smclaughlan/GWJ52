extends PickableObject


func _ready() -> void:
	var _err = connect("picked", Global.currency_tracker, "update_amount")
