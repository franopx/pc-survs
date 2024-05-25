extends Control

var current_peers = []

func _ready():
	Netcode.add_player.connect(_add_player)
	
	Netcode.change_team.connect(
		func(id, team):
			rpc_id(id, "_change_team", team)
	)
	
	# Buncha lambda's
	%"PlayerNameLineEdit".text_changed.connect(
		func(new_text):
			Netcode.player_name = new_text
	)
	
	%"IpLineEdit".text_changed.connect(
		func(new_text):
			Netcode.ip_address = new_text
	)
	
	%HostButton.pressed.connect(
		func():
			Netcode._host_server()
	)
	
	%ConnectButton.pressed.connect(
		func():
			Netcode._join_server()
	)
	
	%StartMatchButton.pressed.connect(
		func():
			var player_list = []
			for player in %RedTeamPlayerList.get_children(): # "player" es una hbox conteniendo label de id - nombre
				player_list.append([player.name, player.get_child(1).text, "Red"])
	
			for player in %BlueTeamPlayerList.get_children(): # "player" es una hbox conteniendo label de id - nombre
				player_list.append([player.name, player.get_child(1).text, "Blue"])
			rpc("_start_match", player_list)
	)


func _process(_delta):
	if(%RedTeamPlayerList.get_child_count() >= 1 and
	%BlueTeamPlayerList.get_child_count() >= 1):
		if(multiplayer.is_server()):
			%StartMatchButton.show()
	else:
		%StartMatchButton.hide()

func _add_player(id, name, team = "Spectator"):
	if(id in current_peers):
		return
	
	%PlayerNameLabel.text = "Your name:"
	%PlayerNameLineEdit.editable = false
	%IpHBox.hide()
	
	var _hbox = HBoxContainer.new()
	
	var id_label = Label.new()
	id_label.text = id
	_hbox.add_child(id_label)
	
	var name_label = Label.new()
	name_label.text = name
	
	_hbox.name = str(id)
	_hbox.add_child(name_label)
	
	match team:
		"Spectator":
			%PlayerListVBox.call_deferred("add_child", _hbox)
		"Red":
			%RedTeamPlayerList.call_deferred("add_child", _hbox)
		"Blue":
			%BlueTeamPlayerList.call_deferred("add_child", _hbox)
	
	current_peers.append(id)


func _on_red_team_button_pressed():
	rpc("_change_team", "Red")
	Netcode.current_team = "Red"


func _on_blue_team_button_pressed():
	rpc("_change_team", "Blue")
	Netcode.current_team = "Blue"


func _on_spectator_team_button_pressed():
	rpc("_change_team", "Spectator")
	Netcode.current_team = "Spectator"


@rpc("authority", "call_local", "reliable")
func _start_match(_player_list):
	
	Netcode.player_lobby = _player_list
	print("Player " + Netcode.player_name + ": LIST "+ str(_player_list))
	get_tree().change_scene_to_file("res://levels/level_1/level_1.tscn")


@rpc("any_peer", "call_local")
func _change_team(team: String):
	var all_players = []
	
	all_players += %PlayerListVBox.get_children() # Spectators
	all_players += %RedTeamPlayerList.get_children() # Red team
	all_players += %BlueTeamPlayerList.get_children() # Blue team
	
	for hbox in all_players:
		if(hbox.name == str(multiplayer.get_remote_sender_id())):
			hbox.get_parent().remove_child(hbox)
			if(team != "Spectator"):
				get_node("%"+team+"TeamPlayerList").add_child(hbox)
			else:
				%PlayerListVBox.add_child(hbox)
