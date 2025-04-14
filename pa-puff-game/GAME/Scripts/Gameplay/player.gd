extends Node2D

var money=0.0 

func _ready():
	self.money = 10000.0

func give_money(money:float)->void:
	self.money+=money
	
func take_money(money:float)->void:
	self.money-=money
	
func check_money()->float:
	return self.money
