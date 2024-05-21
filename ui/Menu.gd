extends Control

var peer = ENetMultiplayerPeer.new()
var peer_array

var nick
var ip_address
var port

var player_info = {"name" : "Player"}

var registered: bool = false

signal get_list

func _ready():
	ip_address = $Panel/MarginContainer/VBoxContainer/IP/LineEdit.text
	port = $Panel/MarginContainer/VBoxContainer/IP2/LineEdit.text
	nick = $Panel/MarginContainer/VBoxContainer/User/LineEdit.text
	
	get_list.connect(_on_list_got)

func _on_button_pressed():
	player_info["name"] = nick
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$Panel.hide()
	$Lobby.show()

func add_player(id = 1):
	print(player_info)
	_register_player.rpc_id(id, player_info)

func _on_line_edit_text_changed(new_text):
	port = new_text


func _on_button_2_pressed():
	player_info["name"] = nick
	peer.create_client(ip_address, int(port))
	multiplayer.multiplayer_peer = peer
	$Panel.hide()
	$Lobby.show()

@rpc("any_peer", "call_remote", "reliable")
func _send_players(player_list: Dictionary):
	if(multiplayer.get_remote_sender_id() == 1):
		get_list.emit(player_list)


@rpc("any_peer", "call_remote", "reliable")
func _register_player(new_player_info):
	#print(new_player_info)
	var _id = multiplayer.get_remote_sender_id()
	PlayerList._add_player(_id, new_player_info["name"])


func _on_nick_text_changed(new_text):
	nick = new_text


func _on_ip_text_changed(new_text):
	ip_address = new_text


func _on_list_got(list: Dictionary):
	if (!PlayerList.player_list.is_empty()):
		return
	for item in list:
		PlayerList._add_player(item[0], item[1])
