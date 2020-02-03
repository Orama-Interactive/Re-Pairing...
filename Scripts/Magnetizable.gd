extends RigidBody2D

var player : Node2D
var held := false
var radius := 0
var prev_position := position

func _ready():
	player = get_tree().get_root().get_child(0).get_node("Player")

# warning-ignore:unused_argument
func _process(delta):
	if !Input.is_action_pressed("grab") || !player.shows_beam:
		held = false

# warning-ignore:unused_argument
func _physics_process(delta):
	if held:
		#var radius = player.position.distance_to(position)
#		#mode = RigidBody2D.MODE_STATIC
#		#(magnetizable as RigidBody2D).position = position + magnet_ray.points[1]
		position.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		position.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
		apply_central_impulse(Vector2.ZERO)
#		#add_child(magnetizable)
#		print(position)
		gravity_scale = 0
		prev_position = position
	#		if Input.is_action_pressed("ui_accept"):
	#			force = Vector2.ONE
	#
	#		(magnetizable as RigidBody2D).add_force(position, force)
	else:
		if gravity_scale == 0:
			gravity_scale = 3
			linear_velocity.x = 0
			if linear_velocity.y < -500:
				print(linear_velocity.y)
				var magnetizable = load("res://Scripts/Magnetizable.tscn").instance()
				magnetizable.position = prev_position
				$"..".add_child(magnetizable)
			#apply_central_impulse(Vector2.ONE)
			#print(gravity_scale)
#		if mode != RigidBody2D.MODE_RIGID:
#			mode = RigidBody2D.MODE_RIGID

func _integrate_forces(state):
	if held:
		#var radius = position.distance_to(player.position)
		#mode = RigidBody2D.MODE_STATIC
		#(magnetizable as RigidBody2D).position = position + magnet_ray.points[1]
		position.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		position.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
		state.transform.origin.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		state.transform.origin.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
	else:
		state.linear_velocity.x = 0
		state.transform = Transform2D(0, position)
		
	#state.linear_velocity = Vector2()
	#print(state.transform)


func _on_Magnetizable_body_entered(body):
	print(body.name)
	if body.is_in_group("Magnetizable"):
		body.linear_velocity = Vector2.ZERO
