extends CardBase
class_name CardInfluencerCampain

@export var price = 5000

func execute(player: Player) -> void:
	if player.check_money() <= price:
		return
	
	player.take_money(price)
	player.influence_factor += 0.3
	player.set_synchronize()
