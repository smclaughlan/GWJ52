# Spawns object based on the drop object of the class who calls it.

extends Node2D


func _ready() -> void:
	Global.pickable_object_spawner = self


func spawn_pickable(pickable_object: Object, position: = Vector2.ZERO) -> void:
	var new_pickable: Object = pickable_object.instance()
	Global.current_map.find_node("YSort").call_deferred("add_child", new_pickable)
	new_pickable.position = position

func _on_creep_died(_creep, pickableLoot, locationOfDeath):
	# we don't actually care who it was. Poor Timmy (other methods need to know)
	spawn_pickable(pickableLoot, locationOfDeath)
	
func _on_spawner_died(_spawner, pickableLoot, locationOfDeath):
	for _i in range(5):
		spawn_pickable(pickableLoot, locationOfDeath)

func _on_spawner_hit(_spawner, pickableLoot, locationOfSpawner):
	spawn_pickable(pickableLoot, locationOfSpawner)
	

