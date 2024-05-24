extends Node2D
class_name Match

@export var player_scene: PackedScene

var red_slots = [1, 1, 1]
var blue_slots = [1, 1, 1]

var red_players := []
var blue_players := []

func _ready():
	
	if(multiplayer.is_server()):
		%RematchButton.text = "WAIT FOR HOST..."
		%RematchButton.disabled = true
	
	Netcode.player_killed.connect(
		func(_name):
			for player in red_players:
				if(player == _name):
					red_players.erase(_name)
					break
			
			for player in blue_players:
				if(player == _name):
					blue_players.erase(_name)
					break
			
			if(red_players.size() == 0):
				%Winner.text = "BLUE WINS!"
				$WinScreen.show()
			
			if(blue_players.size() == 0):
				%Winner.text = "RED WINS!"
				$WinScreen.show()
	)
	
	%RematchButton.pressed.connect(
		func():
			if(multiplayer.is_server()):
				Netcode.reload.rpc()
			#get_tree().reload_current_scene()
	)
	
	%HomeButton.pressed.connect(
		func():
			Netcode.peer = null
			get_tree().change_scene_to_file("res://ui/PlaceholderLobby.tscn")
	)
	
	# Spawn players
	for peer in Netcode.player_lobby:
		var player = player_scene.instantiate()
		
		player.name = peer[0]
		player.nick = peer[1]
		player.team = peer[2]
		player.shots_manager = $ShotManager
		
		if(player.team == "Red"):
			player.modulate = Color.RED
			for i in range(0, 3):
				if(red_slots[i] == 1):
					player.position = %RedPlayerPos.get_child(i).global_position
					red_players.append(player.name)
					red_slots[i] = 0
					break
		
		if(player.team == "Blue"):
			player.modulate = Color.BLUE
			for i in range(0, 3):
				if(blue_slots[i] == 1):
					player.position = %BluePlayerPos.get_child(i).global_position
					blue_players.append(player.name)
					blue_slots[i] = 0
					break
		player.get_node("Label").text = player.nick

		add_child(player, true)

