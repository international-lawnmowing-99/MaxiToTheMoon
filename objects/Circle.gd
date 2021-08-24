extends Area2D

enum MODE {STATIC, LIMITED}

var mode = MODE.STATIC
var max_orbits = 3
var completed_orbits = 0
var orbit_start = null
var jumper = null
var marked_for_deletion = false

var run_value = 0

onready var move_tween = $MoveTween

var move_range = 100  
var move_speed = 1.0  

onready var orbit_position = $Pivot/OrbitPosition
var radius = 100
var rotation_speed = PI
var inflection_level = 26
var plateau_level = 50

func set_mode(_mode):
	mode = _mode
	match mode:
		MODE.STATIC:
			$Label.show()
		MODE.LIMITED:
			randomize()
			modulate = Color(rand_range(1,2),rand_range(1,2),rand_range(1,2))
			$Label.show()
			
func _ready():
	pass

func init(_position, level = 1, current_position = Vector2(0,0)):
	if !_position:
		var x = rand_range(-150,150)
		var y = rand_range(-600,-300)
		_position = Vector2(x,y) + current_position
		
	randomize()
	if level > 0:
		run_value = randi()%7
		
		if level == 0:
			run_value = 0;
		
		if run_value == 5 and rand_range(0,1) < .89:
			run_value = 1
		
		if run_value == 6 and rand_range(0,1) < .5:
			run_value = 2
		
		if run_value>1:
			scale = Vector2( 2/float(run_value), 2/float(run_value))
			$Pivot.scale = Vector2(float(run_value)/2,float(run_value)/2)
		
	var _mode = Settings.rand_weighted([inflection_level/2, level -1])
	var move_chance = clamp(level - inflection_level, 0, inflection_level-1)/inflection_level
	if randf() < move_chance:
		move_range = max(25, 100 * rand_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level/5) * 0.25, 0.75)
	rotation_speed = float(level+6)/ plateau_level * 3*PI;

	set_mode(_mode)
	position = _position
	radius = 100 * (plateau_level - level)/ plateau_level
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.radius = radius
	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1,1) * radius / img_size
	orbit_position.position.x = radius + 25
	rotation_speed *= pow(-1,randi()%2)
	set_tween()
	$Label.text = str(run_value)
	
func _process(delta):
	$Pivot.rotation += rotation_speed * delta
	if mode == MODE.LIMITED and jumper:
		check_orbits()
	
func check_orbits():
	if abs($Pivot.rotation - orbit_start) > 2*PI:
		if Settings.enable_sound:
			$Beep.play()
		completed_orbits +=1
		#$Label.text = str(max_orbits - completed_orbits)
		
		if completed_orbits >= max_orbits and jumper:
			jumper.die()
			jumper = null
			implode()
		
		orbit_start = $Pivot.rotation

func set_tween(_object = null, _key = null):
	if move_range == 0:
		return
	move_range *= -1
	move_tween.interpolate_property(self, "position:x", position.x, position.x + move_range, move_speed,Tween.EASE_IN_OUT)
	move_tween.start()
	
func capture(target):
	jumper = target
	move_tween.stop_all()
	$Pivot.rotation = (jumper.position - position).angle()
	orbit_start = $Pivot.rotation
	$AnimationPlayer.play("Capture")
	yield ($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play(("Brightness Loop"))
	
func implode():
	if !marked_for_deletion:
		$CollisionShape2D.free()
		marked_for_deletion = true
		
	jumper = null
	if ! $AnimationPlayer.current_animation == "Capture":
		$AnimationPlayer.play("Implode")
	else :
		yield ($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("Implode")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func draw_circle_arc_poly(centre, _radius, angle_from, angle_to, colour):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(centre)
	var colours = PoolColorArray([colour])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
		points_arc.push_back(centre + Vector2(cos(angle_point), sin(angle_point)) * _radius)
	draw_polygon(points_arc, colours)

func _draw():
	if jumper && mode == MODE.LIMITED:
		var r = ((radius - 50) / (max_orbits - completed_orbits)) * (1 + max_orbits - (max_orbits - completed_orbits))
		draw_circle_arc_poly(Vector2.ZERO, r, orbit_start + PI/2, $Pivot.rotation + PI/2, Color(1, 0, 0, .95))

func _physics_process(_delta):
	update()
