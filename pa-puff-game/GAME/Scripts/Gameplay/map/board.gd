extends Node2D

@onready var money  : Label = $Money

const HEX_SCENE = preload("res://GAME/Scenes/Map/hexagon.tscn")
const HEX_SIZE = 30

const TAB_CONECTION={
	0:[1,4,5,6],
	1:[0,2,6],
	2:[1,3,6,7],
	3:[2],
	4:[0,5,9],
	5:[0,4,6,9,10,11],
	6:[0,1,2,5,7,11],
	7:[2,6,11,12],
	8:[12,13],
	9:[4,5,10,14],
	10:[5,9,11,14,15],
	11:[5,6,7,10],
	12:[7,8,13,17],
	13:[8,12,17,18],
	14:[9,10,15,19],
	15:[10,14,19,20],
	16:[17,20,21,22],
	17:[12,13,16,18,22],
	18:[13,17,22,23],
	19:[14,15],
	20:[15,16,21,25],
	21:[16,20,22,25,26,27],
	22:[16,17,18,21,23,27],
	23:[18,22,27],
	24:[25	],
	25:[20,21,24,26],
	26:[21,25,27],
	27:[21,22,23,26],
}

var player1:Node2D
var player2:Node2D
var array_hex=[]

func _ready():
	create_hex_grid()

func create_hex_grid():
	var cols = 6
	var rows = 6
	var x_offset = HEX_SIZE * 1.5
	var y_offset = HEX_SIZE * sqrt(3)
	
	var grid_width = (cols - 1) * x_offset
	var grid_height = (rows - 1) * y_offset
	#var center_offset = Vector2(-grid_width / 2, -grid_height / 2)
	var center_offset = Vector2(grid_width*2,grid_height/1.5)
	
	var n_del=0
	for y in range(rows):
		for x in range(cols):
			if (x+y*cols) % 5 != 0:
				var hex = HEX_SCENE.instantiate()
				var x_pos = x * x_offset
				var y_pos = y * y_offset
				
				if x % 2 != 0:
					y_pos += y_offset / 2
				hex.position = Vector2(x_pos, y_pos) + center_offset
				hex.HEX_RADIUS=HEX_SIZE
				hex.INDEX=x+y*cols-n_del
				hex.WEIGHT=randi_range(100,10000)
				add_child(hex)
				array_hex.append(hex)
			else :
				n_del+=1
	

func _on_timer_timeout() -> void:
	update_infuence()
	calcul_money()
	show_money()
	
func update_infuence()-> void:
	var value_infuence : Dictionary
	for i in TAB_CONECTION:
		var inf_a = 0
		var inf_b = 0
		var inf_c = 0
		var new_a = array_hex[i].get_infuence_A()
		var new_b = array_hex[i].get_infuence_B()
		var new_c = array_hex[i].get_infuence_C()
		
		
		var weight = array_hex[i].get_weight()
		var weight_inf=0.0 # Changer avec une variable inter à calculer 1 fois au débu
		for connection in TAB_CONECTION[i]:
			var weight_c = array_hex[connection].get_weight()
			weight_inf+=weight_c
			inf_a+=array_hex[connection].get_infuence_A() * weight_c
			inf_b+=array_hex[connection].get_infuence_B() * weight_c
			inf_c+=array_hex[connection].get_infuence_C() * weight_c
			
		var sum_inf = inf_a + inf_b + inf_c
		inf_a/=sum_inf
		inf_b/=sum_inf
		inf_c/=sum_inf
		
		new_a = lerp(new_a, inf_a, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_b = lerp(new_b, inf_b, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		new_c = lerp(new_c, inf_c, Constants.INFLUENCE_FACTOR*weight_inf/weight)
		
		
		
		new_a+=array_hex[i].get_internal_influence_A()
		new_b+=array_hex[i].get_internal_influence_B()
		
		var total_sum = new_a + new_b + new_c
		new_a/=total_sum
		new_b/=total_sum
		new_c/=total_sum
		
		
		
		array_hex[i].set_infuence(new_a,new_b,new_c)
		value_infuence[i]=[new_a,new_b,new_c]
		
	rpc("update_influence_peer",value_infuence)
	
	for hex in array_hex:
		hex.update_influence()
	
		
		
func calcul_money()->void:

	for hexagon in array_hex:
		get_parent().player1.give_money(hexagon.get_money_A(get_parent().player1.get_price()))
		get_parent().player2.give_money(hexagon.get_money_B(get_parent().player2.get_price()))
		get_parent().player1.take_money(hexagon.get_cost_A(get_parent().player1.get_maintenance()))
		get_parent().player2.take_money(hexagon.get_cost_B(get_parent().player2.get_maintenance()))
		
		
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
