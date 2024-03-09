extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var server = load("res://scenes/server.tscn").instantiate()
	add_child(server)
	if server.get_node("Network").server_check != OK:
		remove_child(server)
		server.queue_free()
		var client = load("res://scenes/client.tscn").instantiate()
		add_child(client)
