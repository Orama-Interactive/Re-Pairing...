extends Sprite

onready var rich_text_label : RichTextLabel = $RichTextLabel
var dialogue_state := 0

func _on_CharaTimer_timeout():
	if rich_text_label.visible_characters == rich_text_label.text.length() && $LineTimer.is_stopped() && dialogue_state < 5:
		$LineTimer.start()
	else:
		rich_text_label.visible_characters += 1

func _on_LineTimer_timeout():
	if dialogue_state == 0:
		rich_text_label.text = "After an extensive research of mine, in a quest to repair this world, I reached some conclusions. We are a simulation after all."
	if dialogue_state == 1:
		rich_text_label.text = "This world was created this way. It hasn’t seen better days. However, the consciousness you carry within you, is the key to repairing the actual world."
	if dialogue_state == 2:
		rich_text_label.text = "You are the reason we exist, and we never existed before you came to life. You are a multidimensional creature."
	if dialogue_state == 3:
		rich_text_label.text = "Go out there and shine your light. Humanity is better than this mess."
	if dialogue_state == 4:
		rich_text_label.visible = false
		$LastDude.playing = true
	if dialogue_state == 5:
		get_tree().change_scene("res://Credits.tscn")

	rich_text_label.visible_characters = 0
	dialogue_state += 1

func _on_LastDude_animation_finished():
	if $LastDude.animation != "Heart":
		$LastDude.animation = "Heart"
		$LineTimer.wait_time = 2
		$LineTimer.start()
