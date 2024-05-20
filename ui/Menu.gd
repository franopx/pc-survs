extends Control

var peer = ENetMultiplayerPeer.new()
var peer_array

var nick
var ip_address
var port

func _ready():
	ip_address = $Panel/MarginContainer/VBoxContainer/IP/LineEdit.text
	port = $Panel/MarginContainer/VBoxContainer/IP2/LineEdit.text
	nick = $Panel/MarginContainer/VBoxContainer/User/LineEdit.text


func _on_button_pressed():
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$Panel.hide()
	$Lobby.show()

func add_player(id = 1):
	PlayerList._add_player(id, nick)

func _on_line_edit_text_changed(new_text):
	port = new_text


func _on_button_2_pressed():
	peer.create_client(ip_address, int(port))
	multiplayer.multiplayer_peer = peer
	$Panel.hide()
	$Lobby.show()


func _on_nick_text_changed(new_text):
	nick = new_text


func _on_ip_text_changed(new_text):
	ip_address = new_text
