extends Sprite

onready var credits_control = $Control

func _process(delta):
	credits_control.rect_position.y -= 200 * delta

func _input(event):
	if event.is_action("jump"):
		get_tree().change_scene("res://Menu.tscn")
