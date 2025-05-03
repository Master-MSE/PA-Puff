extends Node2D
#@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Player1
@onready var player2  : Node2D = $Player2
@onready var card_me  : Node2D = $Card_me
@onready var card_rial  : Node2D = $Card_rival
@onready var connection  : Control = $Connection

var player_info 

func _ready():
	pass
	
func set_player(board: Node2D):
	board.set_player(player1,player2)
