extends Node2D

var money 

func _ready():
	self.money = 0.0

func give_money(money:float)->void:
	self.money+=money
	
func take_money(money:float)->void:
	self.money-=money
	
func check_money()->float:
	return money
