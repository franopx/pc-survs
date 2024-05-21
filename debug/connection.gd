extends Node2D


const PORT = 6000


var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

var ip_address = "localhost"

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
	await get_tree().create_timer(1).timeout
	print("Player: "+ str(id) + " connected!")
	call_deferred("add_child", player)

func flip_sprite(id, side):
	print("LLamar rpc con "+ str(id) + " side:" + str(side))
	rpc("_switch_sprite", id, side)

@rpc("any_peer", "call_local")
func _switch_sprite(id, side):
	id = multiplayer.get_remote_sender_id()
	for player in get_children():
		if player.has_method("get_peer_id"):
			if(player.get_peer_id() == id):
				player.get_child(0).flip_h = side


func join_server():
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
