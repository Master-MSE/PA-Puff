extends StaticBody2D

@onready var texture_base : Polygon2D = $Texture_base
@onready var texture_border : Polygon2D = $Texture_border
@onready var collision : CollisionPolygon2D = $CollisionPolygon2D

@export var HEX_RADIUS = 49
@export var INDEX = 0
@export var WEIGHT = 1000.0




var inf_A :float = 0.0
var inf_B :float = 0.0
var inf_C :float = 1.0
var reputation_A :float = 1.0
var reputation_B :float = 1.0
var new_inf_A :float = 0.0
var new_inf_B :float = 0.0
var new_inf_C :float = 1.0
var usineA : int =0
var usineB : int =0
var is_colored = false

func _ready():
	# Calculer les points de l'hexagone
	var points = []
	for i in range(6):
		var angle = i * PI / 3;
		var x = HEX_RADIUS * cos(angle)
		var y = HEX_RADIUS * sin(angle)
		points.append(Vector2(x, y))
	texture_base.polygon=points
	collision.polygon=points
	for i in range(6):
		var angle = i * PI / 3;
		var x = (HEX_RADIUS+1) * cos(angle)
		var y = (HEX_RADIUS+1) * sin(angle)
		points.append(Vector2(x, y))
	texture_border.polygon=points
	
func _process(delta: float) -> void:
	texture_base.color=Color(1-inf_B,1-(inf_A+inf_B),1-inf_A)
	
func update_inf():
	inf_A=0.0
	
func on_left_click():
	#self.usineA+=1
	rpc("add_usineA",INDEX)
func on_right_click():
	#self.usineB+=1
	rpc("add_usineB",INDEX)
	
@rpc("any_peer")
func add_usineA(index):
	if index==INDEX:
		self.usineA+=1
@rpc("any_peer")
func add_usineB(index):
	if index==INDEX:
		self.usineB+=1
	

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			on_left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			on_right_click()

func _on_mouse_entered() -> void:
	print("I: ",self.INDEX," P: ",self.WEIGHT)
	self.z_index=1
	var points = []
	var rad = HEX_RADIUS+5
	for i in range(6):
		var angle = i * PI / 3;
		var x = rad * cos(angle)
		var y = rad * sin(angle)
		points.append(Vector2(x, y))
	texture_base.polygon=points
	for i in range(6):
		var angle = i * PI / 3;
		var x = (rad+2) * cos(angle)
		var y = (rad+2) * sin(angle)
		points.append(Vector2(x, y))
	texture_border.polygon=points
	


func _on_mouse_exited() -> void:
	self.z_index=0
	var points = []
	var rad = HEX_RADIUS
	for i in range(6):
		var angle = i * PI / 3;
		var x = rad * cos(angle)
		var y = rad * sin(angle)
		points.append(Vector2(x, y))
	texture_base.polygon=points
	for i in range(6):
		var angle = i * PI / 3;
		var x = (rad+1) * cos(angle)
		var y = (rad+1) * sin(angle)
		points.append(Vector2(x, y))
	texture_border.polygon=points
	
	
func get_infuence_A()->float:
	return inf_A
func get_infuence_B()->float:
	return inf_B
func get_infuence_C()->float:
	return inf_C
	
func set_infuence(inf_a,inf_b,inf_c)->void:
	self.new_inf_A=inf_a
	self.new_inf_B=inf_b
	self.new_inf_C=inf_c
	
func update_influence()->void:
	self.inf_A=self.new_inf_A
	self.inf_B=self.new_inf_B
	self.inf_C=self.new_inf_C
	
	
func get_internal_influence_A()->float:
	return self.usineA*Constants.INFLUENCE_FACTOR
func get_internal_influence_B()->float:
	return self.usineB*Constants.INFLUENCE_FACTOR
	
func get_weight()->float:
	return self.WEIGHT
func get_money_A(price:float)->float:
	return self.WEIGHT*self.inf_A*price
func get_money_B(price:float)->float:
	return self.WEIGHT*self.inf_B*price
	
func get_cost_A(maintenance)->float:
	return self.usineA*maintenance
func get_cost_B(maintenance)->float:
	return self.usineB*maintenance
