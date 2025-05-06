extends Label
func _process(delta: float) -> void:
	var money=get_parent().money
	var reputation=get_parent().reputation
	var global_influence=get_parent().global_influence
	var influence_factor=get_parent().influence_factor
	var maintenance_factor=get_parent().maintenance_factor
	var price_factor=get_parent().price_factor
	text = "Money : %f\nReputation : %f\nGlobal_influence : %f\nInfluence_factor : %f\nMaintenance_factor : %f\nPrice_factor : %f" % [money, reputation,global_influence,influence_factor,maintenance_factor,price_factor]
