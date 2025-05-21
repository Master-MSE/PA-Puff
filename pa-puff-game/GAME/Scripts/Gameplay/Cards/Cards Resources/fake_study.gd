extends CardBase
class_name CardFakeStudy

@export var price = 10000

func execute(player: Player) -> void:
	if player.check_money() < price:
		return
	
	player.take_money(price)
	
	if randi() % 10 <= 3:
		player.influence_factor -= 0.5
	else:
		player.influence_factor += 0.5
	
	player.set_synchronize()
