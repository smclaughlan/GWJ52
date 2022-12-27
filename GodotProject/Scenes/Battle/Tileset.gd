extends TileMap

export var crystal_pickup : PackedScene

signal gem_struck(me, loot, location)

func _on_pickaxe_struck_gem(global_coords, tileCoords, tile, damage):
	print("Tileset detected strike on gem at " + str(tileCoords) + " for tile: " + str(tile))
	
	if not is_connected("gem_struck", Global.pickable_object_spawner, "_on_gem_struck"):
		connect("gem_struck", Global.pickable_object_spawner, "_on_gem_struck")
	emit_signal("gem_struck", self, crystal_pickup, global_coords)
	
