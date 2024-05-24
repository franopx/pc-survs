extends Player

func _process(delta):
	super._process(delta)
	animation()

func animation():
	if(is_on_floor() and direction == 0):
		$Sprite.play("idle")
	elif(is_on_floor() and direction != 0):
		$Sprite.play("walk")
	elif(!is_on_floor()):
		$Sprite.play("air")
	
	$Sprite.flip_h = $Sprite2D.flip_h
	
	if(is_multiplayer_authority()):
		send_sprite.rpc(name, $Sprite.animation, $Sprite.frame)

func update_sprite(_name, _animation, _frame):
	if(name == _name):
		$Sprite.animation = _animation
		$Sprite.frame = _frame

@rpc
func send_sprite(_name, _animation, _frame):
	update_sprite(_name, _animation, _frame)
