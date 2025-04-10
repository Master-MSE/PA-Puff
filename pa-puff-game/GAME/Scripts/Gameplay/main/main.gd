extends Node2D
@onready var board  : Node2D = $Board
@onready var player1  : Node2D = $Payer1
@onready var player2  : Node2D = $Payer2

func _ready():
	board.set_player(player1,player2)
