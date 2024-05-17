extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.pressed and event.keycode == KEY_H):
			host_server()
		if(event.pressed and event.keycode == KEY_J):
			join_server()

func host_server():
	pass
