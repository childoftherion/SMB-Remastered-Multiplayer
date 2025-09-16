extends Node

@export var local_player: CharacterBody2D
var remote_player = load("res://Scenes/Prefabs/Entities/PlayerGhost.tscn")
var username

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_successfully)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func build_multiplayer_data(player: Player) -> String:
	var data = {
		"position": { "x": player.global_position.x, "y": player.global_position.y },
		"animation": player.sprite.animation,       # animation name
		"frame": player.sprite.frame,               # current frame
		"scale_x": player.sprite.scale.x,           # direction
		"power_state": player.power_state.state_name,  # "Small", "Big", "Fire"
		"character": player.character,              # "Mario", "Luigi", etc.
		"level": Global.current_level.scene_file_path
	}

	return JSON.stringify(data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_nodes = get_tree().get_nodes_in_group("Players")
	if player_nodes.size() > 0:
		local_player = player_nodes[0]
	if local_player:
		player_state.rpc(build_multiplayer_data(local_player))

@rpc("any_peer", "call_remote", "unreliable", 0)
func player_state(data: String):
	if !local_player:
		return
	var sender_player = local_player.get_parent().get_node_or_null(str(multiplayer.get_remote_sender_id()))
	if sender_player != null:
		sender_player.apply_data(data)
	else:
		if remote_player:
			var new_remote_player = remote_player.instantiate()
			new_remote_player.name = str(multiplayer.get_remote_sender_id())
			local_player.get_parent().add_child(new_remote_player)
		
	#print(str(multiplayer.get_remote_sender_id()) + " Sent a position: " + str(pos))
	
func host(port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("(SERVER) Hosted successfully")

func join(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("(CLIENT) Attempting to join")
	
func _on_player_connected(id):
	print("Player Connected")
	
func _on_player_disconnected(id):
	print("Player Disconnected")
	
func _on_connected_successfully():
	print("(CLIENT) Joined Successfully")
	
func _on_connected_fail():
	print("(CLIENT) Failed To Connect")
	
func _on_server_disconnected():
	print("(CLIENT) Disconnected From Server")
