extends Node

var high_score_runs = 0
var high_score_ballsFaced = 0
var high_score_wickets = 10

var this_attempt_runs = 0
var this_attempt_ballsFaced = 0

var high_score_file = "user://highScore.save"

func _ready():
	load_high_score()
	
func load_high_score():
	var f = File.new()
	if f.file_exists(high_score_file):
		f.open(high_score_file, File.READ)
		high_score_wickets = f.get_64 ()
		high_score_runs = f.get_64 ()
		high_score_ballsFaced = f.get_64 ()
	f.close()
		
func save_high_score():
	var f = File.new()
	f.open(high_score_file, File.WRITE)
	f.store_64(high_score_wickets)
	f.store_64(high_score_runs)
	f.store_64(high_score_ballsFaced)
	f.close()

func get_high_score():
	return str(high_score_wickets) + "/" + str(high_score_runs) + "(" + str(high_score_ballsFaced/6) +"."+str(high_score_ballsFaced%6) + ")"

func check_if_new_high_score_created(runs,ballsFaced):
	this_attempt_ballsFaced = ballsFaced
	this_attempt_runs = runs	
	
	if runs == high_score_runs:
		if ballsFaced < high_score_ballsFaced:
			create_new_high_score(runs,ballsFaced)

	elif runs > high_score_runs:
		create_new_high_score(runs,ballsFaced)
		

	

	
func create_new_high_score(runs, ballsFaced):	
	high_score_wickets = 10
	high_score_ballsFaced = ballsFaced
	high_score_runs = runs
	save_high_score()
