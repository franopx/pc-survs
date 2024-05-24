extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_CUTOFF = 0.9


var connection

var nick: String
var team: String

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_pressed: bool = false


func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _ready():
	if(is_multiplayer_authority()):
		$Camera2D.enabled = true
	
	%DataClock.timeout.connect(data_sender)
	Netcode.player_moved.connect(update_position)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and is_multiplayer_authority():
		velocity.y += gravity * delta
	
	# Handle jump pression detection for smaller jumps
	if(is_multiplayer_authority()):
		if (Input.is_action_pressed("ui_accept")):
			jump_pressed = true
		else:
			jump_pressed = false
			if(!is_on_floor() and velocity.y < 0):
				velocity.y *= JUMP_CUTOFF
	
	# Handle jump
	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	var direction = 0
	if(is_multiplayer_authority()):
		direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		
		if(direction < 0): $Sprite2D.flip_h = true
		else: $Sprite2D.flip_h = false
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func data_sender():
	if(is_multiplayer_authority()):
		print("Sending update pos from "+name)
		send_position.rpc(name, position)

func update_position(_name, _position):
	if(name.to_int() == multiplayer.get_remote_sender_id()):
		$Sprite2D.flip_h = (position.x - _position.x > 0)
		position = lerp(position, _position, 0.5)

@rpc("any_peer", "call_remote", "unreliable")
func send_position(_name, _position):
	Netcode.player_moved.emit(_name, _position)
