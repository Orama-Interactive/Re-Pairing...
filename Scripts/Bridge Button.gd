extends AnimatedSprite

onready var area : Area2D = $Area2D
var animation_player : AnimationPlayer

func _ready():
	animation_player = get_tree().get_root().get_child(0).get_node("AnimationPlayerBridge")

func _on_Area2D_body_entered(body):
	if "Player" in body.name || "Magnetizable" in body.name:
		frame = 1
		animation_player.play("Left Bridge")


func _on_Area2D_body_exited(body):
	if "Player" in body.name || "Magnetizable" in body.name:
		frame = 0
		animation_player.play("Right Bridge")
