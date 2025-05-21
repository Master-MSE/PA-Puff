extends CardBase
class_name CardScientistsRecruit

func execute(player: Player) -> void:
	player.price_factor -= 0.1
	player.influence_factor += 0.1
	player.set_synchronize()