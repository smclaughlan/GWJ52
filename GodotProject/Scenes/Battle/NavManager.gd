extends Node

export(NodePath) onready var nav_mesh = get_node(nav_mesh)


func _ready():
	Global.nav_manager = self

func cut_from_nav(polygon : CollisionPolygon2D):
	var new_polygon = PoolVector2Array()
	var navigation_polygon = nav_mesh.get_navigation_polygon()
	var polygon_transform = polygon.get_global_transform()
	var polygon_bp = polygon.get_polygon()
	for vertex in polygon_bp:
		new_polygon.append(polygon_transform.xform(vertex))
	navigation_polygon.add_outline(new_polygon)
	navigation_polygon.make_polygons_from_outlines()
	nav_mesh.set_navigation_polygon(navigation_polygon)
	nav_mesh.enabled = false
	nav_mesh.enabled = true

func add_back_to_nav(polygon : CollisionPolygon2D):
	var new_polygon = PoolVector2Array()
	var polygon_transform = polygon.get_global_transform()
	var polygon_bp = polygon.get_polygon()
	var navigation_polygon = nav_mesh.get_navigation_polygon()
	for vertex in polygon_bp:
		new_polygon.append(polygon_transform.xform(vertex))
	for outline in navigation_polygon.get_outline_count():
		if navigation_polygon.get_outline(outline) == new_polygon:
			navigation_polygon.remove_outline(outline)
			break
	navigation_polygon.make_polygons_from_outlines()
	nav_mesh.set_navigation_polygon(navigation_polygon)
	nav_mesh.enabled = false
	nav_mesh.enabled = true
