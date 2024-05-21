extends Control

var player_list

@onready var slots = [%"0", %"1", %"2", %"3", %"4", %"5"]

func _ready():
	PlayerList.connect("player_connected", add_player_list)

func add_player_list(_name):
	#print("HELOO=?")
	for slot in slots:
		if slot.text == "":
			slot.text = _name
			return

func _on_button_3_pressed():
	# start game
	pass
