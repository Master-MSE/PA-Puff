extends Control

@onready var host_button = $Host
@onready var join_button = $Join

@export var host_field_scene : PackedScene
@export var join_field_scene : PackedScene


const PORT = 7000
const DEFAULT_SERVER_IP = "localhost" # IPv4 localhost
const MAX_CONNECTIONS = 2


func _ready():
	$Text.text="Choose the connection"
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_join_pressed() -> void:
	if check_address():
		$Join.disabled=true
		$Host.disabled=true
		var address : String = $Address_join.text
		if address == "000.000.000.000":
			address = DEFAULT_SERVER_IP
		join_game(address)
	else :
		$Text.text="Bad Address"
		
func _on_host_pressed() -> void:
	$Join.visible=false
	$Host.visible=false
	$Address_join.visible=false
	$Text.text="Wait Player"
	$Address.text= "Address: %s" % [IP.get_local_addresses()[5]]
	create_game()

func check_address()->bool:
	var address : String= $Address_join.text
	if  address.is_valid_ip_address():
		return true
	return false

func join_game(address = ""):

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	peer.get_peer(1).set_timeout(0, 0, 1000)
	get_parent().player_info=2
	multiplayer.multiplayer_peer = peer
	multiplayer.connection_failed.connect(Callable(self, "_on_connection_failed"))
	multiplayer.connected_to_server.connect(Callable(self, "_on_connection_success"))
	
	
func  _on_connection_success()->void:
	$Text.text="Connection Success! \nWait Start"
	$Join.visible=false
	$Host.visible=false
	$Address_join.visible=false
	init_game()
func  _on_connection_failed()->void:
	$Text.text="Connection failed! \ntry again"
	$Join.disabled=false
	$Host.disabled=false
	
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	get_parent().player_info=1

	
	
	
func _on_peer_connected(peer_id):
	if get_parent().player_info==1:
		init_game()	
		$Text.text="Go Start"
		$Start.visible=true
	
	
	
func _on_peer_disconnected(peer_id):
	print("Peer disconnected")
	
func init_game():
	
	if get_parent().player_info == 1:
		var game_scene = host_field_scene.instantiate()
		game_scene.name="board"
		game_scene.position=Vector2(600,300) 
		get_parent().add_child(game_scene)
		get_parent().card_me.set_color_card(1)
		get_parent().card_rial.set_color_card(2)
	else:
		var game_scene = join_field_scene.instantiate()
		game_scene.name="board"
		game_scene.position=Vector2(600,300) 
		get_parent().add_child(game_scene)
		get_parent().card_me.set_color_card(2)
		get_parent().card_rial.set_color_card(1)
	


func _on_start_pressed() -> void:
	rpc("start")
	get_parent().game_state=Constants.GameState.PLAY
	self.visible = false
	

@rpc("any_peer")
func start():
	get_parent().game_state=Constants.GameState.PLAY
	self.visible = false
	
