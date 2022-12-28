extends TileMap

export var crystal_pickup : PackedScene

signal gem_struck(me, loot, location)

func _on_pickaxe_struck_tile(global_coords, damage, _damageAttributes):
	var local_position = self.to_local(global_coords)
	var map_position = self.world_to_map(local_position)
	
	var tile = self.get_cellv(map_position)
	
	if tile != INVALID_CELL:
		var tileName = get_tileset().tile_get_name(tile)
		if "gem" in tileName.to_lower():
			mine_gem(map_position)


func mine_gem(tile_coords):
	var tileID = get_cellv(tile_coords)
	var tileName = get_tileset().tile_get_name(tileID)
	var autotile_coords = get_cell_autotile_coord(tile_coords.x, tile_coords.y)
	if autotile_coords == Vector2(1,1): # no gems left in this tile, but collision area might be slow to update
		return
	assert("gem" in tileName.to_lower())
	var local_coords = map_to_world(tile_coords) + Vector2(8,8)
	var global_coords = to_global(local_coords)
	if not is_connected("gem_struck", Global.pickable_object_spawner, "_on_gem_struck"):
		connect("gem_struck", Global.pickable_object_spawner, "_on_gem_struck")
	emit_signal("gem_struck", self, crystal_pickup, global_coords)
	
	var gem_num = int(tileName.right(1))
	var flip_x = false
	var flip_y = false
	var transpose = false
	
	# list of the tiles, in order that you want them changed to..
	# note, collision areas are not autoupdated.
	var ordered_autotile_coords = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]
	var next_autotile_index = ordered_autotile_coords.find(autotile_coords) +1
	if next_autotile_index < ordered_autotile_coords.size():
		var new_autotile_coord = ordered_autotile_coords[next_autotile_index]
		set_cell(tile_coords.x, tile_coords.y, tileID, flip_x, flip_y, transpose, new_autotile_coord)
	
