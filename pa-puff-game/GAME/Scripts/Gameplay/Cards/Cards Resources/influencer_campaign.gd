extends CardBase
class_name CardInfluencerCampaign

func execute(player: Player) -> void:
	player.give_money(2000)
	player.set_synchronize()
