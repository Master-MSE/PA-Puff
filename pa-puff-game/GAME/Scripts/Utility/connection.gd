extends Control

@onready var host_button = $Host
@onready var join_button = $Join
@onready var line_address_join = $Address_join
@onready var address_label = $Address
@onready var country_box = $Country_box

@export var switzerland_field_scene : PackedScene
@export var french_field_scene : PackedScene
@export var italy_field_scene : PackedScene


const PORT = 7000
const DEFAULT_SERVER_IP = "localhost" # IPv4 localhost
const MAX_CONNECTIONS = 2

var country_id = 0


func _ready():
	$Text.text="Choose the connection"
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_join_pressed() -> void:
	if check_address():
		$Join.disabled=true
		$Host.disabled=true
		var address : String = line_address_join.text
		if address.is_empty():
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
	if address.is_empty():
		return true
	if  address.is_valid_ip_address():
		return true
	return false
	
	
func init_game():
	var game_scene
	if country_id == 0 :
		game_scene = switzerland_field_scene.instantiate()
	elif country_id == 1 :
		game_scene = french_field_scene.instantiate()
	else :
		game_scene = italy_field_scene.instantiate()
	
	game_scene.name="board"
	game_scene.position=Vector2(600,300) 
	get_parent().add_child(game_scene)

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
	#init_game()
	
	
func  _on_connection_failed()->void:
	$Text.text="Connection failed! \ntry again"
	$Join.disabled=false
	$Host.disabled=false
	
	
@rpc("any_peer")	
func init_map()->void:
	init_game()
	rpc("ready")
	
	
	
	
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	get_parent().player_info=1

	
	
func _on_peer_connected(peer_id):
	if get_parent().player_info==1:
		$Country_box.visible=true
		$Choice.visible=true
		$Text.text="Choise country"
		
		
func _on_peer_disconnected(peer_id):
	print("Peer disconnected")
	
func _on_menu_bar_item_selected(index: int) -> void:
	rpc("set_country_id",index)

func _on_choice_pressed() -> void:
	rpc("init_map")
	init_game()
	
@rpc("any_peer")	
func ready()->void:
	$Text.text="Go Start"
	$Start.visible=true
	

func _on_start_pressed() -> void:
	rpc("start")
	







@rpc("call_local")
func start():
	get_parent().game_state=Constants.GameState.PLAY
	self.visible = false
	
@rpc("call_local")
func set_country_id(index:int)->void:
	country_id = index


	
