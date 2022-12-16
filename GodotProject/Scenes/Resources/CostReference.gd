extends Reference
class_name CostReference

var cost: int = 0
var tower: Object = null

func can_purchase() -> bool:
	return cost <= Global.currency_tracker.sun

func get_upgrade_price(num_upgrades):
	return 10 * (num_upgrades+1)
