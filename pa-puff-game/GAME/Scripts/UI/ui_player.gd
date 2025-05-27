extends Control

func _process(delta: float) -> void:
	if get_parent().visible :
		var money : int = get_parent().money
		var reputation : int = get_parent().reputation
		$Panel/Money_value.text = "%d" % money
		$Panel/Reputation_value.text = "%d" % reputation
