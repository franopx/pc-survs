extends Node

const PORT = 6666

var player_name: String = "Player"
var current_team = "Spectator"

var ip_address: String = "localhost"
var connected_peers = []
var player_lobby = [] # for ingame

var peer = ENetMultiplayerPeer.new()

signal add_player(id, name)
signal change_team(id, team)

# Useful
	# multiplayer.peer_connected.connect(_on_player_connected)
	# multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# multiplayer.connected_to_server.connect(_on_connected_ok)
	# multiplayer.connection_failed.connect(_on_connected_fail)
	# multiplayer.server_disconnected.connect(_on_server_disconnected)

func _host_server():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	_on_peer_connected()


func _join_server():
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer


func _on_peer_connected(id = 1):
	rpc_id(id, "_register_connected_players", connected_peers)
	rpc("_register_player", id)


@rpc("any_peer", "call_local", "reliable")
func _register_player(id):
	connected_peers.append(id)
	rpc("_register_name", player_name, current_team)


@rpc("any_peer", "call_local")
func _register_name(_name = "null", _team = "Spectator"):
	for peer in connected_peers:
		if(peer == multiplayer.get_remote_sender_id()): 
			add_player.emit(str(peer), _name, _team)

@rpc
func _register_connected_players(peers):
	for peer in peers:
		if(peer != multiplayer.get_unique_id()): 
			connected_peers.append(peer)
