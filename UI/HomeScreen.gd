extends "res://UI/BaseScreen.gd"

func _ready():
	check_for_new_high_score()
	
func check_for_new_high_score():
		if HighScore.high_score_runs > 0:
			$MarginContainer/VBoxContainer/HighScoreText.text = "High Score:" + HighScore.get_high_score()
