extends Node2D
@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Player1
@onready var player2  : Node2D = $Player2

@export var hand_player_1 : Hand
@export var hand_player_2 : Hand

func _ready():
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
