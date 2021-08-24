extends Area2D

var velocity = Vector2(100,0)
var jump_speed = 1313
var target = null

signal captured
signal died

var just_dismissed = false

func reset_just_dismissed():
	just_dismissed = false

onready var trail = $Trail/Points
var trail_length = 25

func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if target and event is InputEventScreenTouch and event.pressed:
		jump()
		
func jump():
	target.implode()
	target = null
	velocity = transform.x * jump_speed
	if Settings.enable_sound:
		$Jump.play()

func _on_Jumper_area_entered(area):
	target = area
	velocity = Vector2.ZERO
	#print(area.run_value)
	emit_signal("captured", area)
	if Settings.enable_sound:
		$Capture.play()
	
func _physics_process(delta):
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)

func die():
	target = null
	just_dismissed = true
	emit_signal("died")

func _on_VisibilityNotifier2D_screen_exited():
	if !target:
		 die()
