extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func set_color_card(player_card):
	var color
	if player_card == 1:
		color = Color(1.0,0.0,0.0)
	else :
		color = Color(0.0,0.0,1.0)
	$temp_dec.color = color
	$temp_card.color=color
