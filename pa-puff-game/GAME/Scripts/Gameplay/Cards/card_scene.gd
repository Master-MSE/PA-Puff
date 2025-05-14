extends Control

signal card_clicked(card_data)

var card_data: CardBase
var player_owner: Player
@export var tween_setting: TweenSettings
@export var hover_vertical_offset: Vector2
var initial_local_pos: Vector2
var tween: Tween
var focused: bool = false


func _ready() -> void:
	$Panel/Logo.texture = card_data.logo

func setup(data: CardBase, player: Player) -> void:
	card_data = data
	player_owner = player
	%Title.text = data.title
	%Description.text = data.description
	
func _on_button_pressed() -> void:
	card_data.execute(player_owner)
	player_owner.cards_in_hand.erase(card_data)
	$".".queue_free()

func enter() -> void:
	if focused:
		return
	
	focused = true
	await get_tree().process_frame
	initial_local_pos = position
	if tween != null:
		tween.stop()
		tween = null
	tween = get_tree().create_tween()
	tween_setting.tween_property(tween, self, initial_local_pos+hover_vertical_offset, 1)

func exit() -> void:
	if !focused:
		return
	
	focused=false
	if tween != null:
		tween.stop()
		tween = null
	tween = get_tree().create_tween()
	tween_setting.tween_property(tween, self, initial_local_pos, 1)
