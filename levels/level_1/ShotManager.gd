extends Node2D

@export var basic_shot_scene : PackedScene

const BULLET_SPEED = 300
const BULLET_DIST = 240

signal instantiate_bullet(_name, _position, _number)

func _ready():
	instantiate_bullet.connect(
		func(_name, _position, _number):
			var player
			for node in get_parent().get_children():
				if(node.name == _name):
					var shot_vec = (node.position - _position)
					var shot_dist = shot_vec.length()
					
					var bullet_pos = node.get_node("GunArmGizmo").global_position
					
					var bullet = basic_shot_scene.instantiate()
					bullet.position = bullet_pos
					bullet.linear_velocity = -shot_vec.normalized() * BULLET_SPEED * clamp(shot_dist/BULLET_DIST*1.5, 2, 700)
					bullet.name = _name + "_" + str(_number)
					
					bullet.get_child(0).body_entered.connect(
						func(_body):
							if(_body is TileMap): bullet.queue_free()
					)
					
					bullet.get_child(0).name = _name + "_" + str(_number)
					
					call_deferred("add_child", bullet, true)
	)
