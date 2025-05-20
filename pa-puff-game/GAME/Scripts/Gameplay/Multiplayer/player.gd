extends Node2D
class_name Player

@export var playername: String

@export var PLAYER_HOST = true

var money=0.0
var reputation=100.0
var global_influence=0.0
var total_usine=0

var price_factor=1.0
var influence_factor=1.0
var maintenance_factor = 1.0

var cards_in_hand: Array[CardBase] = []

func _ready():
	self.money = 10000.0

func give_money(_money:float)->void:
	self.money+=_money
	
func take_money(_money:float)->void:
	self.money-=_money
	
func check_money()->float:
	return self.money
	
func get_price()->float:
	return self.price_factor*Constants.BASE_PRICE
	
func get_maintenance()->float:
	return self.maintenance_factor*Constants.MAINTENANCE_COST

func get_hand() -> Array[CardBase]:
	return self.cards_in_hand
	
func set_global_influence(influence):
	self.global_influence=influence
	
func set_synchronize():
	rpc("get_synchronize",
	self.PLAYER_HOST,
	self.money,
	self.reputation,
	self.global_influence,
	self.price_factor,
	self.influence_factor,
	self.maintenance_factor)
	
@rpc("any_peer")
func get_synchronize(player,_money,_reputation,_global_influence,_price_factor,_influence_factor,_maintenance_factor):
	if PLAYER_HOST == player:
		self.money = _money
		self.reputation = _reputation
		self.global_influence = _global_influence
		self.price_factor = _price_factor
		self.influence_factor = _influence_factor
		self.maintenance_factor = _maintenance_factor
		
