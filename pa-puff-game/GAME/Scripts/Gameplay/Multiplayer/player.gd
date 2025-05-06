extends Node2D
class_name Player

@export var playername: String

var money=0.0
var reputation=0.0

var price_factor=1.0
var influence_factor=1.0
var maintenance_factor = 1.0

var cards_in_hand: Array[CardBase] = []

func _ready():
	self.money = 10000.0

func give_money(money:float)->void:
	self.money+=money
	
func take_money(money:float)->void:
	self.money-=money
	
func check_money()->float:
	return self.money
	
func get_price()->float:
	return self.price_factor*Constants.BASE_PRICE
	
func get_maintenance()->float:
	return self.maintenance_factor*Constants.MAINTENANCE_COST

func get_hand() -> Array[CardBase]:
	return self.cards_in_hand
