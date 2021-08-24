extends CanvasLayer



func show_message(text):
	$Message.text = text
	$AnimationPlayer.play("show_message")
	
func show_message_long(text):
	$Message.text = text
	$AnimationPlayer.play("show_message_long")
	
func show():
	$ScoreBox.show()

func hide():
	$ScoreBox.hide()
	
func update_score(wickets,runs, ballsFaced):
	$ScoreBox/HBoxContainer/Score.text = str(wickets) + "/" + str(runs) + "(" + str(ballsFaced/6) +"."+str(ballsFaced%6) + ")"
