extends CardBase
class_name CardStaffLayoff

func execute(player: Player) -> void:
	player.influence_factor -= 0.3
	player.price_factor += 0.3
	player.set_synchronize()