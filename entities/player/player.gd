extends CharacterBody2D
class_name Player

enum state {
	alive,
	spectator
}

@onready var cam = $Camera2D as Camera2D
var player_state = state.alive
var spectable_players = []
var current_player = 0

# movement related
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_CUTOFF = 0.9
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# projectile
var shots_manager
var shot_type = "basic"
var shot_count = 0
var basic_cooldown: Timer

var max_hp = 16
var hp = 16

# input variables and signals
var direction = 0
var jump_pressed: bool = false

var cursor_position: Vector2
signal lclick
signal rclick

# ENET variables
var connection

var nick: String
var team: String

func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _ready():
	if(is_multiplayer_authority()):
		cam.enabled = true
	
	$ClickGizmos/LeftPoly/Label.text = name
	$ClickGizmos/RightPoly/Label.text = name
	$ClickGizmos/Hover/Label.text = name
	
	basic_cooldown = Timer.new()
	basic_cooldown.wait_time = 0.5
	basic_cooldown.one_shot = true
	add_child(basic_cooldown)
	
	%DataClock.timeout.connect(data_sender)
	Netcode.player_moved.connect(update_position)
	Netcode.player_cursor_action.connect(update_cursor)
	
	if(modulate != Color.WHITE):
		$Sprite2D.modulate = modulate
		modulate = Color.WHITE
	
	$HP.max_value = max_hp
	$HP.value = hp
	
	lclick.connect(
		func(_cursor_position):
			match player_state:
				state.alive:
					$ClickGizmos/LeftPoly.position = _cursor_position
					$ClickGizmos/LeftPoly.modulate.a = 1.0
					
					if(basic_cooldown.is_stopped()):
						shots_manager.emit_signal("instantiate_bullet", name, cursor_position, shot_count)
						basic_cooldown.start()
				state.spectator:
					current_player += 1
					if(current_player >= spectable_players.size()): current_player = 0
					reparent_cam(current_player)
	)
	
	rclick.connect(
		func(_cursor_position):
			match player_state:
				state.alive:
					$ClickGizmos/RightPoly.position = _cursor_position
					$ClickGizmos/RightPoly.modulate.a = 1.0
				state.spectator:
					current_player -= 1
					if(current_player < 0): current_player = spectable_players.size()-1
					reparent_cam(current_player)
	)

func _process(delta):
	$ClickGizmos/LeftPoly.modulate.a = lerp($ClickGizmos/LeftPoly.modulate.a, 0.0, 0.02)
	$ClickGizmos/RightPoly.modulate.a = lerp($ClickGizmos/RightPoly.modulate.a, 0.0, 0.02)
	$ClickGizmos/Hover.modulate.a = lerp($ClickGizmos/Hover.modulate.a, 0.0, 0.02)
	$OuchLabel.modulate.a = lerp($OuchLabel.modulate.a, 0.0, 0.02)
	
	$GunArmGizmo.rotation = position.angle_to_point(cursor_position)
	
	var match_info = get_parent() as Match
	if(match_info != null):
		match team:
			"Red":
				spectable_players = match_info.red_players
			"Blue":
				spectable_players = match_info.blue_players
	

func _physics_process(delta):
	if(player_state != state.alive):
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
		if(velocity.y < 0 and jump_pressed == false):
			velocity.y *= JUMP_CUTOFF
	
	# Handle jump pression detection for smaller jumps
	if (Input.is_action_pressed("ui_accept")):
		if(is_multiplayer_authority()):
			jump_pressed = true
	else:
		if(is_multiplayer_authority()):
			jump_pressed = false

	
	# Handle jump
	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if(is_multiplayer_authority()):
		direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		
		if(direction < 0): $Sprite2D.flip_h = true
		else: $Sprite2D.flip_h = false
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _unhandled_input(event):
	if(not is_multiplayer_authority()):
		return
	
	if event is InputEventMouse:
		var camera_offset = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)/2
		cursor_position = position + event.position - camera_offset
	
	if event is InputEventMouseButton:
		if(event.pressed):
			send_cursor.rpc(name, cursor_position, event.button_index)
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if(is_multiplayer_authority()):
						lclick.emit(cursor_position)
				MOUSE_BUTTON_RIGHT:
					if(is_multiplayer_authority()):
						rclick.emit(cursor_position)
		
	elif event is InputEventMouseMotion:
		$ClickGizmos/Hover.position = cursor_position
		$ClickGizmos/Hover.modulate.a = 1.0
		
		data_sender(true)
	

func data_sender(_is_mouse = false):
		if(is_multiplayer_authority()):
			send_position.rpc(name, position, velocity, direction, jump_pressed)
			
			if(multiplayer.is_server()):
				var match_info = get_parent() as Match
				for p in match_info.get_children():
					if(p is Player):
						sync_hp.rpc(p.name, p.hp)
			
			if(_is_mouse):
				send_cursor.rpc(name, cursor_position, MOUSE_BUTTON_NONE)

func update_position(_name, _position, _velocity, _direction, _jump):
	if(name == _name):
		# send input related variables
		direction = _direction
		jump_pressed = _jump
		
		# update position and velocity in case of a desync
		if((position - _position).length() > 32): 
			position = _position
			velocity = _velocity

@rpc("any_peer", "call_remote", "unreliable")
func send_position(_name, _position, _velocity, _direction, _jump):
	Netcode.player_moved.emit(_name, _position, _velocity, _direction, _jump)


func update_cursor(_name, _position, _button_index):
	if(name != _name): return
	
	match _button_index:
		MOUSE_BUTTON_LEFT:
			if(!is_multiplayer_authority()):
				lclick.emit(_position)
		MOUSE_BUTTON_RIGHT:
			if(!is_multiplayer_authority()):
				rclick.emit(_position)
		MOUSE_BUTTON_NONE:
			cursor_position = _position
			
			$ClickGizmos/Hover.position = cursor_position
			$ClickGizmos/Hover.modulate.a = 1.0

@rpc("any_peer", "call_remote", "unreliable")
func send_cursor(_name, _position,_button_index):
	Netcode.player_cursor_action.emit(_name, _position, _button_index)


func _on_hurt_box_area_entered(area):
	if(!area.name.begins_with(name)):
		$OuchLabel.modulate.a = 1.0
		hp -= 1
		$HP.value = hp
		
		if(hp <= 0 and player_state == state.alive):
			$Sprite2D.modulate = Color.DIM_GRAY
			player_state = state.spectator
			Netcode.player_killed.emit(name)
			reparent_cam(current_player)
	else:
		print("IM IMMUNE")

func reparent_cam(_player):
	cam.name = name + "cam"
	cam.get_parent().remove_child(cam)
	for p in get_parent().get_children():
		if(spectable_players.size() <= 0): break
		if(p.name == spectable_players[current_player]):
			p.add_child(cam)
			break
	cam.position = Vector2.ZERO


@rpc("call_local")
func sync_hp(_name, _hp):
	if(name == _name):
		hp = _hp
