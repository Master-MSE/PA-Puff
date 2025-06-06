extends Node2D
#@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Player1
@onready var player2  : Node2D = $Player2
@onready var connection  : Control = $Connection


@export var hand_player : Hand
	
func set_player():
	if player_info == 1:
		hand_player.player=player1
		player1.show()
	else:
		hand_player.player=player2
		player2.show()

func _on_btn_hand_1_button_up() -> void:
	if hand_player.visible:
		await get_tree().process_frame
		hand_player.hide()
	else:
		hand_player.show()


func _on_btn_draw_1_button_up() -> void:
	hand_player.add_card(CardManager.get_card())


var player_info
var game_state: Constants.GameState = Constants.GameState.START
var board
var winner = 0
	
func _process(delta: float) -> void:
	if game_state==Constants.GameState.START:
		if $HUD.visible:
			$HUD.hide()
	elif game_state==Constants.GameState.WAIT:
		board = get_node("board")
		board.stop_timer()
		if $HUD.visible:
			$HUD.hide()
		if not $Time_end.is_stopped():
			$Time_end.paused()
	elif game_state==Constants.GameState.PLAY:
		
		if not $HUD.visible:
			$HUD.show()
		if not ($HUD/Screen/VBoxContainer.visible):
			$HUD/Screen/VBoxContainer.show()
		if player_info==1:
			board = get_node("board")
			board.start_timer()
			if $Time_end.is_stopped():
				$Time_end.start()
		check_end()
	elif game_state==Constants.GameState.END:
		show_winner()
		if $HUD.visible:
			$HUD.hide()
		if player_info==1:
			board = get_node("board")
			board.stop_timer()
			if not $Time_end.is_stopped():
				$Time_end.stop()
	else :
		print("Error")
func check_end():
	if player_info==1:
		if player1.global_influence>0.5 or player2.reputation <0.0:
			rpc("set_winner",1)
			rpc("change_state",Constants.GameState.END)
		if player1.reputation <0.0 or player2.global_influence>0.5:
			rpc("set_winner",2)
			rpc("change_state",Constants.GameState.END)

@rpc("call_local")
func change_state(state:Constants.GameState) -> void:
	game_state=state
	
@rpc("call_local")
func set_winner(_winner:int) -> void:
	winner=_winner

func _on_time_end_timeout() -> void:
	if player1.money>player2.money:
		rpc("set_winner",3)
	elif  player1.money < player2.money:
		rpc("set_winner",4)
	else :		
		rpc("set_winner",0)
	rpc("change_state",Constants.GameState.END)

func show_winner():
	$Win.visible=true
	$Win.z_index=2
	if winner == 1:
		$Win.text = "Player 1 win"
	elif winner == 2:
		$Win.text = "Player 2 win"
	elif winner == 3:
		$Win.text = "Time out \n Player 1 Win"
	elif winner == 4:
		$Win.text = "Time out \n Player 2 Win"
	else:
		$Win.text = "Time out \n Equality"
