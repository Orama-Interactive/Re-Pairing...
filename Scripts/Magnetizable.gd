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
		position.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		position.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
		linear_velocity.x = 0
		linear_velocity.y = 0
		gravity_scale = 0
		prev_position = position
	else:
		if gravity_scale == 0:
			gravity_scale = 3
			linear_velocity.x = 0
			if linear_velocity.y < -500:
				print(linear_velocity.y)
				var magnetizable = load("res://Scripts/Magnetizable.tscn").instance()
				magnetizable.position = prev_position
				$"..".add_child(magnetizable)

func _integrate_forces(state):
	if held:
		position.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		position.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
		state.transform.origin.x = player.beam.global_position.x + radius * cos(deg2rad(player.ray_direction))
		state.transform.origin.y = player.beam.global_position.y + radius * sin(deg2rad(player.ray_direction))
