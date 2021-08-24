extends Node

signal start_game

var current_screen = null
var sound_buttons = {true: preload("res://assets/images/buttons/audioOn.png"),
					false: preload("res://assets/images/buttons/audioOff.png")}
var music_buttons = {true: preload("res://assets/images/buttons/musicOn.png"),
					false: preload("res://assets/images/buttons/musicOff.png")}
func _ready():
	register_buttons()
	change_screen($HomeScreen)
	if Settings.enable_music:
		$MenuMusic.play()

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])
		match button.name:
			"Sound":
				button.texture_normal = sound_buttons[Settings.enable_sound]
			"Music":
				button.texture_normal = music_buttons[Settings.enable_music]
			"Ads":
				if Settings.enable_ads:
					button.text = "Disable ads"
				else:
					button.text = "Enable ads"
					

func _on_button_pressed(button):
	match button.name:
		"Home":
			change_screen($HomeScreen)
		"Play":
			change_screen(null)
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("start_game")
			$MenuMusic.stop()
		"Sound":
			Settings.enable_sound = !Settings.enable_sound
			button.texture_normal = sound_buttons[Settings.enable_sound]
		"Music":
			Settings.enable_music = !Settings.enable_music
			button.texture_normal = music_buttons[Settings.enable_music]
			if Settings.enable_music:
				$MenuMusic.play()
			else:
				$MenuMusic.stop()
		"Settings":
			change_screen($SettingsScreen)
		"About":
			change_screen($AboutScreen)
	if Settings.enable_sound:
		$Click.play()
	Settings.save_settings()


func change_screen(_screen):
	if _screen == $GameOverScreen:
		$GameOverScreen/MarginContainer/VBoxContainer/HighScoreText.text = "Your Score: " + str(10)+"/"+ str(HighScore.this_attempt_runs) + "(" + str(HighScore.this_attempt_ballsFaced/6) +"."+str(HighScore.this_attempt_ballsFaced%6) + ")" \
		+ "\nHigh Score" +  str(10) + "/" + str(HighScore.high_score_runs) + "(" + str(HighScore.high_score_ballsFaced/6) +"."+str(HighScore.high_score_ballsFaced%6) + ")"
	if _screen == $HomeScreen:
		$HomeScreen.check_for_new_high_score()
		$HomeScreen/AnimationPlayer.seek(0)
	if _screen == $AboutScreen:
		$AboutScreen/AnimationPlayer.seek(0)
	if current_screen:
		current_screen.disappear()
		yield(current_screen.tween, "tween_completed")
	current_screen = _screen
	if _screen:
		current_screen.appear()
		yield(current_screen.tween, "tween_completed")

func game_over():
	change_screen($GameOverScreen)


func _on_TrainSmarter_finished():
	if Settings.enable_music:
		$MenuMusic.play()
