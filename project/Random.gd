extends Node

onready var RunSeed = RandomNumberGenerator.new()


func _ready():
	var t = OS.get_datetime()
	setSeed(str(t.hour+t.minute+t.second))

func setSeed(string:String):
	var s = float(string)
	RunSeed.seed = s
