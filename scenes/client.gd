extends Node

var IP_ADDRESS = 'localhost'
var PORT = 8000
var local_player: Node
var remote_players = {}


func _ready():
	var peer = ENetMultiplayerPeer.new()
	multiplayer.connection_failed.connect(_on_peer_connection_failed)
	multiplayer.connected_to_server.connect(_on_peer_connection_success)
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	

func create_player(is_remote_player, player_id, weapon_name):
	var player_node;
	player_node = load("res://scenes/characters/player.tscn").instantiate()
	player_node.is_remote_player = is_remote_player
	player_node.player_id = player_id
	if weapon_name:
		player_node.left_weapon_class = load("res://scenes/weapons/wood/" + weapon_name + ".tscn")
	player_node.right_weapon_class = load("res://scenes/weapons/wood/wooden_round_shield.tscn")
	player_node.sprite_frames = load("res://resources/sprite_frames/player/knight.tres")
	player_node.position.x = 369
	player_node.position.y = 1352.5
	player_node.name = "Player" + str(player_id)
	
	if is_remote_player:
		remote_players[player_id] = player_node
	else:
		local_player = player_node
		print("rpc emmited!")
		create_new_player.rpc(multiplayer.get_unique_id(), weapon_name)
	add_child(player_node, true)
	
	player_node.set_multiplayer_authority(player_id)
	
	
func _on_peer_connection_success():
	var weapon_name = null
	if Autoload.player_weapon_name:
		weapon_name = Autoload.player_weapon_name
	create_player(false, multiplayer.get_unique_id(), weapon_name)
	
	
func _on_peer_connection_failed():
	print("Connection to server failed!")
	
	
@rpc("any_peer", "call_remote", "reliable", 0)
func create_new_player(player_id, weapon_name):
	if str(player_id) != str(multiplayer.get_unique_id()) and not has_node("Player" + str(player_id)):
		create_player(true, player_id, weapon_name)
		
		
@rpc("authority", "call_remote", "reliable", 0)
func create_new_player_server(player_id, weapon_name):
	if str(player_id) != str(multiplayer.get_unique_id()) and not has_node("Player" + str(player_id)):
		create_player(true, player_id, weapon_name)


@rpc("authority", "call_remote", "reliable", 0)
func create_existing_players(incoming_player_id, players_weapons):
	if multiplayer.get_unique_id() == incoming_player_id:
		for player_id in players_weapons:
			var weapon_name = players_weapons[player_id]
			if str(player_id) != str(multiplayer.get_unique_id()):
				create_player(true, player_id, weapon_name)
				
				
@rpc("authority", "call_remote", "reliable", 0)
func remove_player(player_id):
	if remote_players.has(player_id):
		remote_players[player_id].queue_free()
		remote_players.erase(player_id)
		
		
@rpc("authority", "call_remote", "reliable", 0)
func replicate_enemies(enemies_data):
	var enemy_scene = load("res://scenes/characters/enemy.tscn")
	for ind in enemies_data.size():
		var enemy_data = enemies_data[ind]
		var enemy = enemy_scene.instantiate()
		enemy.name = "Enemy" + str(ind)
		enemy.enemy_id = ind
		enemy.position = enemy_data["position"]
		enemy.direction = enemy_data.get("direction", 1)
		enemy.left_weapon_name = enemy_data.get("left_weapon_name", "")
		enemy.right_weapon_name = enemy_data.get("right_weapon_name", "")
		enemy.sprite_frames_name = enemy_data.get("sprite_frames_name", "")
		add_child(enemy, true)
