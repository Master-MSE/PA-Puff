extends Node2D

@export var card_data: CardBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Title.text = card_data.title
	%Description.text = card_data.description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	card_data.execute()
