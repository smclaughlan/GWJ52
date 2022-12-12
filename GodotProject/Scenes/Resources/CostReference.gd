extends Reference
class_name CostReference

var cost: int = 0
var tower: Object = null

func can_purchase() -> bool:
	return cost <= Global.currency_tracker.sun
