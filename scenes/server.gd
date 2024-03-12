extends Node

var peer = ENetMultiplayerPeer.new()
var PORT = 8000
var MAX_PLAYERS = 100
var players_weapons = {}
var initial_enemies_data = [
	{"position": Vector2(198, 272), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(85, 207), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(196, 142), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1342, 1040), "direction": -1, "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(1471, 981), "direction": -1, "left_weapon_name": "bone_club", "right_weapon_name": "bone_heavy_shield", "sprite_frames_name": "warrior_orc"},
	{"position": Vector2(1340, 910), "direction": -1, "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(846, 1424), "left_weapon_name": "bone_club", "right_weapon_name": "bone_heavy_shield", "sprite_frames_name": "warrior_orc"},
	{"position": Vector2(675, 1425), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(768, 1296), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(948, 284), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(875, 175), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1000, 178), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(448, 1079), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(312, 840), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(871, 964), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(876, 1107), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(1065, 743), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(530, 429), "left_weapon_name": "bone_club", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1383, 400), "left_weapon_name": "bone_club", "sprite_frames_name": "regular_skeleton"}
]
var enemies = []
var server_check;
var enemy_scene = load("res://scenes/characters/enemy.tscn")
var player_scene = load("res://scenes/characters/player.tscn")
var enemy_respawn_time = 5


func _ready():
	start_server()
	if server_check == OK:
		create_enemies()
	else:
		get_tree().change_scene_to_file.call_deferred("res://scenes/UI/weapon_election_menu.tscn")


func start_server():
	server_check = peer.create_server(PORT, MAX_PLAYERS)
	if server_check == OK:
		multiplayer.multiplayer_peer = peer
		peer.peer_connected.connect(_on_peer_connected)
		peer.peer_disconnected.connect(_on_peer_disconnected)
	
	
func create_player(player_id, weapon_name):
	var player_node = player_scene.instantiate()
	player_node.is_remote_player = true
	player_node.player_id = player_id
	if weapon_name:
		player_node.left_weapon_class = load("res://scenes/weapons/wood/" + weapon_name + ".tscn")
	player_node.right_weapon_class = load("res://scenes/weapons/wood/wooden_round_shield.tscn")
	player_node.sprite_frames = load("res://resources/sprite_frames/player/knight.tres")
	player_node.position.x = 369
	player_node.position.y = 1352.5
	player_node.name = "Player" + str(player_id)
	add_child(player_node, true)
	player_node.set_multiplayer_authority(player_id)
	players_weapons[player_id] = weapon_name
	
	
func create_enemy(enemy_id):
	var enemy_data = initial_enemies_data[enemy_id]
	var enemy = enemy_scene.instantiate()
	enemy.name = "Enemy" + str(enemy_id)
	enemy.enemy_id = enemy_id
	enemy.position = enemy_data.get("position")
	enemy.direction = enemy_data.get("direction", 1)
	enemy.left_weapon_name = enemy_data.get("left_weapon_name", "")
	enemy.right_weapon_name = enemy_data.get("right_weapon_name", "")
	enemy.sprite_frames_name = enemy_data.get("sprite_frames_name", "")
	enemy.is_server = true
	add_child(enemy, true)
	enemies[enemy_id] = enemy
	enemy.died.connect(_on_enemy_died)
	
	
func create_enemies():
	enemies.resize(initial_enemies_data.size())
	for ind in initial_enemies_data.size():
		create_enemy(ind)
		
		
func serialize_enemy(enemy):
	return {
		"position": enemy.position,
		"direction": enemy.direction,
		"left_weapon_name": enemy.left_weapon_name,
		"right_weapon_name": enemy.right_weapon_name,
		"sprite_frames_name": enemy.sprite_frames_name
	}
		
		
func serialize_enemies():
	var enemies_data = []
	for enemy in enemies:
		if enemy:
			enemies_data.append(serialize_enemy(enemy))
	return enemies_data
	

func _on_peer_connected(player_id):
	print("Player id " + str(player_id) + " connected")
	
	# Create player and enemy data on the new client
	create_existing_players.rpc(player_id, players_weapons)
	var enemies_data = serialize_enemies()
	replicate_enemies.rpc(enemies_data)
	
	
func _on_peer_disconnected(player_id):
	print("Player id " + str(player_id) + " disconnected")
	players_weapons.erase(player_id)
	remove_player.rpc(player_id)
	get_node("Player" + str(player_id)).queue_free()
	
	
func _on_enemy_died(enemy_id):
	await get_tree().create_timer(enemy_respawn_time).timeout
	create_enemy(enemy_id)
	replicate_enemies.rpc([serialize_enemy(enemies[enemy_id])])
	

@rpc("any_peer", "call_remote", "reliable", 0)
func create_new_player(player_id, weapon_name):
	create_player(player_id, weapon_name)
	create_new_player_server.rpc(player_id, weapon_name)
	
	
@rpc("authority", "call_remote", "reliable", 0)
func create_new_player_server(_player_id, _weapon_name):
	pass
	
	
@rpc("authority", "call_remote", "reliable", 0)
func create_existing_players(_incoming_player_id, _players_weapons):
	pass
	

@rpc("authority", "call_remote", "reliable", 0)
func remove_player(_player_id):
	pass


@rpc("authority", "call_remote", "reliable", 0)
func replicate_enemies(_enemies_data):
	pass
