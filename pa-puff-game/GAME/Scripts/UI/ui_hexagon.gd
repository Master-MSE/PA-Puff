extends Control



static var usine_price=1000

func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	if self.visible :
		var inf_A :float = get_parent().inf_A
		var inf_B :float = get_parent().inf_B
		var inf_C :float = get_parent().inf_C
		var usineA : int = get_parent().usineA
		var usineB : int = get_parent().usineB
		$Panel/UsineA.text = "Usine A : %d" % usineA
		$Panel/UsineB.text = "Usine B : %d" % usineB
		$Panel/Button_BUY.text = "Buy : %d" % usine_price
		$Panel/PieChart.values[0] = inf_A
		$Panel/PieChart.values[1] = inf_B
		$Panel/PieChart.values[2] = inf_C
		$Panel/PieChart.queue_redraw()
	
func _on_button_buy_pressed() -> void:
	if get_parent().get_parent().get_parent().player_info == 1:
		if usine_price < get_parent().get_parent().get_parent().player1.check_money():
			get_parent().get_parent().get_parent().player1.take_money(usine_price)
			get_parent().call_add_usineA(1)
			usine_price+=1000
			get_parent().get_parent().get_parent().player1.set_synchronize()
	else:
		if usine_price < get_parent().get_parent().get_parent().player2.check_money():
			get_parent().get_parent().get_parent().player2.take_money(usine_price)
			get_parent().call_add_usineB(1)
			usine_price+=1000
			get_parent().get_parent().get_parent().player2.set_synchronize()


func _on_button_sell_pressed() -> void:
	if get_parent().get_parent().get_parent().player_info == 1:
		if get_parent().usineA > 0:
			get_parent().get_parent().get_parent().player1.give_money(1000)
			get_parent().call_add_usineA(-1)
			usine_price-=1000
			get_parent().get_parent().get_parent().player1.set_synchronize()
	else :
		if get_parent().usineB > 0:
			get_parent().get_parent().get_parent().player2.give_money(1000)
			get_parent().call_add_usineB(-1)
			usine_price-=1000
			get_parent().get_parent().get_parent().player2.set_synchronize()


func _on_button_end_pressed() -> void:
	get_parent().lock_UI=false
	self.visible = false
