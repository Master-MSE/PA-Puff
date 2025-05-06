extends Control

signal card_clicked(card_data)

@export var card_data: CardBase
@onready var name_label = $Panel/Title
@onready var description_label = $Panel/Description
var player_owner: Player

func setup(data: CardBase, player: Player) -> void:
	card_data = data
	player_owner = player
	%Title.text = data.title
	%Description.text = data.description

func _on_button_pressed() -> void:
	card_data.execute(player_owner)
	player_owner.cards_in_hand.erase(card_data)
	$".".queue_free()
