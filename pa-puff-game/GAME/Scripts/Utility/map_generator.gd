extends Node2D
const HEX_SIZE = 10
const GEOJSON_PATH = "res://GAME/Ressources/Game Data/Map/france.geojson"
const NAME = "french"
const HEX_SCENE = preload("res://GAME/Scenes/Map/hexagon.tscn")

var country_polygons = []
var lon_max=-100000.0
var lon_min=100000.0
var lat_max=-100000.0
var lat_min=100000.0
var array_hex : Dictionary
var hex_map = []


func _ready():
	load_geojson()
	var root = Node2D.new()
	root.name = "Board"
	# add timer
	var timer = Timer.new()
	timer.name="Timer"
	timer.autostart = false
	timer.wait_time=0.1
	# add Script
	root.set_script(load("res://GAME/Scripts/Gameplay/map/board2.gd"))
	root.add_child(timer)
	timer.owner=root
		
	create_hex_grid(root)
	
	var packed_scene = PackedScene.new()
	var success = packed_scene.pack(root)
	if success == OK:
		# 4. Sauvegarder sur le disque
		ResourceSaver.save(packed_scene, "res://GAME/Scenes/Map/%s_board.tscn"%[NAME])
		print("Scène créée et sauvegardée !")
	else:
		print("Erreur lors de la création du PackedScene.")
	
	
func _process(delta: float) -> void:
	queue_redraw()
func _draw():
	for poly in country_polygons:
		draw_polygon(rectifing_polygone(poly), [Color.GREEN])
	
func load_geojson():
	var file = FileAccess.open(GEOJSON_PATH, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	if json == null:
		push_error("Erreur de parsing GeoJSON")
		return
	var features = json["features"]
	for feature in features:
		var geom = feature["geometry"]
		if geom["type"] == "Polygon":
			for ring in geom["coordinates"]:
				var poly = []
				for point in ring:
					poly.append(Vector2(point[0], -point[1])) # lon, lat
					lon_max=max(lon_max,point[0])
					lon_min=min(lon_min,point[0])
					lat_max=max(lat_max,-point[1])
					lat_min=min(lat_min,-point[1])
				country_polygons.append(poly)
		elif geom["type"] == "MultiPolygon":
			for polygon in geom["coordinates"]:
				for ring in polygon:
					var poly = []
					for point in ring:
						poly.append(Vector2(point[0], -point[1]))
						lon_max=max(lon_max,point[0])
						lon_min=min(lon_min,point[0])
						lat_max=max(lat_max,-point[1])
						lat_min=min(lat_min,-point[1])
					country_polygons.append(poly)

func is_point_inside_polygons(p: Vector2) -> bool:
	for poly in country_polygons:
		if Geometry2D.is_point_in_polygon(p, rectifing_polygone(poly)):
			return true
	return false
	
func rectifing_polygone(_poly: Array)-> Array:
	var array = []
	var box_width = 800
	var box_height= 400
	var poly_width =(lon_max-lon_min)
	var poly_height =(lat_max-lat_min)
	var scale = min(box_width / poly_width, box_height / poly_height)
	var center_lon = lon_min + poly_width / 2.0
	var center_lat = lat_min + poly_height / 2.0
	for point in _poly:
		array.append(Vector2((point[0]-center_lon)*scale*0.75, (point[1]-center_lat)*scale))
	return array
	
func add_hexagon (key : Vector2, value : StaticBody2D) :
	array_hex[key] = value
			
func create_hex_grid(root : Node2D):
	var width = sqrt(3) * HEX_SIZE
	var height = 2 * HEX_SIZE
	var horiz_spacing = width
	var vert_spacing = 1.5 * HEX_SIZE

	var min_x = -400
	var max_x = 400
	var min_y = -200
	var max_y = 200

	var n_del = 0
	var index = 0
	var r = 0
	while true:
		hex_map.append([])
		var y = r * vert_spacing
		if y + min_y > max_y:
			break
		var q = 0
		while true:
			var x = q * horiz_spacing + (r % 2) * horiz_spacing / 2.0
			if x + min_x > max_x:
				break
			
			var weight = 0.0
			var inf_A :float = 0.0
			var inf_B :float = 0.0
			var inf_C :float = 1.0
			var new_inf_A :float = 0.0
			var new_inf_B :float = 0.0
			var new_inf_C :float = 1.0
			var usineA : int =0
			var usineB : int =0
	
			
			var world_pos = Vector2(x + min_x, y + min_y)
			if is_point_inside_polygons(world_pos):
				weight = 1000.0
				var hex = HEX_SCENE.instantiate()
				hex.position = world_pos
				hex.HEX_RADIUS = HEX_SIZE
				hex.INDEX = index
				hex.ID = Vector2(q,r)
				hex.name = "%d,%d"%[q,r]
				hex.WEIGHT = randi_range(100, 10000)
				root.add_child(hex)
				hex.owner = root
				add_hexagon(Vector2(q,r),hex)
				index += 1
			hex_map[r].append("1")
				
				
			q += 1
		r += 1


	
