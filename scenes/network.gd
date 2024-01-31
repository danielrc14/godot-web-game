extends Node

var IP_ADDRESS = 'localhost'
var PORT = 8000
var local_player: Node
var remote_players = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = ENetMultiplayerPeer.new()
	multiplayer.connection_failed.connect(_on_peer_connection_failed)
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	create_player(false, multiplayer.get_unique_id())
	local_player.player_moved.connect(_on_player_moved)
	

func create_player(is_remote_player, player_id):
	var player_node;
	player_node = load("res://scenes/characters/player.tscn").instantiate()
	player_node.is_remote_player = is_remote_player
	player_node.player_id = player_id
	if is_remote_player:
		player_node.left_weapon_class = load("res://scenes/weapons/wood/wooden_axe.tscn")
	else:
		player_node.left_weapon_class = load("res://scenes/weapons/wood/wooden_sword.tscn")
	player_node.right_weapon_class = load("res://scenes/weapons/wood/wooden_round_shield.tscn")
	player_node.sprite_frames = load("res://resources/sprite_frames/player/knight.tres")
	player_node.position.x = 369
	player_node.position.y = 1352.5
	add_child(player_node)
	
	if is_remote_player:
		remote_players[player_id] = player_node
	else:
		local_player = player_node
	

func _on_peer_connection_failed():
	print("shit")
	
	
func _on_player_moved(player_id, velocity_vector, previous_x, previous_y):
	update_player_movement.rpc(player_id, velocity_vector, previous_x, previous_y)
	
	
@rpc("authority", "call_remote", "reliable", 0)
func create_new_player(player_id):
	if str(player_id) != str(multiplayer.get_unique_id()):
		create_player(true, player_id)

@rpc("authority", "call_remote", "reliable", 0)
func create_existing_players(incoming_player_id, players_ids):
	if multiplayer.get_unique_id() == incoming_player_id:
		for player_id in players_ids:
			if str(player_id) != str(multiplayer.get_unique_id()):
				create_player(true, player_id)
				

@rpc("any_peer", "call_remote", "unreliable", 0)
func update_player_movement(player_id, velocity_vector, previous_x, previous_y):
	if remote_players.has(player_id):
		remote_players[player_id].position.x = previous_x
		remote_players[player_id].position.y = previous_y
		remote_players[player_id].player_velocity_vector = velocity_vector
