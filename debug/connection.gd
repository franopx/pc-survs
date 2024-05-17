extends Node2D

const PORT = 6000

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.pressed and event.keycode == KEY_H):
			host_server()
		if(event.pressed and event.keycode == KEY_J):
			join_server()

func host_server():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	
func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	player.position = Vector2(160, 32)

func join_server():
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer
