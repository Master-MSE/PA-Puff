extends Node2D

@onready var timer : Timer = $Timer

const HEX_SCENE = preload("res://GAME/Scenes/Map/hexagon.tscn")
const card_scene = preload("res://GAME/Scenes/Cards/Card.tscn")

const HEX_SIZE = 20


var array_hex : Dictionary
var tab_conection : Dictionary

var country_polygons = []
var lon_max=-100000.0
var lon_min=100000.0
var lat_max=-100000.0
var lat_min=100000.0
var name_country="switzerland"

func _ready():
	init_hex()
	if not $Timer.timeout.is_connected(_on_timer_timeout):
		$Timer.timeout.connect(_on_timer_timeout)
	
func init_hex():
	var directions_even = [
	Vector2(+1,  0), Vector2( 0, +1), Vector2(-1, +1),
	Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1)]
	var directions_odd = [
	Vector2(+1,  0), Vector2(+1, +1), Vector2( 0, +1),
	Vector2(-1,  0), Vector2( 0, -1), Vector2(+1, -1)]
	init_array()
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
func init_array():
	var list_child = self.get_children()
	for child in list_child:
		if child is Node2D:
			array_hex[child.ID]=child	
	
func _on_timer_timeout() -> void:
	update_infuence()
	calcul_money()
	show_money()
	
func update_infuence()-> void:
	var value_infuence : Dictionary
	var inf_a_g = 0.0
	var inf_b_g = 0.0
	for i in tab_conection:
		var inf_a = 0.0
		var inf_b = 0.0
		var inf_c = 0.0
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
		if  sum_inf > 0.1:
			inf_a/=sum_inf
			inf_b/=sum_inf
			inf_c/=sum_inf
		
		new_a = lerp(new_a, inf_a, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_b = lerp(new_b, inf_b, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_c = lerp(new_c, inf_c, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		
		
		
		new_a+=array_hex[i].get_internal_influence_A()*get_parent().player1.influence_factor
		new_b+=array_hex[i].get_internal_influence_B()*get_parent().player2.influence_factor
		
		var total_sum = new_a + new_b + new_c
		if  total_sum > 0.1:
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
	money_A=get_parent().player1.check_money()
	money_B=get_parent().player2.check_money()

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
