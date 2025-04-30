extends Node2D
#@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Player1
@onready var player2  : Node2D = $Player2

func _ready():
	pass
	
func set_player(board: Node2D):
	board.set_player(player1,player2)
