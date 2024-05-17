extends Control

var peer = ENetMultiplayerPeer.new()
var peer_array

var ip_address
var port

func _ready():
	ip_address = $Panel/MarginContainer/VBoxContainer/IP/LineEdit.text
	port = $Panel/MarginContainer/VBoxContainer/IP2/LineEdit.text

func _on_button_pressed():
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://ui/Lobby.tscn")


func _on_line_edit_text_changed(new_text):
	port = new_text


func _on_button_2_pressed():
	peer.create_client(ip_address, int(port))
	multiplayer.multiplayer_peer = peer
