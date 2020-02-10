extends KinematicBody2D

const GRAVITY := 200.0
const WALK_SPEED := 200
const JUMP_POWER := -120
const CAMERA_DURATION := 2

onready var camera : Camera2D = $Camera2D
onready var camera_tween : Tween = $Camera2D/Tween
onready var beam : Sprite = $Beam
onready var magnet_raycast : RayCast2D = $Beam/RayCast2D
onready var head : Sprite = $Antena_1
onready var eyes : Sprite = $Antena_1/Blink1
onready var wheel : Sprite = $Antena_1/Wheel
onready var information_bar = $"Camera2D/LabelNode/Information Bar"
onready var tutorial_label : Label = $Camera2D/LabelNode/TutorialLabel
onready var repair_words = $Camera2D/LabelNode/RepairWords

var no_input := true
var can_walk := false
var can_jump := false
var shows_beam := false
var velocity := Vector2()
var ray_radius := 120
var ray_direction := 0
var ray_speed := 5
var tutorial_state := 0
var sos_triggered := false

func _ready():
	$"../AudioStreamTape1".play()

func _input(event):
	if no_input:
		return
	if event.is_action_pressed("show_beam"):
		if shows_beam:
			head.animation = "reverse"
			shows_beam = false
			beam.visible = shows_beam
		else:
			head.animation = "default"

		head.playing = true

		if tutorial_state == 1:
			tutorial_label.visible = true
			tutorial_label.text = "You can move it around with your mouse and use the LEFT MOUSE BUTTON\nto examine an object and pick it up"

			tutorial_state += 1
	if event.is_action("grab") && tutorial_state == 2:
		tutorial_label.visible = true
		tutorial_label.text = "Press A and D (or the arrow keys) to move left and right"
		tutorial_state += 1

	if event is InputEventKey:
		if event.is_action("ui_down"):
			ray_direction += ray_speed
		if event.is_action("ui_up"):
			ray_direction -= ray_speed

	if event is InputEventMouseMotion:
		var mouse_dir = (get_global_mouse_position() - beam.global_position).normalized()
# warning-ignore:narrowing_conversion
		ray_direction = rad2deg(mouse_dir.angle())

	if ray_direction < 0:
		ray_direction = 360 + ray_direction
	elif ray_direction > 360:
		ray_direction = 0

	if ray_direction > 55 && ray_direction < 125:
		ray_direction = 55
		if event.is_action("ui_up"):
			ray_direction = 125

	beam.rotation_degrees = ray_direction

func _process(delta):
	camera.global_position.y = 160 # Lock camera y

func _physics_process(delta):
	if no_input:
		return
	velocity.y += delta * GRAVITY

	if can_walk:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -WALK_SPEED
			head.scale.x = -1
			beam.position.x = -10
		elif Input.is_action_pressed("ui_right"):
			velocity.x = WALK_SPEED
			head.scale.x = 1
			beam.position.x = 10
			if tutorial_state == 3:
				tutorial_label.visible = false
				tutorial_state += 1
		else:
			velocity.x = 0

		velocity = move_and_slide(velocity, Vector2(0, -1), false, 4, PI/4, false)
		if abs(velocity.x) > 0.1:
			wheel.rotation_degrees += 20

	if can_jump:
		if Input.is_action_just_pressed("jump") && is_on_floor():
			velocity.y = JUMP_POWER
			if tutorial_state == 5:
				tutorial_label.visible = false
				tutorial_state += 1

		if velocity.y < JUMP_POWER:
			velocity.y = JUMP_POWER

# warning-ignore:return_value_discarded
	camera_tween.interpolate_property(camera, "offset", camera.offset, Vector2(velocity.x * 2, -153), CAMERA_DURATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	camera_tween.start()
	if !shows_beam:
		return
	var magnetizable = magnet_raycast.get_collider()
	if magnetizable:
		if magnetizable.name == "Eye" || magnetizable.get_parent().name == "Birb" || magnetizable.get_parent().name == "Flower" || magnetizable.get_parent().name == "Board":
			$Camera2D/LabelNode/TutorialLabel2.visible = true

		if Input.is_action_pressed("grab"):
			if magnetizable.get_parent().name == "Birb":
				magnetizable.get_parent().timer.wait_time = 2
				magnetizable.get_parent().timer.start()
				no_input = true
				information_bar.visible = true
				information_bar.label.text = "Analysis Results"
				information_bar.rich_text_label.visible_characters = 0
				information_bar.rich_text_label.bbcode_text = "Type: Bird\nFormer status: Extinct"
				information_bar.get_node("AudioStreamPlayer").play()
			elif magnetizable.get_parent().name == "Flower":
				no_input = true
				information_bar.visible = true
				information_bar.label.text = "Analysis Results"
				information_bar.rich_text_label.visible_characters = 0
				information_bar.rich_text_label.bbcode_text = "Type: Flower\nFormer status: Extinct"
				information_bar.get_node("AudioStreamPlayer").play()
			elif magnetizable.get_parent().name == "Board":
				no_input = true
				repair_words.visible = true

			if magnetizable.is_in_group("Magnetizable"):
				if magnetizable.name == "Wheel":
					can_walk = true
					wheel.visible = true
					magnetizable.queue_free()
					$"../AudioStreamPickUp".play()
				if magnetizable.name == "Eye":
					eyes.animation = "default"
					magnetizable.queue_free()
					$"Restrained View".visible = false
					$"../AudioStreamPickUp".play()
				if !magnetizable.held:
					magnetizable.held = true
					magnetizable.radius = magnetizable.position.distance_to(beam.global_position)
	else:
		$Camera2D/LabelNode/TutorialLabel2.visible = false

func _on_Antena_1_frame_changed():
	if head.frame == 2:
		head.playing = false
		if head.animation == "default":
			shows_beam = !shows_beam
			beam.visible = shows_beam

func _on_PitTrigger_body_entered(body):
	if body == self:
		position = Vector2(2600, 150)

func _on_AudioStreamTape1_finished():
	if $"../AudioStreamTape1".playing:
		$"../AudioStreamTape1".stop()
	if !$"../AudioStreamInGameIntro".playing:
		$"../AudioStreamInGameIntro".play()

func _on_AudioStreamInGameIntro_finished():
	$"../AudioStreamInGameBeat".play()
	$"../AudioStreamRain".play()

func _on_SOSTrigger_body_entered(body):
	if body == self && !sos_triggered:
		no_input = true
		sos_triggered = true
		information_bar.visible = true
		information_bar.label.text = "[Incoming Transmission]"
		information_bar.rich_text_label.visible_characters = 0
		information_bar.rich_text_label.bbcode_text = "sos. to any potential suRvivors. this is not thE end. there still is hoPe. follow the source of the trAnsmissIon. oveR."
		$"../AudioStreamInGameBeat".volume_db = -5
		$"../SOSTrigger/AudioStreamTape2".play()

func _on_AcceptButton_pressed():
	var textedit : TextEdit = $"Camera2D/LabelNode/RepairWords/RepairTextEdit"
	if textedit.text.to_upper() == "REPAIR":
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://FinalRoom.tscn")
	else:
		textedit.text = ""

func _on_AudioStreamTape2_finished():
	$"../AudioStreamInGameBeat".volume_db = 0


func _on_RepairTextEdit_text_changed():
	var textedit : TextEdit = $"Camera2D/LabelNode/RepairWords/RepairTextEdit"
	if textedit.get_line_count() > 1:
		textedit.text = textedit.text.replace("\n", "")
