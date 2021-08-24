extends Node

var enable_sound = true
var enable_music = true
var enable_ads = true

var circles_per_level = 5

var settings_file = "user://settings.save"
func _ready():
	load_settings()
	
func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var(enable_sound)
	f.store_var(enable_music)
	f.store_var(enable_ads)
	f.close()

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		enable_sound = f.get_var()
		enable_music = f.get_var()
		self.enable_ads = f.get_var()
	f.close()

static func rand_weighted(weights):
	var sum = 0
	for weight in weights:
		sum += weight
	var rand = rand_range(0, sum)
	for i in weights.size():
		if rand < weights[i]:
			return i
		rand -= weights[i]
			
