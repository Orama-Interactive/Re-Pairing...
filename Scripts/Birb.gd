extends AnimatedSprite

onready var player = $"../Player"
onready var timer = $Timer
onready var staticbody2d = $StaticBody2D
var moving := false

func _process(delta):
	if moving:
		position -= Vector2.ONE

func _on_Area2D_body_exited(body):
	print(body.name)
	if "Magnetizable" in body.name && animation == "default":
		animation = "Idle"
		playing = false
		speed_scale = 1
		staticbody2d.collision_layer = 3

func _on_Timer_timeout():
	animation = "Flying"
	playing = true
	moving = true
	get_tree().get_root().get_child(0).get_node("Player").can_jump = true
	$AudioStreamPlayer2D.play()
