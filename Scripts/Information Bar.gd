extends Sprite

onready var player = get_parent().get_parent().get_parent()
onready var label : Label = $Label
onready var rich_text_label : RichTextLabel = $RichTextLabel

func _on_Timer_timeout():
	rich_text_label.visible_characters += 1

func _on_DismissButton_pressed():
	if player.tutorial_state == 0:
		player.tutorial_label.visible = true
		player.tutorial_state += 1
		player._on_AudioStreamTape1_finished()
	elif player.tutorial_state == 4:
		player.tutorial_label.visible = true
		player.tutorial_label.text = "Press Space to jump"
		player.tutorial_state += 1
	visible = false
	player.no_input = false
	$AudioStreamPlayer.stop()
