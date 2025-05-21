extends StaticBody2D

@onready var texture_base : Polygon2D = $Texture_base
@onready var texture_border : Polygon2D = $Texture_border
@onready var collision : CollisionPolygon2D = $CollisionPolygon2D
@onready var ui : Control = $UI_Hexagon

@export var HEX_RADIUS = 49
@export var INDEX = 0
@export var ID : Vector2 = Vector2(0,0)
@export var WEIGHT = 1000.0
@export var UI_POSTION : Vector2 = Vector2(0,0)

static var lock_UI :bool = false



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

func _ready():
	if not self.mouse_entered.is_connected(_on_mouse_entered):
		self.mouse_entered.connect(_on_mouse_entered)
	if not self.mouse_exited.is_connected(_on_mouse_exited):
		self.mouse_exited.connect(_on_mouse_exited)
	if not self.input_event.is_connected(_on_input_event):
		self.input_event.connect(_on_input_event)
	create_hex(HEX_RADIUS,PI / 2)
	set_position_UI(UI_POSTION)
	
func create_hex(radius:float,base_angle : float=0)->void:
	var points = []
	for i in range(6):
		var angle = i * PI / 3+base_angle;
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		points.append(Vector2(x, y))
	texture_base.polygon=points
	collision.polygon=points
	for i in range(6):
		var angle = i * PI / 3+base_angle;
		var x = (radius+1) * cos(angle)
		var y = (radius+1) * sin(angle)
		points.append(Vector2(x, y))
	texture_border.polygon=points
	
func _process(delta: float) -> void:
	texture_base.color=Color(1-inf_B,1-(inf_A+inf_B),1-inf_A)

	
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			lock_UI=true

func call_add_usineA(value):
	rpc("add_usineA",value,INDEX)
func call_add_usineB(value):
	rpc("add_usineB",value,INDEX)

@rpc("any_peer","call_local")
func add_usineA(value,index):
	if index==INDEX:
		self.usineA+=value
@rpc("any_peer","call_local")
func add_usineB(value,index):
	if index==INDEX:
		self.usineB+=value

func _on_mouse_entered() -> void:
	print("I: ",self.INDEX," P: ",self.WEIGHT)
	self.z_index=1
	#create_hex(HEX_RADIUS+5,PI / 2)
	if not lock_UI:
		$UI_Hexagon.visible=true
	
	
func _on_mouse_exited() -> void:
	self.z_index=0
	#create_hex(HEX_RADIUS,PI / 2)
	if not lock_UI:
		$UI_Hexagon.visible=false
	
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
	
func set_position_UI(_position: Vector2)->void:
	ui.position = _position
	
