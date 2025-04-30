extends Control

@onready var ip_input = $IPLineEdit
@onready var host_button = $Host
@onready var join_button = $Join

@export var host_field_scene : PackedScene
@export var join_field_scene : PackedScene

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "localhost" # IPv4 localhost
const MAX_CONNECTIONS = 2


var players = {}
var players_loaded = 0
var player_info = {"name": "Name"}

func _ready():
	pass


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
	var game_scene = join_field_scene.instantiate()
	get_parent().add_child(game_scene)
	get_parent().set_player(game_scene)	
	self.visible = false
	
	
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	var game_scene = host_field_scene.instantiate()
	get_parent().add_child(game_scene)
	get_parent().set_player(game_scene)	
	self.visible = false
	multiplayer.peer_connected.connect(_on_peer_connected)
	players[1] = player_info
	player_connected.emit(1, player_info)
	
func _on_peer_connected(peer_id):
	print("Peer connected")
