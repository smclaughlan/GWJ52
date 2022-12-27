"""
Acts like a menu interface?
Actual Costs are stored inside tower objects.
Do we need this?
"""

extends Reference
class_name CostReference

var cost: int = 0
var tower: Object = null

func can_purchase() -> bool:
	if Global.currency_tracker != null:
		if cost <= Global.currency_tracker.ichor:
			return true
		else:
			return false
	else:
		return true

func get_upgrade_price(num_upgrades):
	return 10 * (num_upgrades+1)
