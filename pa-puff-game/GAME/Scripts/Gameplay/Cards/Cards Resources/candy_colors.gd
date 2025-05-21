extends CardBase
class_name CardCandyColors

@export var price = 2000

func execute(player: Player) -> void:
	if player.check_money() <= price:
		return
	
	player.take_money(price)
	player.influence_factor += 0.2
	player.set_synchronize()