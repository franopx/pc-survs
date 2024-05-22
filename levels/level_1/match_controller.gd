extends Node2D

@export var player_scene: PackedScene

var red_slots = [1, 1, 1]
var blue_slots = [1, 1, 1]

func _ready():
	for peer in Netcode.player_lobby:
		var player = player_scene.instantiate()
		player.name = peer[0]
		player.nick = peer[1]
		player.team = peer[2]
		
		if(player.team == "Red"):
			player.modulate = Color.RED
			for i in range(0, 3):
				if(red_slots[i] == 1):
					player.position = %RedPlayerPos.get_child(i).global_position
					red_slots[i] = 0
					break
		
		if(player.team == "Blue"):
			player.modulate = Color.BLUE
			for i in range(0, 3):
				if(blue_slots[i] == 1):
					player.position = %BluePlayerPos.get_child(i).global_position
					blue_slots[i] = 0
					break
		
		add_child(player)
		player.get_node("Label").text = player.nick

