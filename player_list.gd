extends Node

var peer_list
var player_list: Dictionary

signal player_connected

func _add_player(_id = 1, _name = "Player"):
	player_list[_name] = _id
	#print(player_list)
	player_connected.emit(_name)
