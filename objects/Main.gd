extends Node2D

var Circle = preload("res://objects/Circle.tscn")
var Jumper = preload("res://objects/Jumper.tscn")

var player

var level = 0
var runs = 0
var wickets = 0
var ballsFaced = -1

var latest_circle = null

func _ready():
	$HUD.hide()

func increase_runs(value):
	#print("increasing runs by " + str(value) + ", level: " + str(level))
	
	if value > 0:
		runs += value
		if int(runs)/Settings.circles_per_level > level - 1:
			#print(str(int(runs)/Settings.circles_per_level) + " runs / 5")
			
			if int(runs)/Settings.circles_per_level > level:
				level +=1
				#print("Six when on 1 less than a multiple of circles per level")
			level += 1
			$HUD.show_message("Level up")
	#print ("new level: " + str(level))
func randomise():
	pass
	
func new_game():
	level = 1
	runs = 0
	wickets = 0
	ballsFaced = -1
	
	if Settings.enable_music:
		$BackgroundMusic.play()

	$Camera2D.position = $StartPosition.position
	player = Jumper.instance()
	player.position = $StartPosition.position
	add_child(player)
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died",self, "_on_Jumper_died")
	spawn_circle($StartPosition.position)
	latest_circle.get_node("Label").text = ""
	$HUD.show()
	$HUD.show_message_long("The fate\n of Australian \nCricket rests on \nyour shoulders")
	
func spawn_circle(_position = null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150,150)
		var y = rand_range(-300 - (clamp(level * 13, 0, 300)),-300)
		_position = Vector2(x,y) + player.target.position
	add_child(c)
	c.init(_position, level)
	latest_circle = c
	
func _on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.capture(player)
	call_deferred("spawn_circle")
	
	if !player.just_dismissed and ballsFaced >=0:
		increase_runs(object.run_value)
	else:
		player.reset_just_dismissed()
	ballsFaced += 1
	$HUD.update_score(wickets,runs,ballsFaced)

func compare_y(a,b):
	if a.position.y<b.position.y:
		return a
	else:
		return b
	
func _on_Jumper_died():
	player.just_dismissed=true
	$HUD.show_message("Wicket!")
	wickets += 1
	$HUD.update_score(wickets,runs, ballsFaced)
	if wickets >= 10:
		HighScore.check_if_new_high_score_created(runs,ballsFaced)
		get_tree().call_group("circles", "implode")
		$HUD.hide()

		player.queue_free()
		$Screens.game_over()
		if Settings.enable_music:
			$BackgroundMusic.stop()
		if Settings.enable_sound:
			$TrainSmarter.play()

	else:
		yield(get_tree().create_timer(1), "timeout")
		player.position = latest_circle.position
		player.velocity = Vector2.ZERO
