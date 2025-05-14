extends Control
class_name Hand

@export var card_scene: PackedScene
@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func draw_hand():
	clear_hand()  # Clear the current cards displayed
	for card_data in player.get_hand():
		add_card(card_data)

func add_card(card_data: CardBase):
	var card_instance = card_scene.instantiate()
	card_instance.setup(card_data, player)  # Setup with the card data
	$CardsBox.add_child(card_instance)

func clear_hand():
	for card_node in $CardsBox.get_children():
		card_node.queue_free()

func _on_button_pressed() -> void:
	player.cards_in_hand.append(CardManager.get_card())
	draw_hand()
