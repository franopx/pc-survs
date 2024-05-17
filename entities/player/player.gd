extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_CUTOFF = 0.9

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_pressed: bool = false

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if(is_multiplayer_authority()):
		$Camera2D.enabled = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump pression detection for smaller jumps.
	
	if (Input.is_action_pressed("ui_accept")):
		jump_pressed = true
	else:
		jump_pressed = false
		if(!is_on_floor() and velocity.y < 0):
			velocity.y *= JUMP_CUTOFF
	
	# Handle jump.
	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	if(is_multiplayer_authority()):
		direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
