extends Control

@onready var host_button = $Host
@onready var join_button = $Join

@export var host_field_scene : PackedScene
@export var join_field_scene : PackedScene


const PORT = 7000
const DEFAULT_SERVER_IP = "localhost" # IPv4 localhost
const MAX_CONNECTIONS = 2

var player_info = 0


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_join_pressed() -> void:
	join_game()

func _on_host_pressed() -> void:
	create_game()

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_info=2
	init_game()
	self.visible = false
	
	
	
	
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_info=1
	init_game()	
	self.visible = false
	
	
	
func _on_peer_connected(peer_id):
	print("Peer connected")
	
	
func _on_peer_disconnected(peer_id):
	print("Peer disconnected")
	
func init_game():
	
	if player_info == 1:
		var game_scene = host_field_scene.instantiate()
		get_parent().add_child(game_scene)
		get_parent().card_me.set_color_card(1)
		get_parent().card_rial.set_color_card(2)
	else:
		var game_scene = join_field_scene.instantiate()
		get_parent().add_child(game_scene)
		get_parent().card_me.set_color_card(2)
		get_parent().card_rial.set_color_card(1)
	
