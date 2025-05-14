extends Node2D
#@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Player1
@onready var player2  : Node2D = $Player2
@onready var card_me  : Node2D = $Card_me
@onready var card_rial  : Node2D = $Card_rival
@onready var connection  : Control = $Connection


@export var hand_player_1 : Hand
@export var hand_player_2 : Hand
	
func set_player(board: Node2D):
	board.set_player(player1,player2)
	await get_tree().process_frame
	hand_player_1.hide()
	hand_player_2.hide()


func _on_btn_hand_1_button_up() -> void:
	if hand_player_1.visible:
		await get_tree().process_frame
		hand_player_1.hide()
	elif !hand_player_2.visible:
		hand_player_1.show()


func _on_btn_hand_2_button_up() -> void:
	if hand_player_2.visible:
		await get_tree().process_frame
		hand_player_2.hide()
	elif !hand_player_1.visible:
		hand_player_2.show()

func _on_btn_draw_1_button_up() -> void:
	hand_player_1.add_card(CardManager.get_card())


func _on_btn_draw_2_button_up() -> void:
	hand_player_2.add_card(CardManager.get_card())
var player_info
var game_state: Constants.GameState = Constants.GameState.START
var board
var winner = 0
	
func _process(delta: float) -> void:
	
	if game_state==Constants.GameState.START:
		pass
	elif game_state==Constants.GameState.WAIT:
		board = get_node("board")
		board.stop_timer()
		if not $Time_end.is_stopped():
			$Time_end.paused()
	elif game_state==Constants.GameState.PLAY:
		board = get_node("board")
		board.start_timer()
		if $Time_end.is_stopped():
			$Time_end.start()
		check_end()
	elif game_state==Constants.GameState.END:
		board = get_node("board")
		board.stop_timer()
		if not $Time_end.is_stopped():
			$Time_end.stop()
		show_winner()
	else :
		print("Error")
func check_end():
	if player_info==1:
		if player1.global_influence>0.5 or player2.reputation <0.0:
			winner = 1
			game_state=Constants.GameState.END
		if player1.reputation <0.0 or player2.global_influence>0.5:
			winner = 2
			game_state=Constants.GameState.END


func _on_time_end_timeout() -> void:
	winner=0
	game_state=Constants.GameState.END
	
func show_winner():
	$Win.visible=true
	$Win.z_index=2
	if winner == 0:
		$Win.text = "Time out"
	elif winner == 1:
		$Win.text = "Player 1 win"
	else :
		$Win.text = "Player 2 win"
	
