extends Node2D

@onready var money  : Label = $Money
@onready var timer : Timer = $Timer

const GEOJSON_PATH = "res://GAME/Ressources/Game Data/france.geojson"
#const GEOJSON_PATH = "res://GAME/Ressources/Game Data/switzerland.geojson"
const HEX_SCENE = preload("res://GAME/Scenes/Map/hexagon.tscn")
const card_scene = preload("res://GAME/Scenes/Cards/Card.tscn")

const HEX_SIZE = 20


var player1:Node2D
var player2:Node2D
var array_hex : Dictionary
var tab_conection : Dictionary

var country_polygons = []
var lon_max=-100000.0
var lon_min=100000.0
var lat_max=-100000.0
var lat_min=100000.0

func _ready():
	load_geojson()
	create_hex_grid()
	init_hex()

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
	var _scale = min(box_width / poly_width, box_height / poly_height)
	var center_lon = lon_min + poly_width / 2.0
	var center_lat = lat_min + poly_height / 2.0
	for point in _poly:
		array.append(Vector2((point[0]-center_lon)*_scale*0.75, (point[1]-center_lat)*_scale))
	return array
	
func add_hexagon (key : Vector2, value : StaticBody2D) :
	array_hex[key] = value
func create_hex_grid():
	var _width = sqrt(3) * HEX_SIZE
	var _height = 2 * HEX_SIZE
	var horiz_spacing = _width
	var vert_spacing = 1.5 * HEX_SIZE

	var min_x = -400
	var max_x = 400
	var min_y = -200
	var max_y = 200

	var index = 0
	var r = 0
	while true:
		var y = r * vert_spacing
		if y + min_y > max_y:
			break
		var q = 0
		while true:
			var x = q * horiz_spacing + (r % 2) * horiz_spacing / 2.0
			if x + min_x > max_x:
				break
			var world_pos = Vector2(x + min_x, y + min_y)
			if is_point_inside_polygons(world_pos):
				var hex = HEX_SCENE.instantiate()
				hex.position = world_pos
				hex.HEX_RADIUS = HEX_SIZE
				hex.INDEX = index
				hex.set_position_UI(Vector2(650,0)-Vector2(x,y))
				hex.WEIGHT = randi_range(1,3)*1000
				add_child(hex)
				add_hexagon(Vector2(q,r),hex)
				index += 1
			q += 1
		r += 1
	
func init_hex():
	var directions_even = [
	Vector2(+1,  0), Vector2( 0, +1), Vector2(-1, +1),
	Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1)]
	var directions_odd = [
	Vector2(+1,  0), Vector2(+1, +1), Vector2( 0, +1),
	Vector2(-1,  0), Vector2( 0, -1), Vector2(+1, -1)]
	for key in array_hex:
		var x = key[0]
		var y = key[1]
		var connection_key=[]
		var directions
		if int(y)% 2 == 0:
			directions = directions_even
		else:
			directions = directions_odd
		for dir in directions:
			var neighbor = Vector2(x, y) + dir
			if array_hex.has(neighbor):
				connection_key.append(neighbor)
		tab_conection[key]=connection_key
		
		
	
func _on_timer_timeout() -> void:
	update_infuence()
	calcul_money()
	show_money()
	
func update_infuence()-> void:
	var value_infuence : Dictionary
	var inf_a_g = 0
	var inf_b_g = 0
	for i in tab_conection:
		var inf_a = 0
		var inf_b = 0
		var inf_c = 0
		var new_a = array_hex[i].get_infuence_A()
		var new_b = array_hex[i].get_infuence_B()
		var new_c = array_hex[i].get_infuence_C()
		
		
		var weight = array_hex[i].get_weight()
		var weight_inf=0.0 # Changer avec une variable inter à calculer 1 fois au débu
		for connection in tab_conection[i]:
			var weight_c = array_hex[connection].get_weight()
			weight_inf+=weight_c
			inf_a+=array_hex[connection].get_infuence_A() * weight_c
			inf_b+=array_hex[connection].get_infuence_B() * weight_c
			inf_c+=array_hex[connection].get_infuence_C() * weight_c
			
		var sum_inf = inf_a + inf_b + inf_c
		if not sum_inf == 0:
			inf_a/=sum_inf
			inf_b/=sum_inf
			inf_c/=sum_inf
		
		new_a = lerp(new_a, inf_a, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_b = lerp(new_b, inf_b, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_c = lerp(new_c, inf_c, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		
		
		
		new_a+=array_hex[i].get_internal_influence_A()
		new_b+=array_hex[i].get_internal_influence_B()
		
		var total_sum = new_a + new_b + new_c
		if not total_sum==0:
			new_a/=total_sum
			new_b/=total_sum
			new_c/=total_sum
		
		
		
		array_hex[i].set_infuence(new_a,new_b,new_c)
		value_infuence[i]=[new_a,new_b,new_c]
		inf_a_g+=new_a
		inf_b_g+=new_b
		
	rpc("update_influence_peer",value_infuence)
	
	for hex in array_hex:
		array_hex[hex].update_influence()
		
	inf_a_g/=array_hex.size()
	inf_b_g/=array_hex.size()
	get_parent().player1.set_global_influence(inf_a_g)
	get_parent().player2.set_global_influence(inf_b_g)
		

func set_player(player1:Node2D,player2:Node2D)->void:
	self.player1=player1
	self.player2=player2
	
func calcul_money()->void:

	for key in array_hex:
		var hexagon=array_hex[key]
		get_parent().player1.give_money(hexagon.get_money_A(get_parent().player1.get_price()))
		get_parent().player2.give_money(hexagon.get_money_B(get_parent().player2.get_price()))
		get_parent().player1.take_money(hexagon.get_cost_A(get_parent().player1.get_maintenance()))
		get_parent().player2.take_money(hexagon.get_cost_B(get_parent().player2.get_maintenance()))
		get_parent().player1.set_synchronize()
		get_parent().player2.set_synchronize()
		
		
var money_A=0.0
var money_B=0.0

func show_money() -> void:
	var old_money_A=money_A
	var old_money_B=money_B
	money_A=get_parent().player1.check_money()
	money_B=get_parent().player2.check_money()
	self.money.text="Money A: %s\n Gain A : %s \nMoney B: %s\n Gain B : %s" % [money_A,money_A-old_money_A,money_B,money_B-old_money_B]

@rpc("any_peer")
func update_influence_peer(list_of_value)->void:
	for key in list_of_value:
		var value=list_of_value[key]
		var hexagon=array_hex[key]
		hexagon.set_infuence(value[0],value[1],value[2])
		hexagon.update_influence()
func start_timer()->void:
	if not timer==null:
		if $Timer.is_stopped():
			$Timer.start()
func stop_timer()->void:
	if not timer==null:
		if not $Timer.is_stopped():
			$Timer.stop()
